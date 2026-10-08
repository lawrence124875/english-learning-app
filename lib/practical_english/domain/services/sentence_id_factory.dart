import 'dart:convert';

/// FNV-1a 64 位元雜湊（SPEC §6.2）。結果跨重啟、跨裝置都相同，
/// 用來產生持久化 ID；絕對不要改用 Dart `String.hashCode`（不保證穩定）。
///
/// Dart VM 的 int 是 64 位元二補數，乘法溢位會自動截斷，正好符合 FNV 需求。
/// （本 App 只在 Android/iOS 原生執行，不編譯成 Web。）
class Fnv1a64 {
  static const _offsetBasis = 0xcbf29ce484222325;
  static const _prime = 0x100000001b3;

  Fnv1a64._();

  static int hashBytes(List<int> bytes) {
    var hash = _offsetBasis;
    for (final b in bytes) {
      hash ^= b;
      hash *= _prime;
    }
    return hash;
  }

  /// 對字串的 UTF-8 位元組做雜湊，回傳 16 位小寫十六進位字串。
  static String hex(String input) {
    final h = hashBytes(utf8.encode(input));
    // int 是有號 64 位元，負數不能直接轉十六進位；拆成高低 32 位元各自輸出。
    final high = (h >> 32) & 0xFFFFFFFF;
    final low = h & 0xFFFFFFFF;
    return high.toRadixString(16).padLeft(8, '0') +
        low.toRadixString(16).padLeft(8, '0');
  }
}

/// Sentence ID 產生規則（SPEC §6.2）。
///
/// - 內建：`pe_core_000001`，由內容製作流程指定，App 不產生。
/// - 匯入：`imp_` + FNV-1a 64(dedupKey) 的 16 位十六進位。
/// - 兩種前綴不同，內建與匯入的 ID 不會互撞。
class SentenceIdFactory {
  static const builtInPrefix = 'pe_core_';
  static const importedPrefix = 'imp_';

  SentenceIdFactory._();

  static const _trailingPunctuation = {'.', '!', '?', '。', '！', '？'};

  /// 句子正規化：trim → 內部空白合併成一個空格 → 彎引號改直引號 →
  /// 去掉句尾 . ! ? 。 ！ ？ → 小寫。
  ///
  /// 註：Dart 沒有內建 Unicode NFC，V2.0 不加套件（SPEC §6.2 NFC 註記）。
  /// 這裡每一步在所有裝置上結果都相同，ID 因此穩定；日後若要加 NFC，
  /// 會改變 ID，必須先規劃 ID 遷移。
  static String normalize(String text) {
    var s = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    s = s
        .replaceAll(RegExp('[‘’‚‛′]'), "'")
        .replaceAll(RegExp('[“”„‟″]'), '"');
    while (s.isNotEmpty && _trailingPunctuation.contains(s[s.length - 1])) {
      s = s.substring(0, s.length - 1).trimRight();
    }
    return s.toLowerCase();
  }

  /// 去重鍵：目標語言 + U+0001 + 正規化後的句子。
  static String dedupKey(String targetLanguage, String sentenceText) =>
      '$targetLanguage\u0001${normalize(sentenceText)}';

  /// 匯入句子的基本 ID（尚未處理碰撞）。
  static String importedIdFor(String dedupKey) =>
      '$importedPrefix${Fnv1a64.hex(dedupKey)}';

  /// 依 dedupKey 取得穩定 ID：
  /// 1. 這個 dedupKey 已有 ID → 直接回傳（重複匯入結果不變）。
  /// 2. 否則用雜湊產生 ID；若該 ID 已被「不同的 dedupKey」佔用，
  ///    依序加上 `-2`、`-3`… 直到沒有被佔用。
  ///
  /// [idByKey]：dedupKey → 已指派的 ID；[keyById]：ID → dedupKey。
  /// 兩者由呼叫端（匯入流程）維護，指派後由本方法寫入。
  static String assign(
    String dedupKey, {
    required Map<String, String> idByKey,
    required Map<String, String> keyById,
  }) {
    final existing = idByKey[dedupKey];
    if (existing != null) return existing;
    final base = importedIdFor(dedupKey);
    var candidate = base;
    var n = 2;
    while (keyById.containsKey(candidate) && keyById[candidate] != dedupKey) {
      candidate = '$base-$n';
      n++;
    }
    idByKey[dedupKey] = candidate;
    keyById[candidate] = dedupKey;
    return candidate;
  }
}
