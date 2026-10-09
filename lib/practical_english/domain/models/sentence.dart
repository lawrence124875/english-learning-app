/// Practical English 句子（SPEC §6.1）。
///
/// [wordIds]（主要詞）與 [secondaryWordIds]（次要詞）是 Sentence ↔ Word
/// 唯一持久化的關聯（WordRef 清單，見 word_ref.dart）；反向的「單字 → 句子」
/// 只在記憶體裡由 SentenceRepository 建立，不另外存檔。
class Sentence {
  final String id;

  /// 主要詞：免費解鎖、覆蓋率、練習次數都只看這裡（SPEC §6.1、§12）。
  final List<String> wordIds;

  /// 次要詞（選填）：只用於「單字找例句」與不熟悉模式的選句排序，
  /// 絕不影響免費解鎖、覆蓋率與練習次數（SPEC §6.1、D19）。
  final List<String> secondaryWordIds;
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
    this.secondaryWordIds = const [],
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

  /// 主要詞＋次要詞（去重，主要詞在前）。同時出現在兩邊的只算主要詞。
  List<String> get allWordIds => [
        ...{...wordIds, ...secondaryWordIds}
      ];

  /// 只屬於次要詞的 WordRef（排除也在主要詞裡的）。
  List<String> get secondaryOnlyWordIds {
    final primary = wordIds.toSet();
    return [
      ...{...secondaryWordIds.where((r) => !primary.contains(r))}
    ];
  }

  Sentence copyWith({
    List<String>? wordIds,
    List<String>? secondaryWordIds,
    Map<String, String>? translations,
  }) {
    return Sentence(
      id: id,
      wordIds: wordIds ?? this.wordIds,
      secondaryWordIds: secondaryWordIds ?? this.secondaryWordIds,
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
    final rawSecondary = json['secondaryWordIds'];
    return Sentence(
      id: id,
      wordIds: rawWordIds.map((e) => e.toString()).toList(growable: false),
      secondaryWordIds: rawSecondary is List
          ? rawSecondary.map((e) => e.toString()).toList(growable: false)
          : const [],
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
        if (secondaryWordIds.isNotEmpty) 'secondaryWordIds': secondaryWordIds,
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
