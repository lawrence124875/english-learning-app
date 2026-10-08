import '../../../domain/models/word_item.dart';

/// Canonical Word Reference（SPEC §4）：全 App 唯一指向一個單字項目的字串。
///
/// - 內建教材：直接用 `WordItem.id`（例如 `ngsl_2809_0001`），本身就全域唯一。
/// - 自訂教材：`<datasetId>/<WordItem.id>`。自訂教材的 WordItem.id
///   （`custom_<列號>_<hash>`）在不同自訂教材之間可能重複，必須加上教材 ID。
///
/// `/` 是保留的分隔符號，內建 ID 不會含有 `/`。
class WordRef {
  static const separator = '/';

  WordRef._();

  /// 依教材類型產生 WordRef。
  static String of(WordDataset dataset, WordItem item) =>
      dataset.builtIn ? item.id : qualify(dataset.id, item.id);

  /// 自訂教材單字的完整參照。
  static String qualify(String datasetId, String wordId) =>
      '$datasetId$separator$wordId';

  /// 是否為自訂教材的參照（含資料集前綴）。
  static bool isQualified(String ref) => ref.contains(separator);

  /// 自訂參照的教材 ID；內建參照回傳 null。
  static String? datasetIdOf(String ref) {
    final i = ref.indexOf(separator);
    return i < 0 ? null : ref.substring(0, i);
  }

  /// 格式檢查：非空、沒有前後空白、最多一個分隔符號且兩側都不為空。
  static bool isWellFormed(String ref) {
    if (ref.isEmpty || ref.trim() != ref) return false;
    final parts = ref.split(separator);
    if (parts.length > 2) return false;
    return parts.every((p) => p.isNotEmpty);
  }
}
