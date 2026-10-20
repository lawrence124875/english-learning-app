import 'package:english_learning_app/practical_english/domain/models/pe_language.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registry has the 10 translation languages, codes unique', () {
    final codes = PeLanguages.all.map((l) => l.code).toList();
    expect(codes, [
      'zh-TW', 'zh-CN', 'ja', 'ko', 'vi', 'id', 'es', 'pt-BR', 'th', 'ar' //
    ]);
    expect(codes.toSet().length, 10);
  });

  test('canonical codes and aliases normalize', () {
    const cases = {
      'zh-TW': 'zh-TW',
      'zh_tw': 'zh-TW',
      'ZH-tw': 'zh-TW',
      'zh-Hant': 'zh-TW',
      'zh_Hans': 'zh-CN',
      'zh-hans-cn': 'zh-CN',
      'JA': 'ja',
      'ja_JP': 'ja',
      ' ko ': 'ko',
      'in': 'id',
      'pt': 'pt-BR',
      'PT_br': 'pt-BR',
      'ar-SA': 'ar',
    };
    cases.forEach((raw, expected) {
      expect(PeLanguages.canonicalize(raw), expected, reason: raw);
    });
  });

  test('non-language codes and ambiguous zh are invalid', () {
    for (final raw in [
      'jp',
      'cn',
      'tw',
      'chinese',
      'zh',
      '',
      'en',
      'fr',
      'xx'
    ]) {
      expect(PeLanguages.canonicalize(raw), isNull, reason: raw);
    }
  });

  test('tts codes and text direction', () {
    expect(PeLanguages.lookup('ja')!.ttsCode, 'ja-JP');
    expect(PeLanguages.lookup('zh-CN')!.ttsCode, 'zh-CN');
    expect(PeLanguages.lookup('ar')!.isRtl, isTrue);
    expect(PeLanguages.all.where((l) => l.isRtl).map((l) => l.code), ['ar']);
    expect(PeLanguages.all.every((l) => l.hasUi), isTrue);
  });

  test('English target codes only', () {
    expect(PeLanguages.canonicalTarget('en'), 'en-US');
    expect(PeLanguages.canonicalTarget('en_us'), 'en-US');
    expect(PeLanguages.canonicalTarget('EN-GB'), 'en-GB');
    expect(PeLanguages.canonicalTarget('en-AU'), 'en-AU');
    expect(PeLanguages.canonicalTarget('en-IN'), 'en-IN');
    for (final raw in ['ja-JP', 'zh-TW', 'fr-FR', 'english', '']) {
      expect(PeLanguages.canonicalTarget(raw), isNull, reason: raw);
    }
  });
}
