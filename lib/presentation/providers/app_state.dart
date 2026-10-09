import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/models/word_item.dart';
import '../../domain/models/playback_settings.dart';
import '../../domain/services/playlist_builder.dart';
import '../../data/repositories/word_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../data/sources/tts_service.dart';
import '../../data/sources/tts_audio_handler.dart';
import '../../data/sources/subscription_service.dart';
import '../../data/sources/ads_service.dart';
import '../../data/sources/analytics_service.dart';
import '../../data/repositories/stats_repository.dart';
import '../../data/sources/notification_service.dart';
import '../../data/sources/background_l10n.dart';
import '../../data/sources/cover_art.dart';
import '../../data/repositories/custom_dataset_repository.dart';
import '../../practical_english/domain/services/playback_coordinator.dart';

/// App 的核心狀態管理，整合資料層與播放邏輯，供 UI 層使用。
class AppState extends ChangeNotifier {
  final WordRepository _wordRepository;
  final ProgressRepository _progressRepository;
  final TtsService _ttsService;
  final TtsAudioHandler? _audioHandler;
  final StatsRepository _statsRepository = StatsRepository();
  final CustomDatasetRepository _customDatasetRepository =
      CustomDatasetRepository();

  LearningStats stats = const LearningStats();
  bool reminderEnabled = false;
  int reminderHour = 20;
  int reminderMinute = 0;

  AppState({
    required WordRepository wordRepository,
    required ProgressRepository progressRepository,
    required TtsService ttsService,
    TtsAudioHandler? audioHandler,
  })  : _wordRepository = wordRepository,
        _progressRepository = progressRepository,
        _ttsService = ttsService,
        _audioHandler = audioHandler {
    _audioHandler?.bindCallbacks(
      onPlay: startCruise,
      onPause: () async => stopCruise(),
      onSkipNext: () => next(),
      onSkipPrevious: () => previous(),
    );
    NotificationService.startRequests.addListener(_onStartRequest);
    // V2：Practical English 開始朗讀時停止 V1（SPEC §10）。
    playbackCoordinator.registerStopper(
        PlaybackOwner.v1, () async => stopCruise());
  }

  /// V1／V2 共用 TTS 的朗讀擁有者（SPEC §10）。V1 只在 [_speakCurrent]
  /// 開頭 claim、在朗讀結束與 [stopCruise] 時歸還，其餘播放邏輯不變。
  final PlaybackCoordinator playbackCoordinator = PlaybackCoordinator();

  /// 背景播放／鎖屏控制（V2 句子播放接管鎖屏用）；初始化失敗時為 null。
  TtsAudioHandler? get audioHandler => _audioHandler;
  PlaybackLease? _v1Lease;

  void _releaseV1Playback() {
    playbackCoordinator.release(_v1Lease);
    _v1Lease = null;
  }

  // --- 0.3.0：每日提醒的「▶ 開始朗讀」與提醒內文 ---
  bool _pendingStart = false;

  void _onStartRequest() {
    if (isLoading || datasets.isEmpty) {
      _pendingStart = true;
    } else {
      unawaited(startCruise());
    }
  }

  Timer? _reminderDebounce;
  DateTime _lastReminderRefresh = DateTime.fromMillisecondsSinceEpoch(0);

  /// 換字後節流更新提醒內文（最多每 3 分鐘一次），避免巡航時一直重排。
  void _scheduleReminderRefresh({bool force = false}) {
    if (!force &&
        DateTime.now().difference(_lastReminderRefresh) <
            const Duration(minutes: 3)) {
      return;
    }
    _reminderDebounce?.cancel();
    _reminderDebounce =
        Timer(const Duration(seconds: 5), () => unawaited(_refreshReminders()));
  }

