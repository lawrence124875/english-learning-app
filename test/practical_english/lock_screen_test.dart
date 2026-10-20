import 'package:audio_service/audio_service.dart';
import 'package:english_learning_app/data/sources/tts_audio_handler.dart';
import 'package:flutter_test/flutter_test.dart';

/// C3：V2 句子播放暫時接管鎖屏。沒有接管時 V1 行為不變（回歸）。
void main() {
  late TtsAudioHandler h;
  late List<String> calls;

  setUp(() {
    h = TtsAudioHandler();
    calls = [];
    h.bindCallbacks(
      onPlay: () async => calls.add('v1:play'),
      onPause: () async => calls.add('v1:pause'),
      onSkipNext: () async => calls.add('v1:next'),
      onSkipPrevious: () async => calls.add('v1:prev'),
    );
  });

  void v1Show(String word, {bool playing = true}) => h.updateNowPlaying(
      word: word,
      meaning: 'm',
      playing: playing,
      currentIndex: 1,
      totalCount: 9);

  NowPlayingOverride override(Object owner) => NowPlayingOverride(
        owner: owner,
        onPlay: () async => calls.add('v2:play'),
        onPause: () async => calls.add('v2:pause'),
        onSkipNext: () async => calls.add('v2:next'),
        onSkipPrevious: () async => calls.add('v2:prev'),
      );

  void v2Show(Object owner, String title, {bool playing = true}) =>
      h.updateOverrideNowPlaying(owner,
          id: title,
          title: title,
          subtitle: '譯',
          playing: playing,
          currentIndex: 2,
          totalCount: 5);

  test('V1 regression: no override → buttons and card are V1', () async {
    v1Show('apple');
    expect(h.mediaItem.value?.title, 'apple');
    expect(h.playbackState.value.playing, isTrue);
    await h.play();
    await h.pause();
    await h.skipToNext();
    await h.skipToPrevious();
    expect(calls, ['v1:play', 'v1:pause', 'v1:next', 'v1:prev']);
  });

  test('override routes buttons to V2 and hides V1 updates', () async {
    v1Show('apple', playing: false);
    final owner = Object();
    h.setOverride(override(owner));
    v2Show(owner, 'I missed the train.');
    v1Show('banana', playing: false); // V1 stopCruise 晚到的更新
    expect(h.mediaItem.value?.title, 'I missed the train.');
    expect(h.mediaItem.value?.artist, '譯');
    await h.play();
    await h.pause();
    await h.skipToNext();
    await h.skipToPrevious();
    expect(calls, ['v2:play', 'v2:pause', 'v2:next', 'v2:prev']);
  });

  test('release restores the latest V1 card and V1 buttons', () async {
    v1Show('apple', playing: false);
    final owner = Object();
    h.setOverride(override(owner));
    v2Show(owner, 'S');
    v1Show('banana', playing: true);
    h.releaseOverride(owner);
    expect(h.mediaItem.value?.title, 'banana');
    expect(h.playbackState.value.playing, isTrue);
    await h.skipToNext();
    expect(calls, ['v1:next']);
  });

  test('release without any V1 card goes idle (card removed)', () {
    final owner = Object();
    h.setOverride(override(owner));
    v2Show(owner, 'S');
    expect(h.playbackState.value.processingState, AudioProcessingState.ready);
    h.releaseOverride(owner);
    expect(h.playbackState.value.processingState, AudioProcessingState.idle);
    expect(h.playbackState.value.playing, isFalse);
  });

  test('stale owner cannot update or release', () {
    final old = Object();
    final fresh = Object();
    h.setOverride(override(old));
    h.setOverride(override(fresh));
    v2Show(old, 'old');
    v2Show(fresh, 'new');
    h.releaseOverride(old);
    expect(h.isOverriddenBy(fresh), isTrue);
    expect(h.mediaItem.value?.title, 'new');
  });

  test('stop (app swiped away) pauses V2 and V1, card goes idle', () async {
    final owner = Object();
    h.setOverride(override(owner));
    v2Show(owner, 'S');
    await h.stop();
    expect(calls, ['v2:pause', 'v1:pause']);
    expect(h.playbackState.value.processingState, AudioProcessingState.idle);
  });
}
