import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 11 種介面語言的 ARB key 必須一致，placeholder 也要對得上。
void main() {
  final files = Directory('lib/l10n')
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.arb'))
      .toList();
  Map<String, dynamic> read(File f) =>
      jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
  final template = read(File('lib/l10n/app_zh.arb'));
  final keys = template.keys.where((k) => !k.startsWith('@')).toSet();

  test('11 ARB files', () => expect(files.length, 11));

  for (final f in files) {
    test('${f.path} has the same keys and placeholders as app_zh.arb', () {
      final arb = read(f);
      expect(arb.keys.where((k) => !k.startsWith('@')).toSet(), keys);
      for (final k in keys) {
        final ph = RegExp(r'\{(\w+)\}');
        Set<String> names(String s) =>
            ph.allMatches(s).map((m) => m.group(1)!).toSet();
        expect(names(arb[k] as String), names(template[k] as String),
            reason: k);
      }
    });
  }

  test('v20 read-mode copy no longer says "English" where it means the word',
      () {
    for (final f in files) {
      final arb = read(f);
      for (final k in ['readModeEnglishOnly', 'summaryReadEnglishOnly']) {
        expect(arb[k], isNot(matches(RegExp(r'英文|英語|영어|Anh|Inggris|inglés|inglês'))),
            reason: '${f.path} $k');
      }
    }
  });
}
