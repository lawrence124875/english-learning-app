import 'package:audio_service/audio_service.dart';
import 'background_l10n.dart';

/// 背景播放/鎖屏控制的 Handler。
/// 實際的播放邏輯（洗牌、播放清單、TTS）仍在 AppState 裡，
/// 這裡只負責：(1) 讓系統知道 App 正在播放音訊，維持前景服務不被砍掉，
/// (2) 更新鎖屏/通知列顯示的「目前單字＋中文意思」，
/// (3) 接收鎖屏上的play/pause/上一個/下一個按鈕，轉發給 AppState。
class TtsAudioHandler extends BaseAudioHandler {
  /// 由 AppState 在初始化時綁定，避免建構時的循環依賴。
  Future<void> Function()? onPlay;
  Future<void> Function()? onPause;
  Future<void> Function()? onSkipNext;
  Future<void> Function()? onSkipPrevious;

  void bindCallbacks({
    required Future<void> Function() onPlay,
    required Future<void> Function() onPause,
    required Future<void> Function() onSkipNext,
    required Future<void> Function() onSkipPrevious,
  }) {
    this.onPlay = onPlay;
    this.onPause = onPause;
    this.onSkipNext = onSkipNext;
    this.onSkipPrevious = onSkipPrevious;
  }

  /// AppState 每次切到新單字，或播放狀態改變時呼叫這個方法，
  /// 更新鎖屏/通知列顯示內容（類似音樂 App 顯示歌名/歌手）。
  void updateNowPlaying({
    required String word,
    required String meaning,
    required bool playing,
    required int currentIndex,
    required int totalCount,
    Uri? artUri,
  }) {
    // V2：實用英文接管鎖屏時，V1 的更新只記下來，交還時再套用。
    _v1NowPlaying = () => updateNowPlaying(
          word: word,
          meaning: meaning,
          playing: playing,
          currentIndex: currentIndex,
          totalCount: totalCount,
          artUri: artUri,
        );
    if (_override != null) return;
    _publish(
      id: word,
      title: word,
      artist: meaning,
      playing: playing,
      currentIndex: currentIndex,
      totalCount: totalCount,
      artUri: artUri,
    );
  }

  /// 送出鎖屏／通知列內容（V1 與 V2 共用）。
  void _publish({
    required String id,
    required String title,
    required String artist,
    required bool playing,
    required int currentIndex,
    required int totalCount,
    Uri? artUri,
  }) {
    // 0.3.1：已 stop()（App 被滑掉）就不再更新。封面圖是非同步取得，
    // 停止過程中觸發的更新會晚於 idle 送出，把狀態改回 ready，
    // 前景服務與卡片就收不掉（0.3.0 起紅米實機：滑掉 App 通知沒消失）。
    // 之後重新開始朗讀（playing=true）才恢復。
    if (_stopped && !playing) return;
    _stopped = false;
    mediaItem.add(MediaItem(
      id: id,
      title: title,
      artist: artist,
      album:
          '${BackgroundL10n.current().appTitle} ($currentIndex / $totalCount)',
      // 0.3.0：大字封面圖（設定可關閉；null＝一般小字卡片）。
      artUri: artUri,
    ));
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        playing ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
      ],
      // 0.3.0：精簡檢視（小米等鎖屏只顯示精簡按鈕）也放上一個／下一個。
      androidCompactActionIndices: const [0, 1, 2],
      systemActions: const {
        MediaAction.skipToPrevious,
        MediaAction.skipToNext,
        MediaAction.play,
        MediaAction.pause,
      },
      playing: playing,
      processingState: AudioProcessingState.ready,
    ));
  }

  bool _stopped = false;

  // ---------------- V2：實用英文暫時接管鎖屏 ----------------

  NowPlayingOverride? _override;
  void Function()? _v1NowPlaying;

  /// 目前是否由 [owner] 接管鎖屏。
  bool isOverriddenBy(Object owner) => _override?.owner == owner;

  /// 實用英文句子播放時接管鎖屏按鈕與顯示內容。V1 的顯示更新會先記下，
  /// [releaseOverride] 時再套回；沒有接管時 V1 行為完全不變。
  void setOverride(NowPlayingOverride value) => _override = value;

  /// 顯示接管者的目前句子；不是目前接管者就忽略（晚到的更新）。
  void updateOverrideNowPlaying(
    Object owner, {
    required String id,
    required String title,
    required String subtitle,
    required bool playing,
    required int currentIndex,
    required int totalCount,
    Uri? artUri,
  }) {
    if (_override?.owner != owner) return;
    _publish(
      id: id,
      title: title,
      artist: subtitle,
      playing: playing,
      currentIndex: currentIndex,
      totalCount: totalCount,
      artUri: artUri,
    );
  }

  /// 交還鎖屏給 V1：套回 V1 最後一次的內容；V1 從沒顯示過就收掉卡片。
  void releaseOverride(Object owner) {
    if (_override?.owner != owner) return;
    _override = null;
    final v1 = _v1NowPlaying;
    if (v1 != null) {
      v1();
    } else {
      playbackState.add(playbackState.value.copyWith(
        playing: false,
        processingState: AudioProcessingState.idle,
      ));
    }
  }

  @override
  Future<void> play() async {
    _stopped = false;
    final o = _override;
    await (o != null ? o.onPlay() : onPlay?.call());
  }

  @override
  Future<void> pause() async {
    final o = _override;
    await (o != null ? o.onPause() : onPause?.call());
  }

  @override
  Future<void> skipToNext() async {
    final o = _override;
    await (o != null ? o.onSkipNext() : onSkipNext?.call());
  }

  @override
  Future<void> skipToPrevious() async {
    final o = _override;
    await (o != null ? o.onSkipPrevious() : onSkipPrevious?.call());
  }

  @override
  Future<void> stop() async {
    _stopped = true;
    // 第十七版：停止朗讀若出錯或卡住，也一定要送出 idle，
    // 否則原生端不會結束服務、收掉通知與鎖屏卡片。
    try {
      await _override?.onPause().timeout(const Duration(seconds: 2));
    } catch (_) {}
    try {
      await onPause?.call().timeout(const Duration(seconds: 2));
    } catch (_) {}
    playbackState.add(playbackState.value.copyWith(
      playing: false,
      processingState: AudioProcessingState.idle,
    ));
  }

  /// 使用者把 App 從「最近使用列表」整個滑掉時，Android 會呼叫這個
  /// 方法。之前沒有覆寫這個方法，導致背景播放的前景服務、鎖屏/通知列
  /// 的媒體控制卡片，在使用者關閉 App 後仍然會殘留在畫面上不會消失。
  /// 呼叫 stop() 讓處理狀態變成 idle，系統才會正確停止前景服務、
  /// 收掉通知與鎖屏卡片。
  @override
  Future<void> onTaskRemoved() async {
    await stop();
  }
}

/// 接管鎖屏時的按鈕處理（V2 實用英文句子播放）。
class NowPlayingOverride {
  final Object owner;
  final Future<void> Function() onPlay;
  final Future<void> Function() onPause;
  final Future<void> Function() onSkipNext;
  final Future<void> Function() onSkipPrevious;

  const NowPlayingOverride({
    required this.owner,
    required this.onPlay,
    required this.onPause,
    required this.onSkipNext,
    required this.onSkipPrevious,
  });
}
