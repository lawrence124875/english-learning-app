import '../models/sentence.dart';
import '../models/word_learning_state.dart';
import 'sentence_access.dart';
import 'sentence_selector.dart';
import 'word_ref_index.dart';

/// Practical English 學習覆蓋與進度（SPEC §9.5）。
///
/// 單字一律以 canonical WordRef 計算，一句含多個字也不會重複計算。
/// 「句子覆蓋」與「單字覆蓋」分開：
/// - Sentence Coverage：可學的句子數／所有可對應的句子數。
/// - Word Coverage：至少有一句可對應句子的單字數／全部單字數。
class PracticalEnglishCoverage {
  /// 全部單字數（內建 4,185 ＋ 自訂教材）。
  final int totalWords;

  /// 至少有一句句子的單字數（不論是否鎖住）。
  final int wordsWithSentences;

  /// 各狀態的單字數（互斥，加總＝totalWords）。
  final Map<WordStatus, int> statusCounts;

  /// 在 Practical English 練習過的單字數（peExposureCount > 0，含之後被標弱字或精熟者）。
  final int practicedWords;

  /// 所有可對應的句子數。
  final int totalSentences;

  /// 目前權限下可學的句子數。
  final int accessibleSentences;

  const PracticalEnglishCoverage({
    required this.totalWords,
    required this.wordsWithSentences,
    required this.statusCounts,
    required this.practicedWords,
    required this.totalSentences,
    required this.accessibleSentences,
  });

  int count(WordStatus status) => statusCounts[status] ?? 0;

  /// 已接觸（看過或練習過，但不是弱字也還沒精熟）。
  int get exposedWords => count(WordStatus.seen) + count(WordStatus.learning);

  int get lockedSentences => totalSentences - accessibleSentences;

  static PracticalEnglishCoverage compute({
    required WordRefIndex index,
    required Iterable<Sentence> sentences,
    required SentenceAccess access,
    required WordLearningState Function(String ref) stateOf,
  }) {
    final covered = <String>{};
    var total = 0, accessible = 0;
    for (final s in sentences) {
      if (!access.isResolvable(s)) continue;
      total++;
      if (access.isAccessible(s)) accessible++;
      covered.addAll(s.wordIds);
    }
    final counts = {for (final st in WordStatus.values) st: 0};
    var practiced = 0;
    for (final ref in index.refs) {
      final state = stateOf(ref);
      counts[deriveWordStatus(state)] = counts[deriveWordStatus(state)]! + 1;
      if (state.peExposureCount > 0) practiced++;
    }
    return PracticalEnglishCoverage(
      totalWords: index.length,
      wordsWithSentences: covered.length,
      statusCounts: counts,
      practicedWords: practiced,
      totalSentences: total,
      accessibleSentences: accessible,
    );
  }
}
