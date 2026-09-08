import 'dart:math';
import '../models/playback_settings.dart';

/// 核心播放邏輯：洗牌演算法 + 依照範圍模式建構播放清單。
/// 這一層完全不依賴 Flutter / Firebase / TTS，方便未來測試與替換底層技術。
class PlaylistBuilder {
  static final Random _random = Random();

  /// Fisher-Yates 洗牌，對應原網頁版的隨機播放邏輯。
  static List<int> shuffle(List<int> indices) {
    final list = List<int>.from(indices);
    for (var i = list.length - 1; i > 0; i--) {
      final j = _random.nextInt(i + 1);
      final tmp = list[i];
      list[i] = list[j];
      list[j] = tmp;
    }
    return list;
  }

  /// 依照範圍模式（全部/僅不熟悉 × 隨機/依序）建構播放清單。
  /// [totalCount] 是該教材的總項目數。
  /// [starredIndices] 是該教材目前被標記「不熟悉」的 index 集合。
  static List<int> build({
    required int totalCount,
    required Set<int> starredIndices,
    required ScopeMode scopeMode,
  }) {
    List<int> base;
    switch (scopeMode) {
      case ScopeMode.allRandom:
      case ScopeMode.allSequential:
        base = List<int>.generate(totalCount, (i) => i);
        break;
      case ScopeMode.starredRandom:
      case ScopeMode.starredSequential:
        base = starredIndices.toList()..sort();
        break;
    }

    final isRandom = scopeMode == ScopeMode.allRandom ||
        scopeMode == ScopeMode.starredRandom;

    return isRandom ? shuffle(base) : base;
  }
}
