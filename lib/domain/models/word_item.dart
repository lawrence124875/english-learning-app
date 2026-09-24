/// 單一教材項目（單字或片語）。
/// [translations] 是多語言 map，例如 {"zh-TW": "蘋果", "ja": "りんご"}。
/// 內建教材逐步補上 ja / ko / vi / id；還沒翻譯到的項目會退回 zh-TW。
class WordItem {
  final String id;
  final String word;
  final Map<String, String> translations;

  const WordItem({
    required this.id,
    required this.word,
    required this.translations,
  });

  /// 依照使用者目前的語言設定取得對應翻譯；找不到則 fallback 回中文。
  String meaningFor(String localeCode) {
    return translations[resolveLocale(localeCode)] ?? '';
  }

  /// 實際會用到的翻譯語言：優先用 [preferred]，沒有就退回 zh-TW。
  /// 朗讀翻譯時要用這個結果決定 TTS 語言，才不會發生
  /// 「顯示的是中文翻譯，卻用日文語音去念」的情況。
  String resolveLocale(String preferred) {
    if (translations.containsKey(preferred)) return preferred;
    if (translations.containsKey('zh-TW')) return 'zh-TW';
    return translations.isEmpty ? preferred : translations.keys.first;
  }

  factory WordItem.fromJson(Map<String, dynamic> json) {
    final rawM = json['m'];
    final Map<String, String> translations = {};
    if (rawM is Map) {
      rawM.forEach((k, v) {
        translations[k.toString()] = v.toString();
      });
    }
    return WordItem(
      id: json['id'] as String,
      word: json['w'] as String,
      translations: translations,
    );
  }
}

/// 一整份教材（例如 NGSL 2809）。
class WordDataset {
  final String id;
  final String name;
  final String shortName;
  final List<WordItem> items;

  /// 這份教材主要使用的翻譯語言代碼（例如 "zh-TW"、"ja"）。
  /// 內建四份教材固定是 "zh-TW"；使用者自訂匯入的教材，
  /// 會依照匯入時選擇的語言設定這個欄位，畫面顯示跟朗讀翻譯時
  /// 都要照這個欄位選對應語言，不能整個 App 都寫死中文。
  final String primaryLocale;

  /// 是否為 App 內建教材。內建教材的翻譯語言跟著介面語言走；
  /// 自訂教材則固定使用匯入時選的 [primaryLocale]。
  final bool builtIn;

  const WordDataset({
    required this.id,
    required this.name,
    required this.shortName,
    required this.items,
    this.primaryLocale = 'zh-TW',
    this.builtIn = false,
  });

  factory WordDataset.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>;
    return WordDataset(
      id: json['id'] as String,
      name: json['name'] as String,
      shortName: json['short'] as String,
      items: itemsJson
          .map((e) => WordItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      primaryLocale: json['primaryLocale'] as String? ?? 'zh-TW',
      builtIn: json['builtIn'] as bool? ?? false,
    );
  }
}