  /// 依目前資料更新提醒內文與大圖示，並重新排程每日提醒與久未使用提醒。
  /// 內文是排程當下的資料（不是即時的）。失敗不影響 App。
  Future<void> _refreshReminders() async {
    _lastReminderRefresh = DateTime.now();
    try {
      final word = currentWord;
      final state = currentPlaybackState;
      final hasProgress = state.currentStep > 0 || state.cycleCount > 1;
      final starred =
          _starredSets.values.fold<int>(0, (sum, s) => sum + s.length);
      String? lastHeard;
      if (word != null && hasProgress) {
        final meaning = meaningOf(word);
        lastHeard = meaning.isEmpty ? word.word : '${word.word} $meaning';
      }
      await NotificationService.setReminderContent(
        lastHeard: lastHeard,
        starredCount: starred,
        iconWord: word?.word,
      );
      if (reminderEnabled) {
        await NotificationService.scheduleDailyReminder(
            hour: reminderHour, minute: reminderMinute);
      }
      await NotificationService.rescheduleInactivityReminder();
    } catch (e) {
      debugPrint('提醒內文更新失敗（不影響 App）：$e');
    }
  }

  List<WordDataset> datasets = [];
  int currentDatasetIndex = 0;
  PlaybackSettings settings = const PlaybackSettings();

  final Map<String, DatasetPlaybackState> _playbackStates = {};
  final Map<String, Set<int>> _starredSets = {};

  bool isPlaying = false;
  bool isLoading = true;
  Timer? _cruiseTimer;

  /// 朗讀世代編號：每開始一次新的朗讀（或停止）就 +1。
  /// 舊的朗讀流程在每個 await 之後檢查編號，發現已過期就立刻結束，
  /// 避免快速連按上一個/下一個時，舊單字的重複朗讀或翻譯接著念出來，
  /// 把新單字的聲音蓋掉（沒聲音、聲音和畫面上的字不同步）。
  int _speakGen = 0;
  bool _speechActive = false;

  /// 巡航迴圈世代編號：暫停後很快又按播放時，舊迴圈醒來會發現已過期而結束，
  /// 不會出現兩個迴圈同時推進（單字跳得比設定的間隔快）。
  int _cruiseGen = 0;

  // --- 免費版 / 訂閱相關 ---
  bool isPremium = false;

  /// 每個教材各自的「本次使用階段額外解鎖」數量（看獎勵廣告換來的），
  /// 只存在記憶體裡，重開 App 就會重置，符合「加速器」而非永久解鎖的設計。
  final Map<String, int> _sessionExtraUnlocked = {};

  static const _freeUnlockFraction = 1 / 3;
  static const _rewardedAdUnlockAmount = 20;

  /// 免費版使用者目前可以存取的項目數（超過這個範圍的單字不會出現在播放清單裡）。
  /// Premium 使用者永遠回傳整份教材的長度。
  int unlockedCount(WordDataset dataset) {
    if (isPremium) return dataset.items.length;
    final base = (dataset.items.length * _freeUnlockFraction).floor();
    final extra = _sessionExtraUnlocked[dataset.id] ?? 0;
    return (base + extra).clamp(0, dataset.items.length);
  }

  bool get currentDatasetFullyUnlocked =>
      isPremium || unlockedCount(currentDataset) >= currentDataset.items.length;

  WordDataset get currentDataset => datasets[currentDatasetIndex];

  DatasetPlaybackState get currentPlaybackState =>
      _playbackStates[currentDataset.id] ?? const DatasetPlaybackState();

  Set<int> get currentStarred => _starredSets[currentDataset.id] ?? <int>{};

  /// 目前單字是否已加入不熟悉單字庫（首頁星號實心／空心）。
  bool get isCurrentStarred {
    final state = currentPlaybackState;
    if (state.playlist.isEmpty) return false;
    return currentStarred
        .contains(state.playlist[state.currentStep % state.playlist.length]);
  }

  WordItem? get currentWord {
    final state = currentPlaybackState;
    if (state.playlist.isEmpty) return null;
    final idx = state.playlist[state.currentStep % state.playlist.length];
    return currentDataset.items[idx];
  }

