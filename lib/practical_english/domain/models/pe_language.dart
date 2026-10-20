/// Practical English 的翻譯語言登錄表（SPEC §6.4）。
///
/// 選單、CSV 驗證、翻譯朗讀、文字方向都從這裡讀，不另外寫死清單。
/// V1 的語言清單在 V2.0 不改用這張表。
class PeLanguage {
  /// Canonical 翻譯代碼（`Sentence.translations` 的 key）。
  final String code;

  /// 可接受的其他寫法（比對時不分大小寫、`_` 視同 `-`）。
  final List<String> aliases;

  /// 選單上顯示的名稱（該語言自己的寫法）。
  final String endonym;

  /// 交給 TTS 的語言代碼。
  final String ttsCode;

  final bool isRtl;

  /// App 介面是否有這個語言（11 種 ARB）。
  final bool hasUi;

  const PeLanguage({
    required this.code,
    this.aliases = const [],
    required this.endonym,
    required this.ttsCode,
    this.isRtl = false,
    this.hasUi = true,
  });
}

class PeLanguages {
  PeLanguages._();

  /// V2.0 支援的 10 種翻譯語言。別名是本 App 的產品規則，不是通用標準；
  /// `jp`、`cn`、`tw`、單獨的 `zh` 這類寫法一律無效，不猜測。
  static const List<PeLanguage> all = [
    PeLanguage(
        code: 'zh-TW',
        aliases: ['zh-Hant', 'zh-Hant-TW'],
        endonym: '繁體中文',
        ttsCode: 'zh-TW'),
    PeLanguage(
        code: 'zh-CN',
        aliases: ['zh-Hans', 'zh-Hans-CN'],
        endonym: '简体中文',
        ttsCode: 'zh-CN'),
    PeLanguage(
        code: 'ja', aliases: ['ja-JP'], endonym: '日本語', ttsCode: 'ja-JP'),
    PeLanguage(
        code: 'ko', aliases: ['ko-KR'], endonym: '한국어', ttsCode: 'ko-KR'),
    PeLanguage(
        code: 'vi',
        aliases: ['vi-VN'],
        endonym: 'Tiếng Việt',
        ttsCode: 'vi-VN'),
    PeLanguage(
        code: 'id',
        aliases: ['id-ID', 'in'],
        endonym: 'Bahasa Indonesia',
        ttsCode: 'id-ID'),
    PeLanguage(
        code: 'es', aliases: ['es-ES'], endonym: 'Español', ttsCode: 'es-ES'),
    PeLanguage(
        code: 'pt-BR',
        aliases: ['pt'],
        endonym: 'Português (Brasil)',
        ttsCode: 'pt-BR'),
    PeLanguage(
        code: 'th', aliases: ['th-TH'], endonym: 'ไทย', ttsCode: 'th-TH'),
    PeLanguage(
        code: 'ar',
        aliases: ['ar-SA'],
        endonym: 'العربية',
        ttsCode: 'ar-SA',
        isRtl: true),
  ];

  /// 句子原文（target language）在 V2.0 只接受英文（SPEC §8.1、D20）。
  /// key 是比對用的寫法，value 是正規化後的代碼。
  static const Map<String, String> _englishTargets = {
    'en': 'en-US',
    'en-us': 'en-US',
    'en-gb': 'en-GB',
    'en-au': 'en-AU',
    'en-in': 'en-IN',
  };

  static String _key(String raw) =>
      raw.trim().replaceAll('_', '-').toLowerCase();

  static final Map<String, PeLanguage> _byKey = {
    for (final lang in all) ...{
      _key(lang.code): lang,
      for (final alias in lang.aliases) _key(alias): lang,
    }
  };

  /// 依任何可接受的寫法找語言；無效時回傳 null。
  static PeLanguage? lookup(String raw) => _byKey[_key(raw)];

  /// 正規化翻譯代碼（`JA` → `ja`、`zh_tw` → `zh-TW`、`pt` → `pt-BR`）；無效時 null。
  static String? canonicalize(String raw) => lookup(raw)?.code;

  /// 正規化英文原文代碼（`en` → `en-US`、`en_gb` → `en-GB`）；非英文或無效時 null。
  static String? canonicalTarget(String raw) => _englishTargets[_key(raw)];
}
