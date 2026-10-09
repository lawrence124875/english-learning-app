import 'dart:io';

import '../domain/models/word_learning_state.dart';
import 'json_file_store.dart';
import 'sentence_repository.dart';

/// V2 單字學習狀態（canonical，以 WordRef 為鍵）的存取（SPEC §7.1、§7.2）。
/// 檔案：`<App 文件夾>/practical_english/word_state.json`。
class WordStateRepository {
  static const fileName = 'word_state.json';
  static const schemaVersion = 1;

  final Future<Directory> Function() _baseDir;
  final JsonStoreErrorReporter? _onError;
  JsonFileStore? _store;

  final Map<String, WordLearningState> _states = {};
  bool _loaded = false;
  bool _rebuiltFromCorruption = false;

  WordStateRepository({
    Future<Directory> Function()? baseDir,
    JsonStoreErrorReporter? onError,
  })  : _baseDir = baseDir ?? SentenceRepository.practicalEnglishDir,
        _onError = onError;

  bool get isLoaded => _loaded;

  /// 這次載入時狀態檔（含 .bak）損毀，目前是從空狀態重建的。
  /// Migration 會據此避免用空的 weak 集合覆蓋 V1 ★（SPEC §5.5）。
  bool get rebuiltFromCorruption => _rebuiltFromCorruption;

  Future<JsonFileStore> _fileStore() async {
    final existing = _store;
    if (existing != null) return existing;
    final dir = await _baseDir();
    return _store =
        JsonFileStore(File('${dir.path}/$fileName'), onError: _onError);
  }

  /// 載入狀態檔；檔案不存在或損毀時從空狀態開始（損毀由 JsonFileStore 回報）。
  Future<void> load() async {
    if (_loaded) return;
    final store = await _fileStore();
    final json = await store.read();
    _rebuiltFromCorruption = store.lastReadCorrupt;
    _states.clear();
    if (json is Map && json['words'] is Map) {
      (json['words'] as Map).forEach((key, value) {
        if (value is Map) {
          final state =
              WordLearningState.fromJson(Map<String, dynamic>.from(value));
          if (!state.isEmpty) _states[key.toString()] = state;
        }
      });
    }
    _loaded = true;
  }

  WordLearningState get(String ref) =>
      _states[ref] ?? WordLearningState.empty;

  /// 目前所有有狀態的單字（唯讀）。
  Map<String, WordLearningState> get all => Map.unmodifiable(_states);

  /// 更新單一單字；空狀態會直接移除，不存檔。
  void put(String ref, WordLearningState state) {
    if (state.isEmpty) {
      _states.remove(ref);
    } else {
      _states[ref] = state;
    }
  }

  Map<String, dynamic> _toJson() => {
        'schema': schemaVersion,
        'words': _states.map((k, v) => MapEntry(k, v.toJson())),
      };

  /// 立刻以原子方式寫入（migration／reconciliation 用）。
  Future<void> saveNow() async => (await _fileStore()).write(_toJson());

  /// 延遲合併寫入（一般學習操作用）。
  Future<void> scheduleSave() async =>
      (await _fileStore()).scheduleWrite(_toJson());

  /// 寫出尚未寫入的資料（App 進背景、離開 Practical English 時呼叫）。
  Future<void> flush() async => (await _fileStore()).flush();
}
