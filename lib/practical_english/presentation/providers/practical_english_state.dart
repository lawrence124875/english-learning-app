import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
import '../../domain/models/pe_language.dart';
import '../../domain/models/sentence.dart';
import '../../domain/models/word_learning_state.dart';
import '../../domain/services/coverage_calculator.dart';
import '../../domain/services/legacy_migration.dart';
import '../../domain/services/playback_coordinator.dart';
import '../../domain/services/sentence_access.dart';
import '../../domain/services/sentence_selector.dart';
import '../../domain/services/weak_word_sync.dart';
import '../../domain/services/word_ref_index.dart';

/// 同一句中同拼字的主要詞（顯示用分組）。
class WordGroup {
  final String word;
  final List<String> refs;
  WordGroup(this.word, this.refs);
}

enum PracticalEnglishLoadStatus { idle, loading, ready, error }

/// 手機是否有某語言的 TTS 語音（三態，SPEC §10）。
/// 與 V1 v20 的 `TtsLanguageStatus` 相同；v20 合入 main 後改用
/// `TtsService.checkLanguage`，本地轉接只留到那時。
enum PeVoiceStatus { available, unavailable, unknown }

/// 翻譯朗讀的結果。
enum TranslationSpeechResult { spoken, noTranslation, voiceUnavailable, failed }

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
  final PlaybackCoordinator _playback;

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
    PlaybackCoordinator? playbackCoordinator,
    Future<PeVoiceStatus> Function(String ttsCode)? checkVoice,
  })  : _appState = appState,
        _playback = playbackCoordinator ?? appState.playbackCoordinator,
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
        _translationKey = translationKey ?? BackgroundL10n.translationKey,
        _checkVoiceOverride = checkVoice;

  final Future<PeVoiceStatus> Function(String ttsCode)? _checkVoiceOverride;

  /// SharedPreferences：翻譯語言設定（SPEC §6.4）。沒有這個 key＝跟隨 App 語言。
  static const translationLocalePrefKey = 'pe_translation_locale';

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

  /// 使用者選的翻譯語言（canonical）；null＝跟隨 App 語言。
  String? _translationSetting;

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
      await _loadTranslationSetting();
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
      _playback.registerStopper(PlaybackOwner.v2, _stopForOtherOwner);
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
    _sync =
        WeakWordSync(gateway: _gateway, wordStates: _wordStates, index: _index);
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
      isKnown: _index.contains,
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

  int score(Sentence s) =>
      SentenceSelector.score(s, stateOf, isKnown: _index.contains);

  /// 翻譯語言設定；null＝跟隨 App 語言。
  String? get translationLocaleSetting => _translationSetting;

  /// 目前生效的翻譯語言（canonical）。跟隨 App 語言且介面是英文（或不在
  /// 登錄表的語言）時為 null：不顯示翻譯。
  String? get translationLocale =>
      _translationSetting ?? PeLanguages.canonicalize(_translationKey());

  /// 句子翻譯（SPEC §6.4）：只用目前翻譯語言，簡中可退回繁中；
  /// 沒有就回傳 null，畫面顯示「此句尚無翻譯」。
  SentenceTranslation? translationFor(Sentence s) =>
      s.translationFor(translationLocale);

  Future<void> _loadTranslationSetting() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(translationLocalePrefKey);
      // 不是登錄表代碼的舊值視為「跟隨」，不改寫。
      _translationSetting = raw == null
          ? null
          : PeLanguages.all.any((l) => l.code == raw)
              ? raw
              : null;
    } catch (e, st) {
      _onError(e, st);
      _translationSetting = null;
    }
  }

  /// 設定翻譯語言；null＝跟隨 App 語言（移除 key）。只存 canonical code。
  /// 不影響單字狀態、★、練習次數、解鎖（D18）。
  Future<void> setTranslationLocale(String? code) async {
    final canonical = code == null ? null : PeLanguages.canonicalize(code);
    if (code != null && canonical == null) {
      throw ArgumentError.value(code, 'code', 'not a translation language');
    }
    _translationSetting = canonical;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (canonical == null) {
      await prefs.remove(translationLocalePrefKey);
    } else {
      await prefs.setString(translationLocalePrefKey, canonical);
    }
  }

  /// 句子主要詞依「同 wordLocale＋同拼字」分組（SPEC §9.6，只用於顯示）。
  /// 只看這句自己的 `wordIds`；已不存在的連結略過。
  List<WordGroup> wordGroups(Sentence s) {
    final groups = <String, WordGroup>{};
    for (final ref in s.wordIds.toSet()) {
      final location = _index.resolve(ref);
      if (location == null) continue;
      final word = location.item.word;
      final key = '${location.dataset.wordLocale}\u0001'
          '${word.trim().toLowerCase()}';
      (groups[key] ??= WordGroup(word, [])).refs.add(ref);
    }
    return groups.values.toList(growable: false);
  }

  /// 句中其他值得學的字（只屬於次要詞、目前可對應的）。
  List<String> otherWordsOf(Sentence s) =>
      s.secondaryOnlyWordIds.where(_index.contains).toList(growable: false);

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

  /// 目前這一次朗讀的所有權（[PlaybackCoordinator]）。
  PlaybackLease? _speechLease;

  bool get isSpeaking => _playback.isCurrent(_speechLease);

  /// 朗讀句子：先向 [PlaybackCoordinator] 取得所有權（V1 巡航中會先被停止），
  /// 再用同一個 TTS 引擎朗讀。快速連點或換句時，較新的一次會取代舊的；
  /// 被取代的那次不會再開口，也不會清掉新的所有權。
  /// 只有 TTS 真的出錯才回傳 false（被取代不算失敗）。
  Future<bool> speak(Sentence sentence) async {
    final lease = await _playback.claim(PlaybackOwner.v2);
    if (!_playback.isCurrent(lease)) return true;
    _speechLease = lease;
    try {
      await _tts.stop(); // 停掉自己上一句
      if (!_playback.isCurrent(lease)) return true;
      await _tts.speak(sentence.sentenceText,
          languageCode: sentence.targetLanguage);
      return true;
    } catch (e, st) {
      _onError(e, st);
      return false;
    } finally {
      _releaseSpeech(lease);
    }
  }

  /// 已查過的語音結果（每種語言一次 session 只查、只提示一次）。
  final Map<String, PeVoiceStatus> _voiceStatus = {};

  Future<PeVoiceStatus> _checkVoice(String ttsCode) async {
    final cached = _voiceStatus[ttsCode];
    if (cached != null) return cached;
    PeVoiceStatus status;
    final override = _checkVoiceOverride;
    if (override != null) {
      status = await override(ttsCode);
    } else {
      try {
        final ok = await _tts
            .isLanguageAvailable(ttsCode)
            .timeout(const Duration(seconds: 3));
        status = ok ? PeVoiceStatus.available : PeVoiceStatus.unavailable;
      } catch (_) {
        status = PeVoiceStatus.unknown;
      }
    }
    return _voiceStatus[ttsCode] = status;
  }

  /// 朗讀翻譯（SPEC §10）：用登錄表的 ttsCode，同樣經 [PlaybackCoordinator]
  /// 取得所有權。手機明確沒有該語音時不朗讀，回傳 [TranslationSpeechResult.
  /// voiceUnavailable]（畫面提示一次）；查不到結果時照常朗讀。
  Future<TranslationSpeechResult> speakTranslation(Sentence sentence) async {
    final translation = translationFor(sentence);
    final language =
        translation == null ? null : PeLanguages.lookup(translation.code);
    if (translation == null || language == null) {
      return TranslationSpeechResult.noTranslation;
    }
    final voice = await _checkVoice(language.ttsCode);
    if (voice == PeVoiceStatus.unavailable) {
      return TranslationSpeechResult.voiceUnavailable;
    }
    final lease = await _playback.claim(PlaybackOwner.v2);
    if (!_playback.isCurrent(lease)) return TranslationSpeechResult.spoken;
    _speechLease = lease;
    try {
      await _tts.stop();
      if (!_playback.isCurrent(lease)) return TranslationSpeechResult.spoken;
      await _tts.speak(translation.text, languageCode: language.ttsCode);
      return TranslationSpeechResult.spoken;
    } catch (e, st) {
      _onError(e, st);
      return TranslationSpeechResult.failed;
    } finally {
      _releaseSpeech(lease);
    }
  }

  void _releaseSpeech(PlaybackLease lease) {
    _playback.release(lease);
    if (identical(_speechLease, lease)) _speechLease = null;
  }

  /// 換句、離開句子頁、App 進背景時停止朗讀。只有 V2 仍是擁有者才停 TTS，
  /// 避免 V1 已經接手播放時被這裡誤停。
  Future<void> stopSpeaking() async {
    final lease = _speechLease;
    if (!_playback.isCurrent(lease)) return;
    _releaseSpeech(lease!);
    try {
      await _tts.stop();
    } catch (e, st) {
      _onError(e, st);
    }
  }

  /// V1 claim 時由 coordinator 呼叫：停止 V2 朗讀。所有權已由 coordinator 轉移。
  Future<void> _stopForOtherOwner() async {
    _speechLease = null;
    await _tts.stop();
  }

  /// 匯入句子 CSV（SPEC §8）。檔案層級錯誤會丟 SentenceCsvFileException。
  Future<SentenceImportResult> importCsv(String content,
      {String? translationLocale, bool overwrite = false}) async {
    final result = await SentenceCsvImporter(
      repository: _sentences,
      wordIndex: _index,
    ).importCsv(content,
        translationLocale: translationLocale ?? defaultTranslationLocale,
        overwrite: overwrite);
    _invalidate();
    notifyListeners();
    return result;
  }

  /// 匯入畫面預設的單欄翻譯語言：目前翻譯語言；英文介面跟隨時用 zh-TW。
  String get defaultTranslationLocale => translationLocale ?? 'zh-TW';

  /// 某語言有翻譯的可用句子數（翻譯語言選單用）。
  int translatedCount(String code) =>
      _sentences.all.where((s) => s.translationFor(code)?.code == code).length;

  Future<void> flush() => _wordStates.flush();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // V2.0 沒有背景朗讀。
      stopSpeaking();
      flush().catchError((Object e, StackTrace st) => _onError(e, st));
    }
  }

  @override
  void dispose() {
    _appState.removeListener(_onAppStateChanged);
    _playback.unregisterStopper(PlaybackOwner.v2, _stopForOtherOwner);
    stopSpeaking();
    WidgetsBinding.instance.removeObserver(this);
    flush().catchError((Object e, StackTrace st) => _onError(e, st));
    super.dispose();
  }
}
