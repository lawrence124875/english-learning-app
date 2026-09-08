import 'package:audio_service/audio_service.dart';

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
  }) {
    mediaItem.add(MediaItem(
      id: word,
      title: word,
      artist: meaning,
      album: '智慧聽覺巡航（$currentIndex / $totalCount）',
    ));
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        playing ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
      ],
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

  @override
  Future<void> play() async => onPlay?.call();

  @override
  Future<void> pause() async => onPause?.call();

  @override
  Future<void> skipToNext() async => onSkipNext?.call();

  @override
  Future<void> skipToPrevious() async => onSkipPrevious?.call();

  @override
  Future<void> stop() async {
    await onPause?.call();
    playbackState.add(playbackState.value.copyWith(
      playing: false,
      processingState: AudioProcessingState.idle,
    ));
  }
}