  /// 目前單字在整份教材裡的編號（從 1 開始），用於畫面顯示「128 / 2809」。
  int? get currentWordNumber {
    final state = currentPlaybackState;
    if (state.playlist.isEmpty) return null;
    final idx = state.playlist[state.currentStep % state.playlist.length];
    return idx + 1;
  }

  double get progressRatio {
    final state = currentPlaybackState;
    if (state.playlist.isEmpty) return 0;
    return (state.currentStep + 1) / state.playlist.length;
  }

  /// 目前是第幾輪學習（每播完一整輪、重新洗牌後會 +1）。
  int get currentCycleNumber => currentPlaybackState.cycleCount;

  /// 本輪已經播到第幾個（從1開始）。
  int get roundHeardCount => currentPlaybackState.currentStep + 1;

  /// 本輪總共有幾個項目（依目前播放範圍/模式決定，例如僅不熟悉時
  /// 會比全部清單少）。
  int get roundTotalCount => currentPlaybackState.playlist.length;

  /// 只給介面截圖測試用：不碰任何外掛，直接放入教材與播放位置。
  @visibleForTesting
  void debugPreview({
    required List<WordDataset> data,
    PlaybackSettings? newSettings,
    bool premium = false,
    int step = 0,
    int index = 0,
  }) {
    datasets = data;
    currentDatasetIndex = index;
    if (newSettings != null) settings = newSettings;
    isPremium = premium;
    for (final d in data) {
      _starredSets[d.id] = <int>{};
      _playbackStates[d.id] = DatasetPlaybackState(
        playlist: List.generate(d.items.length, (i) => i),
        currentStep: step.clamp(0, d.items.length - 1),
      );
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> initialize() async {
    isLoading = true;
    notifyListeners();

    isPremium = await SubscriptionService.isPremium();
    AdsService.adsEnabled = !isPremium;
    // 第十七版：免費版才走廣告同意（UMP）流程並初始化廣告；不等它完成。
    if (!isPremium) unawaited(AdsService.startConsentAndAds());
    AnalyticsService.setUserProperties(isPremium: isPremium);
    stats = await _statsRepository.loadStats();
    reminderEnabled = await _progressRepository.loadReminderEnabled();
    final reminderTime = await _progressRepository.loadReminderTime();
    reminderHour = reminderTime.$1;
    reminderMinute = reminderTime.$2;
    // 通知排程失敗絕不能中斷 initialize()，否則畫面會一直卡在載入中
    // （第 9～10 版 Crashlytics 回報的 NotificationService.requestPermission 當機）。
    // 啟動時也不再請求通知權限：使用者開啟每日提醒時（setReminder）已經問過，
    // 啟動時沒有使用者操作、Activity 可能還沒就緒，正是出錯的時機。
    try {
      if (reminderEnabled) {
        // 重新排程一次，確保裝置重開機等情況下提醒仍然有效。
        await NotificationService.scheduleDailyReminder(
            hour: reminderHour, minute: reminderMinute);
      }
    } catch (e) {
      debugPrint('每日提醒重新排程失敗（不影響 App）：$e');
    }
    // 久未使用提醒：不受使用者是否關閉每日提醒影響，每次啟動都重新
    // 排到 3 天後，只要持續正常使用就永遠不會真的跳出來。
    try {
      await NotificationService.rescheduleInactivityReminder();
    } catch (e) {
      debugPrint('久未使用提醒排程失敗（不影響 App）：$e');
    }
    datasets = await _wordRepository.loadAllDatasets();
    datasets.addAll(await _customDatasetRepository.loadAll());
    settings = await _progressRepository.loadSettings();
    await _applyVoiceIfNeeded();
    await _ttsService.setRate(settings.speechRate);

    for (final dataset in datasets) {
      _starredSets[dataset.id] =
          await _progressRepository.loadStarred(dataset.id);
      final saved = await _progressRepository.loadProgress(dataset.id);
      _playbackStates[dataset.id] = saved.playlist.isEmpty
          ? _rebuildPlaylist(dataset, _starredSets[dataset.id]!)
          : saved;
    }

    isLoading = false;
    _updateNowPlaying();
    notifyListeners();
    unawaited(_refreshReminders());
    // 0.3.0：從提醒的「▶ 開始朗讀」按鈕開啟 App 時，直接開始巡航。
    if (_pendingStart || await NotificationService.launchedByStartAction()) {
      _pendingStart = false;
      unawaited(startCruise());
    }
  }

  /// 依照 settings.voiceId 重新把先前選定的語音套用到 TTS 引擎，
  /// 確保「語音測試/預覽」頁選好的語音，在 App 重開之後還是有效
  /// （不然選好的語音只會在當次執行期間生效）。
  Future<void> _applyVoiceIfNeeded() async {
    final voiceId = settings.voiceId;
    if (voiceId == null) return;
    try {
      final voices = await _ttsService.getVoices();
      final match = voices.firstWhere(
        (v) => v['name'] == voiceId,
        orElse: () => <String, String>{},
      );
      if (match.isNotEmpty) {
        await _ttsService.setVoice(match);
      }
    } catch (_) {
      // 找不到裝置上對應的語音（例如換了手機）就略過，改用系統預設語音。
    }
  }

  DatasetPlaybackState _rebuildPlaylist(
      WordDataset dataset, Set<int> starred) {
    final playlist = PlaylistBuilder.build(
      totalCount: dataset.items.length,
      starredIndices: starred,
      scopeMode: settings.scopeMode,
      allowedCount: unlockedCount(dataset),
    );
    return DatasetPlaybackState(playlist: playlist, currentStep: 0);
  }

  /// 看完一次獎勵廣告後呼叫：幫目前教材多解鎖 20 個項目（僅限本次使用階段）。
  Future<void> unlockMoreViaRewardedAd() async {
    final dataset = currentDataset;
    _sessionExtraUnlocked[dataset.id] =
        (_sessionExtraUnlocked[dataset.id] ?? 0) + _rewardedAdUnlockAmount;
    _playbackStates[dataset.id] = _rebuildPlaylist(dataset, currentStarred);
    await _persistCurrentProgress();
    notifyListeners();
  }

  Future<bool> purchasePremiumPackage(dynamic package) async {
    final packageId = _packageIdOf(package);
    AnalyticsService.purchaseStart(packageId);
    // Google Play 付款畫面會暫時離開 App，回來時不要跳開啟應用程式廣告。
    AdsService.skipNextAppOpenAd();
    final success = await SubscriptionService.purchase(package);
    if (success) {
      isPremium = true;
      AdsService.adsEnabled = false;
      AnalyticsService.purchaseSuccess(packageId);
      AnalyticsService.setUserProperties(isPremium: true);
      // 訂閱成功後，所有教材的播放清單都要重新建構成完整版（不再受限）。
      for (final dataset in datasets) {
        _playbackStates[dataset.id] =
            _rebuildPlaylist(dataset, _starredSets[dataset.id] ?? {});
      }
      notifyListeners();
    }
    return success;
  }

  static String _packageIdOf(dynamic package) {
    try {
      return package.identifier as String;
    } catch (_) {
      return 'unknown';
    }
  }

  /// 取得指定教材「已學習」（曾被朗讀過）的項目數，供學習統計畫面使用。
  Future<int> learnedCountForDataset(String datasetId) =>
      _statsRepository.learnedCountForDataset(datasetId);

  /// 匯入一份新的自訂教材：存檔、加進目前的教材清單，並幫它初始化
  /// 播放狀態（跟 initialize() 裡對內建教材做的事一樣）。
  Future<void> addCustomDataset(WordDataset dataset) async {
    await _customDatasetRepository.save(dataset);
    AnalyticsService.importCsv(dataset.items.length);
    datasets.add(dataset);
    _starredSets[dataset.id] = <int>{};
    _playbackStates[dataset.id] = _rebuildPlaylist(dataset, <int>{});
    notifyListeners();
  }

  /// 刪除一份自訂教材。如果使用者當下正切在這份教材上，會自動切回
  /// 第一份教材，避免畫面停留在一份已經不存在的教材上。
  Future<void> removeCustomDataset(String datasetId) async {
    await _customDatasetRepository.delete(datasetId);
    final removingCurrent = currentDataset.id == datasetId;
    datasets.removeWhere((d) => d.id == datasetId);
    _starredSets.remove(datasetId);
    _playbackStates.remove(datasetId);
    if (removingCurrent) {
      currentDatasetIndex = 0;
    } else if (currentDatasetIndex >= datasets.length) {
      currentDatasetIndex = datasets.length - 1;
    }
    notifyListeners();
  }

  Future<bool> restorePremium() async {
    AdsService.skipNextAppOpenAd();
    final restored = await SubscriptionService.restorePurchases();
    if (restored) {
      isPremium = true;
      AdsService.adsEnabled = false;
      AnalyticsService.setUserProperties(isPremium: true);
      for (final dataset in datasets) {
        _playbackStates[dataset.id] =
            _rebuildPlaylist(dataset, _starredSets[dataset.id] ?? {});
      }
      notifyListeners();
    }
    return restored;
  }

  /// 設定/更新每日複習提醒。enabled=false 時會取消排程。
  Future<void> setReminder({
    required bool enabled,
    required int hour,
    required int minute,
  }) async {
    reminderEnabled = enabled;
    reminderHour = hour;
    reminderMinute = minute;
    notifyListeners(); // 先更新畫面，避免使用者覺得沒反應；儲存/排程在背景繼續處理。

    await _progressRepository.saveReminderSettings(
        enabled: enabled, hour: hour, minute: minute);

    if (enabled) {
      // Android 13 以下沒有「通知權限」這個概念，requestPermission() 可能回傳
      // null/false，但這不代表不能排程通知——不能用這個結果來擋排程動作，
      // 否則舊版 Android 上提醒永遠不會生效。
      await NotificationService.requestPermission();
      // 精準鬧鐘權限：讓提醒準時跳出（小米等手機非精準排程常延遲或不觸發）。
      await NotificationService.requestExactAlarmIfNeeded();
      await NotificationService.scheduleDailyReminder(hour: hour, minute: minute);
    } else {
      await NotificationService.cancelReminder();
    }
  }

  void switchDataset(int index) {
    stopCruise();
    currentDatasetIndex = index;
    AnalyticsService.datasetSwitch(currentDataset.id);
    notifyListeners();
  }

  Future<void> updateSettings(PlaybackSettings newSettings) async {
    final scopeChanged = newSettings.scopeMode != settings.scopeMode;
    final voiceChanged = newSettings.voiceId != settings.voiceId;
    final rateChanged = newSettings.speechRate != settings.speechRate;
    final nowPlayingChanged =
        newSettings.showTranslation != settings.showTranslation;
    settings = newSettings;
    if (nowPlayingChanged) _updateNowPlaying();
    await _progressRepository.saveSettings(settings);
    if (voiceChanged) {
      await _applyVoiceIfNeeded();
    }
    if (rateChanged) {
      await _ttsService.setRate(settings.speechRate);
    }
    if (scopeChanged) {
      // 範圍模式改變時，該教材要重新建構播放清單。
      final dataset = currentDataset;
      _playbackStates[dataset.id] =
          _rebuildPlaylist(dataset, currentStarred);
      await _progressRepository.saveProgress(
          dataset.id, _playbackStates[dataset.id]!);
    }
    notifyListeners();
  }

  Future<void> toggleStarCurrent() async {
    final dataset = currentDataset;
    final state = currentPlaybackState;
    if (state.playlist.isEmpty) return;
    final idx = state.playlist[state.currentStep % state.playlist.length];

    final starred = Set<int>.from(currentStarred);
    if (starred.contains(idx)) {
      starred.remove(idx);
    } else {
      starred.add(idx);
      AnalyticsService.starWord(dataset.id);
    }
    _starredSets[dataset.id] = starred;
    await _progressRepository.saveStarred(dataset.id, starred);

    // 如果目前是「僅不熟悉」模式,拿掉星號後播放清單要重建。
    if (settings.scopeMode == ScopeMode.starredRandom ||
        settings.scopeMode == ScopeMode.starredSequential) {
      _playbackStates[dataset.id] = _rebuildPlaylist(dataset, starred);
      await _progressRepository.saveProgress(
          dataset.id, _playbackStates[dataset.id]!);
    }
    notifyListeners();
  }

  // --- V2 Practical English 相容掛勾（SPEC §3、§9.2）；不改變 V1 既有行為 ---

  /// 某份教材目前的 ★ index 集合（唯讀副本）。
  Set<int> starredIndexesFor(String datasetId) =>
      Set<int>.unmodifiable(_starredSets[datasetId] ?? const <int>{});

  /// Practical English 標記／取消弱字時寫回 V1 ★：與 [toggleStarCurrent]
  /// 相同的存檔與播放清單重建方式，key 與資料格式不變。
  Future<void> replaceStarredFromPracticalEnglish(
      String datasetId, Set<int> starred) async {
    final matches = datasets.where((d) => d.id == datasetId);
    if (matches.isEmpty) return;
    final dataset = matches.first;
    final updated = Set<int>.from(starred);
    _starredSets[dataset.id] = updated;
    await _progressRepository.saveStarred(dataset.id, updated);
    if (settings.scopeMode == ScopeMode.starredRandom ||
        settings.scopeMode == ScopeMode.starredSequential) {
      _playbackStates[dataset.id] = _rebuildPlaylist(dataset, updated);
      await _progressRepository.saveProgress(
          dataset.id, _playbackStates[dataset.id]!);
    }
    notifyListeners();
  }

  /// 這個項目實際要顯示/朗讀的翻譯語言。內建教材跟著介面語言，
  /// 自訂教材用匯入時選的語言；該語言還沒翻譯時退回中文。
  String meaningLocaleFor(WordItem word) {
    final preferred = currentDataset.builtIn
        ? BackgroundL10n.translationKey()
        : currentDataset.primaryLocale;
    return word.resolveLocale(preferred);
  }

  /// 英文介面（含不支援語言）下，內建教材沒有對應翻譯，不顯示也不朗讀翻譯
  /// （不能退回中文給英文介面的使用者看）。
  ///
  /// 第 11 版起改為逐項判斷：非中文介面（泰、阿…）若某個內建項目還沒有
  /// 該語言翻譯，也不顯示、不朗讀（不退回中文），讓教材翻譯可以分批補齊。
  bool _hideBuiltInTranslationFor(WordItem word) {
    if (!currentDataset.builtIn) return false;
    final key = BackgroundL10n.translationKey();
    if (key == 'en') return true;
    return !key.startsWith('zh') && !word.translations.containsKey(key);
  }

  /// 右到左書寫的語言（阿拉伯文等）。單字卡依「內容的語言」決定文字方向，
  /// 不是依介面語言：阿拉伯文介面下英文單字仍左到右，中文介面下匯入的
  /// 阿拉伯文翻譯仍右到左（標點與括號位置才會正確）。
  static bool isRtlLanguage(String code) {
    final lang = code.split(RegExp('[-_]')).first.toLowerCase();
    return const {'ar', 'he', 'iw', 'fa', 'ur'}.contains(lang);
  }

  bool get wordIsRtl => isRtlLanguage(currentDataset.wordLocale);

  bool meaningIsRtl(WordItem word) => isRtlLanguage(meaningLocaleFor(word));

  /// 手機是否有這個語言的朗讀語音（匯入畫面用）。
  Future<bool> isTtsLanguageAvailable(String languageCode) =>
      _ttsService.isLanguageAvailable(languageCode);

  String meaningOf(WordItem word) =>
      _hideBuiltInTranslationFor(word) ? '' : word.meaningFor(meaningLocaleFor(word));

  /// 同步目前單字/播放狀態到鎖屏與通知列顯示（背景播放時看得到）。
  /// 0.3.1：封面是固定的無字綠底（見 CoverArt.lockScreen）。
  /// 連續快速換字時只送最後一次（世代編號比對），避免舊字蓋掉新字。
  int _nowPlayingGen = 0;

  void _updateNowPlaying() {
    final word = currentWord;
    if (word == null || _audioHandler == null) return;
    final gen = ++_nowPlayingGen;
    final state = currentPlaybackState;
    final meaning = settings.showTranslation ? meaningOf(word) : '';
    final index = state.playlist.isEmpty ? 0 : state.currentStep + 1;
    final total = state.playlist.length;
    final playing = isPlaying;

    void push(Uri? art) {
      if (gen != _nowPlayingGen) return;
      _audioHandler?.updateNowPlaying(
        word: word.word,
        meaning: meaning,
        playing: playing,
        currentIndex: index,
        totalCount: total,
        artUri: art,
      );
    }

    _scheduleReminderRefresh();
    CoverArt.lockScreen()
        .timeout(const Duration(seconds: 2))
        .then(push, onError: (_) => push(null));
  }

  Future<void> _persistCurrentProgress() async {
    final dataset = currentDataset;
    await _progressRepository.saveProgress(
        dataset.id, _playbackStates[dataset.id]!);
  }

  /// [fromCruise] 只給巡航自動播放迴圈內部呼叫使用。使用者手動按「下一個」
  /// 時會先暫停巡航（避免跟自動播放的計時器同時搶著推進進度，
  /// 導致偶爾跳兩個單字、或巡航按鈕狀態跟實際播放狀況對不起來）。
  Future<void> next({bool speak = true, bool fromCruise = false}) async {
    if (!fromCruise && isPlaying) {
      stopCruise();
    }
    final dataset = currentDataset;
    var state = currentPlaybackState;
    if (state.playlist.isEmpty) return;
    var nextStep = state.currentStep + 1;
    var cycleCount = state.cycleCount;
    var cycleCompleted = false;
    if (nextStep >= state.playlist.length) {
      nextStep = 0;
      cycleCount += 1;
      cycleCompleted = true;
      // 每輪播完重新洗牌（若是隨機模式）。
      final reshuffled = _rebuildPlaylist(dataset, currentStarred);
      state = reshuffled.copyWith(currentStep: 0, cycleCount: cycleCount);
    } else {
      state = state.copyWith(currentStep: nextStep);
    }
    _playbackStates[dataset.id] = state;
    await _persistCurrentProgress();
    _updateNowPlaying();
    notifyListeners();
    if (cycleCompleted) {
      AnalyticsService.roundComplete(dataset.id, cycleCount);
      if (!isPremium) {
        // 免費版：每輪播完一次插頁廣告。App 在前景才會立刻顯示；
        // 鎖屏/背景收聽時先記下，等使用者回到 App 再顯示（AdMob 政策）。
        AdsService.onRoundComplete();
      }
    }
    if (speak) await _speakCurrent();
  }

  Future<void> previous({bool speak = true}) async {
    if (isPlaying) {
      stopCruise();
    }
    final dataset = currentDataset;
    final state = currentPlaybackState;
    if (state.playlist.isEmpty) return;
    final prevStep =
        (state.currentStep - 1 + state.playlist.length) % state.playlist.length;
    _playbackStates[dataset.id] = state.copyWith(currentStep: prevStep);
    await _persistCurrentProgress();
    _updateNowPlaying();
    notifyListeners();
    if (speak) await _speakCurrent();
  }

  Future<void> jumpTo(int oneBasedNumber) async {
    if (isPlaying) stopCruise();
    final dataset = currentDataset;
    final state = currentPlaybackState;
    final targetIndex = oneBasedNumber - 1;
    final maxAllowed = unlockedCount(dataset);
    if (targetIndex < 0 || targetIndex >= maxAllowed) return;
    final posInPlaylist = state.playlist.indexOf(targetIndex);
    final step = posInPlaylist >= 0 ? posInPlaylist : 0;
    _playbackStates[dataset.id] = state.copyWith(currentStep: step);
    await _persistCurrentProgress();
    _updateNowPlaying();
    notifyListeners();
    await _speakCurrent();
  }

  Future<void> replay() async {
    if (isPlaying) stopCruise();
    await _speakCurrent();
  }

  Future<void> _speakCurrent() async {
    final gen = ++_speakGen;
    // V2 正在朗讀時先停止 V2；V1 已是擁有者時不等待（時序與原本相同）。
    if (!playbackCoordinator.isCurrent(_v1Lease)) {
      final lease = await playbackCoordinator.claim(PlaybackOwner.v1);
      if (!playbackCoordinator.isCurrent(lease)) return;
      _v1Lease = lease;
      if (gen != _speakGen) return;
    }
    // 上一個單字還在念（手動快速切換）：先確實停止，再念新的。
    if (_speechActive) {
      await _ttsService.stop();
      if (gen != _speakGen) return;
    }
    final word = currentWord;
    if (word == null) return;
    _speechActive = true;
    try {
      await _speakWord(word, gen);
    } finally {
      if (gen == _speakGen) {
        _speechActive = false;
        if (!isPlaying) _releaseV1Playback();
      }
    }
  }

  Future<void> _speakWord(WordItem word, int gen) async {
    for (var i = 0; i < settings.repeatCount; i++) {
      // 第一欄語言：內建教材固定英文；自訂教材依匯入時選的語言朗讀。
      await _ttsService.speak(word.word,
          languageCode: currentDataset.wordLocale);
      if (gen != _speakGen) return;
    }
    if (settings.readMode == ReadMode.bilingual &&
        !_hideBuiltInTranslationFor(word)) {
      final locale = meaningLocaleFor(word);
      // 「〜」「~」「…」是釋義裡的占位符號，部分 TTS 引擎會把它念成
      // 「から」「물결」之類的字，朗讀前先拿掉（畫面顯示不受影響）。
      final spoken = word
          .meaningFor(locale)
          .replaceAll(RegExp(r'[〜～~…]'), ' ')
          .trim();
      if (spoken.isNotEmpty) {
        await _ttsService.speak(spoken, languageCode: locale);
        if (gen != _speakGen) return;
      }
    }
    final state = currentPlaybackState;
    if (state.playlist.isNotEmpty) {
      final idx = state.playlist[state.currentStep % state.playlist.length];
      stats = await _statsRepository.markLearned(currentDataset.id, idx);
      notifyListeners();
    }
  }

  Future<void> togglePlay() async {
    if (isPlaying) {
      stopCruise();
    } else {
      await startCruise();
    }
  }

  Future<void> startCruise() async {
    if (isPlaying) return;
    isPlaying = true;
    AnalyticsService.playStart(currentDataset.id);
    _updateNowPlaying();
    notifyListeners();
    await _cruiseLoop();
  }

  void stopCruise() {
    isPlaying = false;
    _cruiseGen++;
    _speakGen++; // 讓正在進行的朗讀流程不再接著念重複/翻譯
    _speechActive = false;
    _cruiseTimer?.cancel();
    _ttsService.stop();
    _releaseV1Playback();
    _updateNowPlaying();
    notifyListeners();
  }

  Future<void> _cruiseLoop() async {
    final gen = ++_cruiseGen;
    bool alive() => isPlaying && gen == _cruiseGen;
    while (alive()) {
      await _speakCurrent();
      if (!alive()) break;
      await Future.delayed(
          Duration(milliseconds: (settings.intervalSeconds * 1000).round()));
      if (!alive()) break;
      await next(speak: false, fromCruise: true);
    }
  }

  @override
  void dispose() {
    NotificationService.startRequests.removeListener(_onStartRequest);
    _reminderDebounce?.cancel();
    _cruiseTimer?.cancel();
    super.dispose();
  }
}
