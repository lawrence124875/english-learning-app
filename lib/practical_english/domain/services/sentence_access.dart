import '../../../domain/models/word_item.dart';
import '../models/sentence.dart';
import 'word_ref_index.dart';

/// 句子的使用權限（SPEC §12，2026-10-08 正式產品規則）。
///
/// - 句中任何一個 WordRef 無法對應（例如自訂教材已刪除）→ 不顯示。
/// - 免費版：句中**所有** target words 都在該教材的 V1 免費解鎖範圍內
///   （index < unlockedCount）才可顯示／學習。
/// - Premium：所有可對應的句子都可用（unlockedCount 回傳整份教材長度）。
///
/// [unlockedCountOf] 直接使用 V1 `AppState.unlockedCount`，不另訂規則。
class SentenceAccess {
  final WordRefIndex _index;
  final int Function(WordDataset dataset) _unlockedCountOf;

  SentenceAccess(this._index, this._unlockedCountOf);

  bool isResolvable(Sentence sentence) =>
      sentence.wordIds.every((ref) => _index.contains(ref));

  bool isWordUnlocked(String ref) {
    final location = _index.resolve(ref);
    if (location == null) return false;
    return location.index < _unlockedCountOf(location.dataset);
  }

  bool isAccessible(Sentence sentence) =>
      sentence.wordIds.isNotEmpty && sentence.wordIds.every(isWordUnlocked);

  /// 可對應但因免費版限制而鎖住的句子。
  bool isLocked(Sentence sentence) =>
      isResolvable(sentence) && !isAccessible(sentence);
}
