import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/widgets.dart';

import '../../../data/sources/background_l10n.dart';
import '../../../data/sources/tts_service.dart';
import '../../../domain/models/word_item.dart';
import '../../../presentation/providers/app_state.dart';
import '../../data/app_state_v1_gateway.dart';
import '../../data/json_file_store.dart';
import '../../data/sentence_csv_importer.dart';
import '../../data/sentence_repository.dart';
import '../../data/v1_legacy_gateway.dart';
import '../../data/word_state_repository.dart';
import '../../domain/models/sentence.dart';
import '../../domain/models/word_learning_state.dart';
import '../../domain/services/coverage_calculator.dart';
import '../../domain/services/legacy_migration.dart';
import '../../domain/services/sentence_access.dart';
import '../../domain/services/sentence_selector.dart';
import '../../domain/services/weak_word_sync.dart';
import '../../domain/services/word_ref_index.dart';

enum PracticalEnglishLoadStatus { idle, loading, ready, error }

/// Practical English 的獨立狀態（SPEC §3）。不放進 AppState。
///
/// - 進入 Practical English 時才建立並 [load]（V1 啟動不受影響），
///   離開時 dispose，並把尚未寫入的學習狀態寫出。
/// - 資料來源仍是各 repository（句子、canonical 單字狀態）；這裡只保存
///   目前模式與排序結果的快取，任何狀態變更後重新計算。
/// - 只從 AppState 讀取 isPremium、教材、unlockedCount；★ 讀寫經
///   Phase 2 的相容層（V1LegacyGateway／WeakWordSync），不直接碰 V1 key。
class PracticalEnglishState extends ChangeNotifier with WidgetsBindingObserver {
  final AppState _appState;
  final TtsService _tts;
  final SentenceRepository _sentences;
  final WordStateRepository _wordStates;
  final V1LegacyGateway _gateway;
  final Future<Directory> Function()? _baseDir;
  final JsonStoreErrorReporter _onError;
  final DateTime Function() _now;
  final String Function() _translationKey;

  PracticalEnglishState({
    required AppState appState,
    required TtsService tts,
    SentenceRepository? sentences,
    WordStateRepository? wordStates,
    V1LegacyGateway? gateway,
    Future<Directory> Function()? baseDir,
    JsonStoreErrorReporter? onError,
    DateTime Function()? now,
    String Function()? translationKey,
  })  : _appState = appState,
        _tts = tts,
        _onError = onError ?? _reportToCrashlytics,
        _baseDir = baseDir,
        _sentences = sentences ??
            SentenceRepository(
                baseDir: baseDir, onError: onError ?? _reportToCrashlytics),
        _wordStates = wordStates ??
            WordStateRepository(
                baseDir: baseDir, onError: onError ?? _reportToCrashlytics),
        _gateway = gateway ?? AppStateV1Gateway(appState),
        _now = now ?? DateTime.now,
        _translationKey = translationKey ?? BackgroundL10n.translationKey;

  static void _reportToCrashlytics(Object error, StackTrace stack) {
    try {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
    } catch (_) {
      debugPrint('Practical English error: $error');
    }
  }

  PracticalEnglishLoadStatus status = PracticalEnglishLoadStatus.idle;
  MigrationReport? lastMigration;
  late WordRefIndex _index;
  late SentenceAccess _access;
  late WeakWordSync _sync;

  LearningMode _mode = LearningMode.weakPriority;
  List<Sentence>? _ordered;
  PracticalEnglishCoverage? _coverage;
  bool _lastPremium = false;
  int _lastDatasetCount = 0;

  LearningMode get mode => _mode;
  bool get isReady => status == PracticalEnglishLoadStatus.ready;

  /// 載入句子、執行 V1 migration／reconciliation、建立索引。
  Future<void> load() async {
    if (status == PracticalEnglishLoadStatus.loading) return;
    status = PracticalEnglishLoadStatus.loading;
    notifyListeners();
    try {
      final datasets = List<WordDataset>.of(_appState.datasets);
      await _sentences.load();
      lastMigration = await LegacyMigration(
        gateway: _gateway,
        wordStates: _wordStates,
        baseDir: _baseDir,
        onError: _onError,
      ).run(datasets);
      // migration 失敗時仍可使用（狀態從現有檔案載入，下次進入重試）。
      await _wordStates.load();
      _rebuildIndex(datasets);
      _lastPremium = _appState.isPremium;
      _appState.addListener(_onAppStateChanged);
      WidgetsBinding.instance.addObserver(this);
      status = PracticalEnglishLoadStatus.ready;
    } catch (e, st) {
      _onError(e, st);
      status = PracticalEnglishLoadStatus.error;
    }
    notifyListeners();
  }

  void _rebuildIndex(List<WordDataset> datasets) {
    _index = WordRefIndex.build(datasets);
    _access = SentenceAccess(_index, _appState.unlockedCount);
    _sync = WeakWordSync(
        gateway: _gateway, wordStates: _wordStates, index: _index);
    _lastDatasetCount = datasets.length;
    _invalidate();
  }

