/// Practical English 句子（SPEC §6.1）。
///
/// [wordIds] 是 Sentence ↔ Word 唯一持久化的關聯（WordRef 清單，見 word_ref.dart）；
/// 反向的「單字 → 句子」只在記憶體裡由 SentenceRepository 建立，不另外存檔。
class Sentence {
  final String id;
  final List<String> wordIds;
  final String datasetId;

  /// 與 `WordDataset.wordLocale` 相同格式（例如 `en-US`），也是朗讀用的 TTS 語言。
  final String targetLanguage;
  final String sentenceText;

  /// 翻譯，key 沿用 WordItem 的語言代碼（`zh-TW`、`ja`、`ko`…）。
  final Map<String, String> translations;
  final String? level;
  final String? category;

  /// V2.1 預留，V2.0 一律為 null。
  final String? patternId;

  /// V2.2 預留，V2.0 一律為 null。
  final String? scenarioId;

  /// 僅供備註；需要查詢的資料不可放這裡。
  final Map<String, dynamic>? metadata;

  const Sentence({
    required this.id,
    required this.wordIds,
    required this.datasetId,
    required this.targetLanguage,
    required this.sentenceText,
    this.translations = const {},
    this.level,
    this.category,
    this.patternId,
    this.scenarioId,
    this.metadata,
  });

  /// 翻譯 fallback 與 V1 `WordItem.resolveLocale` 相同：
  /// 介面語言 → zh-TW → 第一個可用的 → 無（回傳 null，只顯示英文）。
  String? translationFor(String localeCode) {
    if (translations.containsKey(localeCode)) return translations[localeCode];
    if (translations.containsKey('zh-TW')) return translations['zh-TW'];
    return translations.isEmpty ? null : translations.values.first;
  }

  Sentence copyWith({
    List<String>? wordIds,
    Map<String, String>? translations,
  }) {
    return Sentence(
      id: id,
      wordIds: wordIds ?? this.wordIds,
      datasetId: datasetId,
      targetLanguage: targetLanguage,
      sentenceText: sentenceText,
      translations: translations ?? this.translations,
      level: level,
      category: category,
      patternId: patternId,
      scenarioId: scenarioId,
      metadata: metadata,
    );
  }

  /// 解析單筆句子；必要欄位缺少或格式錯誤時丟 [FormatException]，
  /// 由呼叫端決定略過該筆（不影響其他句子）。
  factory Sentence.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final rawWordIds = json['wordIds'];
    final datasetId = json['datasetId'];
    final targetLanguage = json['targetLanguage'];
    final text = json['sentenceText'];
    if (id is! String || id.isEmpty) {
      throw const FormatException('sentence.id missing');
    }
    if (rawWordIds is! List || rawWordIds.isEmpty) {
      throw FormatException('sentence $id: wordIds missing');
    }
    if (datasetId is! String || targetLanguage is! String || text is! String) {
      throw FormatException('sentence $id: required field missing');
    }
    final translations = <String, String>{};
    final rawT = json['translations'];
    if (rawT is Map) {
      rawT.forEach((k, v) {
        if (v != null) translations[k.toString()] = v.toString();
      });
    }
    final rawMeta = json['metadata'];
    return Sentence(
      id: id,
      wordIds: rawWordIds.map((e) => e.toString()).toList(growable: false),
      datasetId: datasetId,
      targetLanguage: targetLanguage,
      sentenceText: text,
      translations: translations,
      level: json['level'] as String?,
      category: json['category'] as String?,
      patternId: json['patternId'] as String?,
      scenarioId: json['scenarioId'] as String?,
      metadata: rawMeta is Map ? Map<String, dynamic>.from(rawMeta) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'wordIds': wordIds,
        'datasetId': datasetId,
        'targetLanguage': targetLanguage,
        'sentenceText': sentenceText,
        'translations': translations,
        if (level != null) 'level': level,
        if (category != null) 'category': category,
        'patternId': patternId,
        'scenarioId': scenarioId,
        if (metadata != null) 'metadata': metadata,
      };
}
