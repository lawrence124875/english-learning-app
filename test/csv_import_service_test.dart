import 'package:english_learning_app/data/sources/csv_import_service.dart';
import 'package:english_learning_app/domain/models/word_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CsvImportService.parse header detection', () {
    for (final header in [
      'word,translation', // v20 範本
      'english,translation', // v19 以前的範本
      'English,Translation',
      '單字,翻譯',
      'español,ไทย',
    ]) {
      test('skips header "$header"', () {
        final r = CsvImportService.parse('$header\nhola,สวัสดี\n', 'th');
        expect(r.items.map((w) => w.word), ['hola']);
        expect(r.items.single.translations, {'th': 'สวัสดี'});
      });
    }

    test('file without header keeps the first row', () {
      final r = CsvImportService.parse('apple,蘋果\ngive up,放棄', 'zh-TW');
      expect(r.items.map((w) => w.word), ['apple', 'give up']);
    });
  });

  group('CsvImportService.parse formats', () {
    test('BOM, CRLF, blank rows and empty first column', () {
      final r = CsvImportService.parse(
          '﻿word,translation\r\nhola,สวัสดี\r\n\r\n,ไม่มีคำ\r\n', 'th');
      expect(r.items.map((w) => w.word), ['hola']);
      // 既有行為：空白列與第一欄空白的列都算「略過」。
      expect(r.skippedRows, 2);
    });

    test('tab and semicolon delimiters', () {
      expect(CsvImportService.parse('word\ttranslation\nこんにちは\thola', 'es')
          .items.single.translations, {'es': 'hola'});
      expect(CsvImportService.parse('word;translation\nบ้าน;casa', 'es')
          .items.single.word, 'บ้าน');
    });

    test('row without translation imports with empty translations', () {
      final r = CsvImportService.parse('word,translation\nDanke', 'zh-TW');
      expect(r.items.single.translations, isEmpty);
    });

    test('only first two columns are read', () {
      final r = CsvImportService.parse('word,translation\na,b,c,d', 'ja');
      expect(r.items.single.translations, {'ja': 'b'});
    });

    test('errors', () {
      expect(() => CsvImportService.parse('', 'ja'),
          throwsA(isA<CsvImportException>()));
      expect(
          () => CsvImportService.parse('word,translation\n', 'ja'),
          throwsA(isA<CsvImportException>()
              .having((e) => e.error, 'error', CsvImportError.noValidRows)));
    });
  });

  group('template', () {
    test('header is word,translation', () {
      expect(CsvImportService.templateHeader, ['word', 'translation']);
      final csv = CsvImportService.templateCsv(
          apple: 'manzana', giveUp: 'rendirse', howAreYou: '¿Qué tal?');
      expect(csv.split(RegExp(r'\r?\n')).first, 'word,translation');
    });

    test('template round-trips through parse', () {
      final csv = CsvImportService.templateCsv(
          apple: '蘋果', giveUp: '放棄', howAreYou: '你今天過得怎麼樣？');
      final r = CsvImportService.parse(csv, 'zh-TW');
      expect(r.items.map((w) => w.word),
          ['apple', 'give up', 'How are you doing today?']);
      expect(r.items.first.translations, {'zh-TW': '蘋果'});
      expect(r.skippedRows, 0);
    });
  });

  test('custom dataset JSON (CustomDatasetRepository.save shape) reloads', () {
    final ds = WordDataset.fromJson({
      'id': 'custom_1',
      'name': 'Español',
      'short': 'Españo',
      'primaryLocale': 'th',
      'wordLocale': 'es-ES',
      'items': [
        {'id': 'custom_1_1', 'w': 'hola', 'm': {'th': 'สวัสดี'}},
      ],
    });
    expect(ds.wordLocale, 'es-ES');
    expect(ds.primaryLocale, 'th');
    expect(ds.builtIn, isFalse);
    expect(ds.items.single.meaningFor('th'), 'สวัสดี');

    // v19 以前沒有 wordLocale 的舊教材仍視為英文。
    final old = WordDataset.fromJson({
      'id': 'custom_0',
      'name': 'old',
      'short': 'old',
      'primaryLocale': 'zh-TW',
      'items': [],
    });
    expect(old.wordLocale, 'en-US');
  });
}