  /// AppState 會頻繁通知（播放進度）；只有權限或教材變動才重算。
  void _onAppStateChanged() {
    if (!isReady) return;
    if (_appState.datasets.length != _lastDatasetCount) {
      _rebuildIndex(List.of(_appState.datasets));
      notifyListeners();
    } else if (_appState.isPremium != _lastPremium) {
      _lastPremium = _appState.isPremium;
      _invalidate();
      notifyListeners();
    }
  }

  void _invalidate() {
    _ordered = null;
    _coverage = null;
  }

  // ---------------- 查詢 ----------------

  WordLearningState stateOf(String ref) => _wordStates.get(ref);

  WordStatus statusOf(String ref) => deriveWordStatus(stateOf(ref));

  WordLocation? wordFor(String ref) => _index.resolve(ref);

  bool get isPremium => _appState.isPremium;

  /// 目前模式下可學的句子（已套用免費／Premium 規則並排序）。
  List<Sentence> get sentences {
    return _ordered ??= SentenceSelector.order(
      _sentences.all.where(_access.isAccessible).toList(growable: false),
      _mode,
      stateOf,
    );
  }

  /// 因免費版限制而鎖住的句子數（不顯示內容，只提示數量）。
  int get lockedCount => coverage.lockedSentences;

  PracticalEnglishCoverage get coverage =>
      _coverage ??= PracticalEnglishCoverage.compute(
        index: _index,
        sentences: _sentences.all,
        access: _access,
        stateOf: stateOf,
      );

  int score(Sentence s) => SentenceSelector.score(s, stateOf);

  /// 句子翻譯：介面語言 → zh-TW → 第一個可用（同 V1 規則）。
  String? translationFor(Sentence s) => s.translationFor(_translationKey());

  /// 單字的意思：內建教材跟介面語言（英文介面不顯示，同 V1）；
  /// 自訂教材用匯入時選的語言。
  String? meaningFor(String ref) {
    final location = wordFor(ref);
    if (location == null) return null;
    final dataset = location.dataset;
    final item = location.item;
    if (dataset.builtIn) {
      final key = _translationKey();
      if (key == 'en') return null;
      if (!key.startsWith('zh') && !item.translations.containsKey(key)) {
        return null;
      }
      final m = item.meaningFor(key);
      return m.isEmpty ? null : m;
    }
    final m = item.meaningFor(dataset.primaryLocale);
    return m.isEmpty ? null : m;
  }

  // ---------------- 操作 ----------------

  void setMode(LearningMode mode) {
    if (mode == _mode) return;
    _mode = mode;
    _ordered = null;
    notifyListeners();
  }

  /// 標記／取消弱字（經相容層同步 V1 ★）。
  Future<void> setWeak(String ref, bool weak) async {
    await _sync.setWeak(ref, weak);
    _invalidate();
    notifyListeners();
  }

  /// 「我會了」：mastered＝true、移除弱字與 V1 ★；不刪除任何紀錄。
  Future<void> setMastered(String ref, bool mastered) async {
    await _sync.setMastered(ref, mastered);
    _invalidate();
    notifyListeners();
  }

  /// 練習一句：句中每個字 peExposureCount＋1、更新 lastPracticedAt。
  /// 只算接觸，不會改變弱字或精熟狀態。
  void recordPractice(Sentence sentence) {
    final now = _now();
    for (final ref in sentence.wordIds.toSet()) {
      if (!_index.contains(ref)) continue;
      final s = stateOf(ref);
      _wordStates.put(
          ref,
          s.copyWith(
              peExposureCount: s.peExposureCount + 1, lastPracticedAt: now));
    }
    _wordStates.scheduleSave();
    _invalidate();
    notifyListeners();
  }

  /// 朗讀句子。Phase 4 先用既有公開介面：V1 巡航播放中就先停止，
  /// 再用同一個 TTS 引擎朗讀（完整的 PlaybackCoordinator 在 Phase 5）。
  /// TTS 失敗不影響畫面，回傳 false。
  Future<bool> speak(Sentence sentence) async {
    try {
      if (_appState.isPlaying) _appState.stopCruise();
      await _tts.stop();
      await _tts.speak(sentence.sentenceText,
          languageCode: sentence.targetLanguage);
      return true;
    } catch (e, st) {
      _onError(e, st);
      return false;
    }
  }

  Future<void> stopSpeaking() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }

  /// 匯入句子 CSV（Phase 3 importer）。檔案層級錯誤會丟 SentenceCsvFileException。
  Future<SentenceImportResult> importCsv(String content,
      {String? translationLocale}) async {
    final result = await SentenceCsvImporter(
      repository: _sentences,
      wordIndex: _index,
    ).importCsv(content,
        translationLocale: translationLocale ?? _translationKey());
    _invalidate();
    notifyListeners();
    return result;
  }

  /// 匯入預設翻譯語言（介面語言對應的教材翻譯代碼）。
  String get defaultTranslationLocale => _translationKey();

  Future<void> flush() => _wordStates.flush();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      flush().catchError((Object e, StackTrace st) => _onError(e, st));
    }
  }

  @override
  void dispose() {
    _appState.removeListener(_onAppStateChanged);
    WidgetsBinding.instance.removeObserver(this);
    flush().catchError((Object e, StackTrace st) => _onError(e, st));
    super.dispose();
  }
}
