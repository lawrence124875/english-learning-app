import 'dart:convert';
import 'dart:io';

import 'package:english_learning_app/presentation/widgets/fit_word_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// 大字＋長片語不可超出單字區（0.3.0 紅米 Note 8：單字長到按鈕列後面）。
/// 內建四份教材取最長的單字／翻譯，三種單字大小、兩種系統字級、
/// 三種區塊高度、左到右與右到左都要放得下。
void main() {
  final cases = <(String, String, bool)>[];
  for (final f in Directory('assets/data').listSync()) {
    if (!f.path.endsWith('.json') || f.path.endsWith('manifest.json')) continue;
    final items = (jsonDecode(File(f.path).readAsStringSync())['items'] as List)
        .cast<Map<String, dynamic>>();
    items.sort((a, b) =>
        (b['w'] as String).length.compareTo((a['w'] as String).length));
    for (final it in items.take(15)) {
      final m = (it['m'] as Map).cast<String, String>();
      final longestMeaning =
          m.values.reduce((a, b) => b.length > a.length ? b : a);
      cases.add((it['w'] as String, m['zh-TW'] ?? '', false));
      cases.add((it['w'] as String, longestMeaning, false));
      cases.add((it['w'] as String, m['ar'] ?? '', true));
    }
  }

  testWidgets('word and meaning always fit their area', (tester) async {
    for (final (word, meaning, rtl) in cases) {
      for (final size in [40.0, 52.0, 64.0]) {
        for (final scale in [1.0, 1.3]) {
          for (final box in [const Size(300, 150), const Size(320, 220), const Size(340, 320)]) {
            await tester.pumpWidget(MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: Directionality(
                textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
                // 模擬 Material 3 bodyMedium（行高 1.43、字距 0.25），
                // 0.3.1 第一版沒算進去，實機翻譯被切掉一半。
                child: DefaultTextStyle(
                 style: const TextStyle(height: 1.43, letterSpacing: 0.25),
                 child: Center(
                  child: SizedBox.fromSize(
                    size: box,
                    child: FitWordArea(
                      word: word,
                      meaning: meaning,
                      maxWordSize: size,
                      meaningSize: 16 + (size - 40) / 6,
                      wordStyle: const TextStyle(height: 1.1),
                      meaningStyle: const TextStyle(),
                      wordDirection: TextDirection.ltr,
                      meaningDirection:
                          rtl ? TextDirection.rtl : TextDirection.ltr,
                    ),
                  ),
                ),
               ),
              ),
            ));
            expect(tester.takeException(), isNull,
                reason: '$word / $size / $scale / $box');
            final texts = tester.renderObjectList<RenderParagraph>(
                find.byType(RichText));
            var h = 0.0;
            for (final t in texts) {
              expect(t.size.width, lessThanOrEqualTo(box.width + 0.01));
              h += t.size.height;
            }
            h += FitWordArea.gap;
            expect(h, lessThanOrEqualTo(box.height + 0.01),
                reason: '$word / $meaning / $size / $scale / $box');
          }
        }
      }
    }
  });
}
