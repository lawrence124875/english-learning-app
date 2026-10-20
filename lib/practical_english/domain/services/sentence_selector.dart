import '../models/sentence.dart';
import '../models/word_learning_state.dart';

/// 學習模式（SPEC §9.4）。
enum LearningMode { all, weakPriority, weakOnly }

/// 單字學習狀態（SPEC §9.1，依序第一個符合者勝出）。
enum WordStatus { unseen, seen, learning, weak, mastered }

WordStatus deriveWordStatus(WordLearningState s) {
  if (s.mastered) return WordStatus.mastered;
  if (s.weak) return WordStatus.weak;
  if (s.peExposureCount > 0) return WordStatus.learning;
  if (s.exposedInV1) return WordStatus.seen;
  return WordStatus.unseen;
}

/// 確定性的選句與排序（SPEC §9.4）。沒有隨機、沒有 AI。
///
/// 分數＝3 ×（句中弱字數）＋ 1 ×（句中 unseen／seen／learning 字數），
/// mastered 的字不加分。主要詞與次要詞都計入（每個 WordRef 一次，SPEC §9.4）；
/// [isKnown] 回傳 false 的參照（無法對應）不計。同分時：句子「最近一次練習時間」較舊者優先
/// （從未練習＝最舊），再依句子 ID。句子的練習時間取句中各字
/// lastPracticedAt 的最大值（練習一句時句中所有字會同時更新）。
class SentenceSelector {
  SentenceSelector._();

  static bool _always(String ref) => true;

  static Iterable<String> _scoredRefs(
          Sentence sentence, bool Function(String ref) isKnown) =>
      sentence.allWordIds.where(isKnown);

  static int score(
      Sentence sentence, WordLearningState Function(String ref) stateOf,
      {bool Function(String ref) isKnown = _always}) {
    var total = 0;
    for (final ref in _scoredRefs(sentence, isKnown)) {
      switch (deriveWordStatus(stateOf(ref))) {
        case WordStatus.weak:
          total += 3;
        case WordStatus.unseen:
        case WordStatus.seen:
        case WordStatus.learning:
          total += 1;
        case WordStatus.mastered:
          break;
      }
    }
    return total;
  }

  static int weakCount(
          Sentence sentence, WordLearningState Function(String ref) stateOf,
          {bool Function(String ref) isKnown = _always}) =>
      _scoredRefs(sentence, isKnown).where((r) => stateOf(r).weak).length;

  static DateTime? lastPracticed(
      Sentence sentence, WordLearningState Function(String ref) stateOf) {
    DateTime? latest;
    for (final ref in sentence.wordIds) {
      final t = stateOf(ref).lastPracticedAt;
      if (t != null && (latest == null || t.isAfter(latest))) latest = t;
    }
    return latest;
  }

  /// 依模式排序／篩選。[candidates] 應已套用權限過濾，順序為原始句子順序
  /// （內建在前、匯入在後），「全部」模式直接沿用這個順序。
  static List<Sentence> order(
    List<Sentence> candidates,
    LearningMode mode,
    WordLearningState Function(String ref) stateOf, {
    bool Function(String ref) isKnown = _always,
  }) {
    if (mode == LearningMode.all) return List.unmodifiable(candidates);

    final pool = mode == LearningMode.weakOnly
        ? candidates
            .where((s) => weakCount(s, stateOf, isKnown: isKnown) > 0)
            .toList()
        : List<Sentence>.of(candidates);

    final scores = {
      for (final s in pool) s.id: score(s, stateOf, isKnown: isKnown)
    };
    final times = {for (final s in pool) s.id: lastPracticed(s, stateOf)};
    pool.sort((a, b) {
      final byScore = scores[b.id]!.compareTo(scores[a.id]!);
      if (byScore != 0) return byScore;
      final ta = times[a.id], tb = times[b.id];
      if (ta != tb) {
        if (ta == null) return -1;
        if (tb == null) return 1;
        final byTime = ta.compareTo(tb);
        if (byTime != 0) return byTime;
      }
      return a.id.compareTo(b.id);
    });
    return List.unmodifiable(pool);
  }
}
