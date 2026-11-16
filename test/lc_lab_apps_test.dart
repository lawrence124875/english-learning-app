import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('LC Lab 其他 App：11 語都有字串、圖示已內嵌', () {
    const keys = [
      'lcLabAppsTitle',
      'lcLabQianguaName',
      'lcLabQianguaDesc',
      'lcLabTarotName',
      'lcLabTarotDesc',
    ];
    final arbs = Directory('lib/l10n')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.arb'))
        .toList();
    expect(arbs.length, 11);
    for (final f in arbs) {
      final map = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      for (final k in keys) {
        expect((map[k] as String?)?.isNotEmpty, true, reason: '${f.path} $k');
      }
    }
    for (final p in ['assets/lclab/qiangua.png', 'assets/lclab/tarot.png']) {
      expect(File(p).existsSync(), true, reason: p);
    }
  });
}
