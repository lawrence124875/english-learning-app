/// 單一教材項目（單字或片語）。
/// [translations] 是多語言 map，例如 {"zh-TW": "蘋果", "ja": "りんご"}。
/// 目前只會有 zh-TW，之後加日/韓/越語只需擴充這個 map，不需要改資料結構。
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
    return translations[localeCode] ?? translations['zh-TW'] ?? '';
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

  const WordDataset({
    required this.id,
    required this.name,
    required this.shortName,
    required this.items,
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
    );
  }
}
