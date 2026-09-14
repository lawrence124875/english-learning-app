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

/// App 的核心狀態管理，整合資料層與播放邏輯，供 UI 層使用。
class AppState extends ChangeNotifier {
  final WordRepository _wordRepository;
  final ProgressRepository _progressRepository;
  final TtsService _ttsService;
  final TtsAudioHandler? _audioHandler;

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
  }

  List<WordDataset> datasets = [];
  int currentDatasetIndex = 0;
  PlaybackSettings settings = const PlaybackSettings();

  final Map<String, DatasetPlaybackState> _playbackStates = {};
  final Map<String, Set<int>> _starredSets = {};

  bool isPlaying = false;
  bool isLoading = true;
  Timer? _cruiseTimer;

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

  WordItem? get currentWord {
    final state = currentPlaybackState;
    if (state.playlist.isEmpty) return null;
    final idx = state.playlist[state.currentStep % state.playlist.length];
    return currentDataset.items[idx];
  }

  double get progressRatio {
    final state = currentPlaybackState;
    if (state.playlist.isEmpty) return 0;
    return (state.currentStep + 1) / state.playlist.length;
  }

  Future<void> initialize() async {
    isLoading = true;
    notifyListeners();

    isPremium = await SubscriptionService.isPremium();
    datasets = await _wordRepository.loadAllDatasets();
    settings = await _progressRepository.loadSettings();

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
    final success = await SubscriptionService.purchase(package);
    if (success) {
      isPremium = true;
      // 訂閱成功後，所有教材的播放清單都要重新建構成完整版（不再受限）。
      for (final dataset in datasets) {
        _playbackStates[dataset.id] =
            _rebuildPlaylist(dataset, _starredSets[dataset.id] ?? {});
      }
      notifyListeners();
    }
    return success;
  }

  Future<bool> restorePremium() async {
    final restored = await SubscriptionService.restorePurchases();
    if (restored) {
      isPremium = true;
      for (final dataset in datasets) {
        _playbackStates[dataset.id] =
            _rebuildPlaylist(dataset, _starredSets[dataset.id] ?? {});
      }
      notifyListeners();
    }
    return restored;
  }

  void switchDataset(int index) {
    stopCruise();
    currentDatasetIndex = index;
    notifyListeners();
  }

  Future<void> updateSettings(PlaybackSettings newSettings) async {
    final scopeChanged = newSettings.scopeMode != settings.scopeMode;
    settings = newSettings;
    await _progressRepository.saveSettings(settings);
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

  /// 同步目前單字/播放狀態到鎖屏與通知列顯示（背景播放時看得到）。
  void _updateNowPlaying() {
    final word = currentWord;
    if (word == null || _audioHandler == null) return;
    final state = currentPlaybackState;
    _audioHandler?.updateNowPlaying(
      word: word.word,
      meaning: settings.showTranslation ? word.meaningFor('zh-TW') : '',
      playing: isPlaying,
      currentIndex: state.playlist.isEmpty ? 0 : state.currentStep + 1,
      totalCount: state.playlist.length,
    );
  }

  Future<void> _persistCurrentProgress() async {
    final dataset = currentDataset;
    await _progressRepository.saveProgress(
        dataset.id, _playbackStates[dataset.id]!);
  }

  Future<void> next({bool speak = true}) async {
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
    if (cycleCompleted && !isPremium) {
      // 免費版：每輪播完顯示一次插頁廣告。失敗也不影響正常播放。
      AdsService.showInterstitialAd();
    }
    if (speak) await _speakCurrent();
  }

  Future<void> previous({bool speak = true}) async {
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

  Future<void> replay() => _speakCurrent();

  Future<void> _speakCurrent() async {
    final word = currentWord;
    if (word == null) return;
    for (var i = 0; i < settings.repeatCount; i++) {
      await _ttsService.speak(word.word, languageCode: 'en-US');
    }
    if (settings.readMode == ReadMode.bilingual) {
      await _ttsService.speak(word.meaningFor('zh-TW'),
          languageCode: 'zh-TW');
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
    isPlaying = true;
    _updateNowPlaying();
    notifyListeners();
    await _cruiseLoop();
  }

  void stopCruise() {
    isPlaying = false;
    _cruiseTimer?.cancel();
    _ttsService.stop();
    _updateNowPlaying();
    notifyListeners();
  }

  Future<void> _cruiseLoop() async {
    while (isPlaying) {
      await _speakCurrent();
      if (!isPlaying) break;
      await Future.delayed(
          Duration(milliseconds: (settings.intervalSeconds * 1000).round()));
      if (!isPlaying) break;
      await next(speak: false);
    }
  }

  @override
  void dispose() {
    _cruiseTimer?.cancel();
    super.dispose();
  }
}
