import '../../../domain/models/word_item.dart';
import '../models/sentence.dart';
import 'word_ref_index.dart';

/// 句子的使用權限（SPEC §4、§12，2026-10-09 正式產品規則 A）。
///
/// - 只看主要詞 `wordIds`；次要詞 `secondaryWordIds` 不影響權限。
/// - 指向已刪除自訂教材的 WordRef 會被忽略：只要句子還有可對應的主要詞，
///   就只依可對應的部分判斷（重新匯入教材與句子後可以恢復）。
/// - 其他無法對應的 WordRef（未知的內建 ID、教材還在但單字不在）→ 不顯示。
/// - 免費版：句子的每個**目標詞彙**都已解鎖才可顯示／學習。
///   同一個目標詞彙可能透過多個 WordRef 連到不同教材（SPEC §4，內容製作時
///   把經詞義確認的同拼字內建項目列進 `wordIds`）；只要其中任一個 WordRef
///   在它的教材解鎖範圍內（index < unlockedCount），這個詞彙就算已解鎖。
/// - 「同一個目標詞彙」只在這句自己的 `wordIds` 之內判斷：對應到的單字原文
///   （同一種原文語言、忽略大小寫與前後空白）相同的 WordRef 視為同一個詞彙。
///   不會因此連到 `wordIds` 以外的項目。
/// - Premium：所有可對應的句子都可用（unlockedCount 回傳整份教材長度）。
///
/// [unlockedCountOf] 直接使用 V1 `AppState.unlockedCount`，不另訂規則。
class SentenceAccess {
  final WordRefIndex _index;
  final int Function(WordDataset dataset) _unlockedCountOf;

  SentenceAccess(this._index, this._unlockedCountOf);

  /// 實際參與判斷的主要詞（去掉指向已刪除自訂教材的參照）。
  List<String> effectiveWordIds(Sentence sentence) => [
        for (final ref in sentence.wordIds.toSet())
          if (!_index.isFromDeletedDataset(ref)) ref
      ];

  bool isResolvable(Sentence sentence) {
    final refs = effectiveWordIds(sentence);
    return refs.isNotEmpty && refs.every(_index.contains);
  }

  bool isWordUnlocked(String ref) {
    final location = _index.resolve(ref);
    if (location == null) return false;
    return location.index < _unlockedCountOf(location.dataset);
  }

  bool isAccessible(Sentence sentence) {
    if (!isResolvable(sentence)) return false;
    final unlockedByTerm = <String, bool>{};
    for (final ref in effectiveWordIds(sentence)) {
      final key = _termKey(ref);
      unlockedByTerm[key] =
          (unlockedByTerm[key] ?? false) || isWordUnlocked(ref);
    }
    return unlockedByTerm.values.every((unlocked) => unlocked);
  }

  /// 可對應但因免費版限制而鎖住的句子。
  bool isLocked(Sentence sentence) =>
      isResolvable(sentence) && !isAccessible(sentence);

  String _termKey(String ref) {
    final location = _index.resolve(ref)!;
    return '${location.dataset.wordLocale}\u0001'
        '${location.item.word.trim().toLowerCase()}';
  }
}
