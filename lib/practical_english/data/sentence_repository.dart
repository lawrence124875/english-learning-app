import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

import '../domain/models/sentence.dart';
import 'json_file_store.dart';

/// 內建句子與使用者匯入句子的統一存取（SPEC §3、§6.3、§7）。
///
/// - 內建：`assets/practical_english/pe_core.json`（唯讀）。
/// - 匯入：`<App 文件夾>/practical_english/imported_sentences.json`。
/// - 與 V1 的 CustomDatasetRepository 完全分開。
///
/// 進入 Practical English 時 [load] 一次，資料留在記憶體直到 repository 釋放；
/// V1 啟動流程不會呼叫這裡。`Sentence.wordIds`／`secondaryWordIds` 是唯一
/// 持久化的關聯，「單字 → 句子」的反向索引只在記憶體建立（含次要詞）。
class SentenceRepository {
  static const builtInAssetPath = 'assets/practical_english/pe_core.json';
  static const importedFileName = 'imported_sentences.json';
  static const schemaVersion = 1;

  final Future<String?> Function() _loadBuiltInAsset;
  final Future<Directory> Function() _baseDir;
  final JsonStoreErrorReporter? _onError;

  SentenceRepository({
    Future<String?> Function()? loadBuiltInAsset,
    Future<Directory> Function()? baseDir,
    JsonStoreErrorReporter? onError,
  })  : _loadBuiltInAsset = loadBuiltInAsset ?? _defaultLoadAsset,
        _baseDir = baseDir ?? practicalEnglishDir,
        _onError = onError;

  /// Practical English 的本機資料夾（其他 V2 repository 共用）。
  static Future<Directory> practicalEnglishDir() async {
    final base = await getApplicationDocumentsDirectory();
    return Directory('${base.path}/practical_english');
  }

  static Future<String?> _defaultLoadAsset() async {
    try {
      return await rootBundle.loadString(builtInAssetPath);
    } catch (_) {
      return null;
    }
  }

  List<Sentence> _builtIn = const [];
  List<Sentence> _imported = const [];
  final Map<String, Sentence> _byId = {};
  final Map<String, List<String>> _sentenceIdsByWord = {};
  JsonFileStore? _importedStore;
  bool _loaded = false;
  int _skippedEntries = 0;

  bool get isLoaded => _loaded;
  List<Sentence> get builtIn => _builtIn;
  List<Sentence> get imported => _imported;
  Iterable<Sentence> get all => _byId.values;
  int get length => _byId.length;

  /// 載入時因格式錯誤或 ID 重複而略過的筆數（診斷用）。
  int get skippedEntries => _skippedEntries;

  Sentence? byId(String id) => _byId[id];

  /// 含有這個 WordRef（主要詞或次要詞）的句子（依載入順序：內建在前、匯入在後）。
  List<Sentence> sentencesForWord(String wordRef) {
    final ids = _sentenceIdsByWord[wordRef];
    if (ids == null) return const [];
    return ids.map((id) => _byId[id]!).toList(growable: false);
  }

  /// 至少有一句句子的所有 WordRef（主要詞或次要詞；覆蓋率請用
  /// PracticalEnglishCoverage，它只算主要詞）。
  Iterable<String> get wordRefsWithSentences => _sentenceIdsByWord.keys;

  Future<JsonFileStore> _store() async {
    final existing = _importedStore;
    if (existing != null) return existing;
    final dir = await _baseDir();
    return _importedStore = JsonFileStore(
      File('${dir.path}/$importedFileName'),
      onError: _onError,
    );
  }

  /// 載入內建與匯入句子，建立記憶體索引。重複呼叫不會重新讀檔。
  Future<void> load() async {
    if (_loaded) return;
    _skippedEntries = 0;

    final raw = await _loadBuiltInAsset();
    final builtInResult = raw == null
        ? const ParsedSentences([], 0)
        : await compute(parseSentenceFile, raw);

    final importedJson = await (await _store()).read();
    final importedResult = importedJson is Map<String, dynamic>
        ? parseSentenceMap(importedJson)
        : const ParsedSentences([], 0);

    _builtIn = builtInResult.sentences;
    _imported = importedResult.sentences;
    _skippedEntries = builtInResult.skipped + importedResult.skipped;
    _rebuildIndex();
    _loaded = true;
  }

  /// 以新的匯入句子清單整個取代（原子寫入），並重建索引。
  /// 匯入流程（Phase 3）先在記憶體完成驗證與合併，最後一次呼叫這裡。
  Future<void> replaceImported(List<Sentence> sentences) async {
    final store = await _store();
    await store.write({
      'schema': schemaVersion,
      'sentences': sentences.map((s) => s.toJson()).toList(),
    });
    _imported = List.unmodifiable(sentences);
    _rebuildIndex();
  }

  void _rebuildIndex() {
    _byId.clear();
    _sentenceIdsByWord.clear();
    // 內建優先：匯入句子若與內建 ID 相同（理論上前綴不同不會發生）就略過。
    for (final s in [..._builtIn, ..._imported]) {
      if (_byId.containsKey(s.id)) {
        _skippedEntries++;
        continue;
      }
      _byId[s.id] = s;
      for (final ref in s.allWordIds) {
        (_sentenceIdsByWord[ref] ??= <String>[]).add(s.id);
      }
    }
  }
}

/// 解析結果：成功的句子與略過的筆數。
class ParsedSentences {
  final List<Sentence> sentences;
  final int skipped;
  const ParsedSentences(this.sentences, this.skipped);
}

/// 解析整份句子 JSON 字串（給 `compute()` 在背景 isolate 執行，必須是頂層函式）。
/// 整份格式錯誤時回傳空清單，不丟例外。
ParsedSentences parseSentenceFile(String raw) {
  try {
    final json = jsonDecode(raw);
    if (json is Map<String, dynamic>) return parseSentenceMap(json);
  } catch (_) {}
  return const ParsedSentences([], 0);
}

/// 解析 `{"schema":1, "sentences":[...]}`；單筆錯誤只略過該筆。
ParsedSentences parseSentenceMap(Map<String, dynamic> json) {
  final list = json['sentences'];
  if (list is! List) return const ParsedSentences([], 0);
  final result = <Sentence>[];
  var skipped = 0;
  for (final entry in list) {
    try {
      result.add(Sentence.fromJson(Map<String, dynamic>.from(entry as Map)));
    } catch (_) {
      skipped++;
    }
  }
  return ParsedSentences(List.unmodifiable(result), skipped);
}
