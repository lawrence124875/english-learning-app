import 'dart:convert';
import 'dart:io';

import 'package:english_learning_app/domain/models/word_item.dart';
import 'package:english_learning_app/practical_english/data/sentence_csv_importer.dart';
import 'package:english_learning_app/practical_english/data/sentence_repository.dart';
import 'package:english_learning_app/practical_english/domain/models/sentence.dart';
import 'package:english_learning_app/practical_english/domain/services/word_ref_index.dart';
import 'package:flutter_test/flutter_test.dart';

WordItem _w(String id) => WordItem(id: id, word: id, translations: const {});

final _datasets = [
  WordDataset(
    id: 'ngsl_2809',
    name: 'NGSL',
    shortName: 'NGSL',
    builtIn: true,
    items: [for (var i = 0; i < 5; i++) _w('ngsl_2809_000$i')],
  ),
];

String _builtInCorpus() => jsonEncode({
      'schema': 1,
      'datasetId': 'pe_core',
      'sentences': [
        {
          'id': 'pe_core_000001',
          'wordIds': ['ngsl_2809_0001'],
          'datasetId': 'pe_core',
          'targetLanguage': 'en-US',
          'sentenceText': 'I need more time.',
          'translations': {'zh-TW': '我需要更多時間。'},
        }
      ],
    });

/// SPEC §8：多語言 CSV 匯入（寬欄、驗證、衝突、內建句命中、覆寫、冪等）。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  setUp(() async => dir = await Directory.systemTemp.createTemp('pe_csv_ml'));
  tearDown(() async => dir.delete(recursive: true));

  SentenceRepository newRepo() => SentenceRepository(
      loadBuiltInAsset: () async => _builtInCorpus(), baseDir: () async => dir);

  SentenceCsvImporter importer(SentenceRepository repo) => SentenceCsvImporter(
      repository: repo, wordIndex: WordRefIndex.build(_datasets));

  Future<SentenceImportResult> run(SentenceRepository repo, String csv,
          {String locale = 'zh-TW', bool overwrite = false}) =>
      importer(repo)
          .importCsv(csv, translationLocale: locale, overwrite: overwrite);

  Sentence only(SentenceRepository repo) => repo.imported.single;

  String fileText() =>
      File('${dir.path}/imported_sentences.json').readAsStringSync();

  group('header', () {
    test('wide columns only (no single column) are accepted', () async {
      final repo = newRepo();
      final r = await run(
          repo,
          'word_id,sentence,sentence_translation_zh-TW,sentence_translation_ja\n'
          'ngsl_2809_0002,Can you help me?,你可以幫我嗎？,手伝ってくれますか？\n');
      expect(r.added, 1);
      expect(only(repo).translations, {'zh-TW': '你可以幫我嗎？', 'ja': '手伝ってくれますか？'});
    });

    test('wide column codes are normalized through the registry', () async {
      final repo = newRepo();
      await run(
          repo,
          'word_id,sentence,Sentence_Translation_zh_tw,sentence_translation_JA-jp,'
          'sentence_translation_pt,sentence_translation_zh-Hans\n'
          'ngsl_2809_0002,Hi.,嗨,やあ,Oi,嗨嗨\n');
      expect(only(repo).translations.keys.toSet(),
          {'zh-TW', 'ja', 'pt-BR', 'zh-CN'});
    });

    test('invalid wide column code is a file error listing the column', () {
      final imp = importer(newRepo());
      expect(
          () => imp.evaluate(
              'word_id,sentence,sentence_translation_jp,sentence_translation_xx\n'
              'ngsl_2809_0002,Hi.,a,b\n',
              translationLocale: 'zh-TW'),
          throwsA(isA<SentenceCsvFileException>()
              .having((e) => e.error, 'error',
                  SentenceCsvFileError.invalidTranslationColumn)
              .having((e) => e.columns, 'columns',
                  ['sentence_translation_jp', 'sentence_translation_xx'])));
    });

    test('bare zh in a header is invalid (ambiguous)', () {
      final imp = importer(newRepo());
      expect(
          () => imp.evaluate(
              'word_id,sentence,sentence_translation_zh\nx,y,z\n',
              translationLocale: 'zh-TW'),
          throwsA(isA<SentenceCsvFileException>().having((e) => e.error,
              'error', SentenceCsvFileError.invalidTranslationColumn)));
    });

    test('two columns for the same language is a file error', () {
      final imp = importer(newRepo());
      expect(
          () => imp.evaluate(
              'word_id,sentence,sentence_translation_ja,sentence_translation_ja-JP\n'
              'ngsl_2809_0002,Hi.,a,b\n',
              translationLocale: 'zh-TW'),
          throwsA(isA<SentenceCsvFileException>().having((e) => e.error,
              'error', SentenceCsvFileError.duplicateTranslationColumn)));
    });

    test('no translation column at all lists sentence_translation as missing',
        () {
      final imp = importer(newRepo());
      expect(
          () => imp.evaluate('word_id,sentence\nngsl_2809_0002,Hi.\n',
              translationLocale: 'zh-TW'),
          throwsA(isA<SentenceCsvFileException>().having(
              (e) => e.missingColumns, 'missing', ['sentence_translation'])));
    });
  });

  group('row validation', () {
    test('single column uses translation_locale, else the screen language',
        () async {
      final repo = newRepo();
      await run(
          repo,
          'word_id,sentence,sentence_translation,translation_locale\n'
          'ngsl_2809_0002,One.,一,\n'
          'ngsl_2809_0003,Two.,ニ,JA\n',
          locale: 'ko');
      final byText = {for (final s in repo.imported) s.sentenceText: s};
      expect(byText['One.']!.translations, {'ko': '一'});
      expect(byText['Two.']!.translations, {'ja': 'ニ'});
    });

    test('screen language is canonicalized too', () async {
      final repo = newRepo();
      await run(repo,
          'word_id,sentence,sentence_translation\nngsl_2809_0002,One.,一\n',
          locale: 'zh_Hant');
      expect(only(repo).translations, {'zh-TW': '一'});
    });

    test('invalid translation_locale or target_language is an Invalid Row',
        () async {
      final repo = newRepo();
      final r = await run(
          repo,
          'word_id,sentence,sentence_translation,translation_locale,target_language\n'
          'ngsl_2809_0002,One.,一,jp,\n'
          'ngsl_2809_0002,Two.,二,,ja-JP\n'
          'ngsl_2809_0002,Three.,三,,english\n'
          'ngsl_9999_0000,Four.,四,cn,\n');
      expect(r.invalidRows.map((e) => '${e.row}:${e.reason.name}'), [
        '2:invalidLocale',
        '3:invalidTargetLanguage',
        '4:invalidTargetLanguage',
        '5:invalidLocale', // Invalid Row 比 Invalid Word ID 嚴重
      ]);
      expect(r.invalidWordIds, isEmpty);
      expect(r.hasChanges, isFalse);
    });

    test('English target codes are canonicalized before dedup', () async {
      final repo = newRepo();
      final r = await run(
          repo,
          'word_id,sentence,sentence_translation,target_language\n'
          'ngsl_2809_0002,Hello there.,你好,en\n'
          'ngsl_2809_0003,Hello there.,,EN_us\n'
          'ngsl_2809_0004,Hello there.,,\n'
          'ngsl_2809_0002,Hello there.,你好,en-GB\n');
      expect(r.added, 2); // en-US 與 en-GB 是不同句
      expect(r.updated, 2);
      final us = repo.imported.firstWhere((s) => s.targetLanguage == 'en-US');
      expect(
          us.wordIds, ['ngsl_2809_0002', 'ngsl_2809_0003', 'ngsl_2809_0004']);
    });

    test('empty translation cells are ignored; no-translation rows warn',
        () async {
      final repo = newRepo();
      final r = await run(
          repo,
          'word_id,sentence,sentence_translation_zh-TW,sentence_translation_ja\n'
          'ngsl_2809_0002,One.,一,\n'
          'ngsl_2809_0003,Two.,,\n');
      expect(r.added, 2);
      expect(r.noTranslationRows, [3]);
      expect(repo.imported.first.translations, {'zh-TW': '一'});
    });

    test('wide and single column agree → used once', () async {
      final repo = newRepo();
      final r = await run(
          repo,
          'word_id,sentence,sentence_translation,sentence_translation_zh-TW\n'
          'ngsl_2809_0002,One.,一,一\n');
      expect(r.added, 1);
      expect(only(repo).translations, {'zh-TW': '一'});
    });

    test('wide and single column disagree → Conflict, neither written',
        () async {
      final repo = newRepo();
      final r = await run(
          repo,
          'word_id,sentence,sentence_translation,sentence_translation_zh-TW,'
          'sentence_translation_ja\n'
          'ngsl_2809_0002,One.,一,壹,いち\n');
      expect(r.added, 0);
      expect(r.conflicts.single.row, 2);
      expect(r.conflicts.single.languages, ['zh-TW']);
      // 句子本身與其他語言仍寫入
      expect(r.hasChanges, isTrue);
      expect(only(repo).translations, {'ja': 'いち'});
    });
  });

  group('conflicts with stored data', () {
    const first = 'word_id,sentence,sentence_translation\n'
        'ngsl_2809_0002,Can you help me?,你可以幫我嗎？\n';
    const changed = 'word_id,sentence,sentence_translation\n'
        'ngsl_2809_0002,Can you help me?,能幫我嗎？\n';

    test('different text is a Conflict and keeps the stored text', () async {
      final repo = newRepo();
      await run(repo, first);
      final before = fileText();
      final r = await run(repo, changed);
      expect(r.conflicts.map((c) => c.row), [2]);
      expect(r.updated, 0);
      expect(r.hasChanges, isFalse);
      expect(fileText(), before);
    });

    test('overwrite replaces an imported translation and is idempotent',
        () async {
      final repo = newRepo();
      await run(repo, first);
      final r = await run(repo, changed, overwrite: true);
      expect(r.updated, 1);
      expect(r.conflicts, isEmpty);
      expect(only(repo).translations, {'zh-TW': '能幫我嗎？'});
      final again = await run(repo, changed, overwrite: true);
      expect(again.updated, 0);
      expect(again.duplicate, 1);
    });

    test('a conflicting row still merges its other changes', () async {
      final repo = newRepo();
      await run(repo, first);
      final r = await run(
          repo,
          'word_id,sentence,sentence_translation,sentence_translation_ja\n'
          'ngsl_2809_0003,Can you help me?,能幫我嗎？,手伝って\n');
      expect(r.conflicts.single.languages, ['zh-TW']);
      expect(only(repo).wordIds, ['ngsl_2809_0002', 'ngsl_2809_0003']);
      expect(only(repo).translations, {'zh-TW': '你可以幫我嗎？', 'ja': '手伝って'});
      final again = await run(
          repo,
          'word_id,sentence,sentence_translation,sentence_translation_ja\n'
          'ngsl_2809_0003,Can you help me?,能幫我嗎？,手伝って\n');
      expect(again.hasChanges, isFalse);
      expect(again.conflicts.length, 1);
    });

    test('stored non-canonical keys are matched through aliases', () async {
      final repo = newRepo();
      await repo.load();
      await repo.replaceImported([
        const Sentence(
            id: 'imp_x',
            wordIds: ['ngsl_2809_0002'],
            datasetId: 'pe_import',
            targetLanguage: 'en-US',
            sentenceText: 'Old one.',
            translations: {'ja-JP': '古い'}),
      ]);
      final r = await run(
          repo,
          'word_id,sentence,sentence_translation_ja\n'
          'ngsl_2809_0002,Old one.,古い\n');
      expect(r.duplicate, 1);
      expect(r.hasChanges, isFalse);
    });
  });

  group('within one file', () {
    const twoTexts = 'word_id,sentence,sentence_translation\n'
        'ngsl_2809_0002,Can you help me?,甲\n'
        'ngsl_2809_0003,Can you help me?,乙\n';

    test('two texts for the same key and language → Conflict for every row',
        () async {
      final repo = newRepo();
      final r = await run(repo, twoTexts);
      expect(r.conflicts.map((c) => c.row), [2, 3]);
      expect(r.added, 0);
      // 句子與連結仍寫入，衝突的語言不寫
      expect(only(repo).translations, isEmpty);
      expect(only(repo).wordIds, ['ngsl_2809_0002', 'ngsl_2809_0003']);
    });

    test('result never depends on row order', () async {
      final a = newRepo();
      await run(a, twoTexts);
      final aJson = fileText();
      await File('${dir.path}/imported_sentences.json').delete();
      final b = newRepo();
      await run(
          b,
          'word_id,sentence,sentence_translation\n'
          'ngsl_2809_0003,Can you help me?,乙\n'
          'ngsl_2809_0002,Can you help me?,甲\n');
      expect(b.imported.single.translations, a.imported.single.translations);
      expect(b.imported.single.id, a.imported.single.id);
      expect(aJson, isNotEmpty);
    });

    test('overwrite does not apply to in-file conflicts', () async {
      final repo = newRepo();
      await run(repo,
          'word_id,sentence,sentence_translation\nngsl_2809_0002,Can you help me?,原\n');
      final r = await run(repo, twoTexts, overwrite: true);
      expect(r.conflicts.map((c) => c.row), [2, 3]);
      expect(only(repo).translations, {'zh-TW': '原'});
    });

    test('identical repeats count once', () async {
      final repo = newRepo();
      final r = await run(
          repo,
          'word_id,sentence,sentence_translation\n'
          'ngsl_2809_0002,Can you help me?,甲\n'
          'ngsl_2809_0002,Can you help me!,甲\n');
      expect(r.added, 1);
      expect(r.duplicate, 1);
      expect(r.conflicts, isEmpty);
    });

    test('in-file conflict in one language does not block another', () async {
      final repo = newRepo();
      final r = await run(
          repo,
          'word_id,sentence,sentence_translation_zh-TW,sentence_translation_ja\n'
          'ngsl_2809_0002,Hi.,甲,やあ\n'
          'ngsl_2809_0002,Hi.,乙,\n');
      expect(r.conflicts.map((c) => c.row), [2, 3]);
      expect(only(repo).translations, {'ja': 'やあ'});
    });
  });

  group('built-in sentences', () {
    test('a match is reported with row numbers, never Duplicate', () async {
      final repo = newRepo();
      final r = await run(
          repo,
          'word_id,sentence,sentence_translation,translation_locale\n'
          'ngsl_2809_0003,I need more time.,もっと時間が必要,ja\n'
          'ngsl_2809_0001,i need  more time!,,\n');
      expect(r.builtInMatches, [2, 3]);
      expect(r.duplicate, 0);
      expect(r.hasChanges, isFalse);
      expect(repo.byId('pe_core_000001')!.wordIds, ['ngsl_2809_0001']);
      expect(repo.byId('pe_core_000001')!.translations, {'zh-TW': '我需要更多時間。'});
    });

    test('overwrite never applies to built-in sentences', () async {
      final repo = newRepo();
      final r = await run(
          repo,
          'word_id,sentence,sentence_translation\n'
          'ngsl_2809_0001,I need more time.,別的翻譯\n',
          overwrite: true);
      expect(r.builtInMatches, [2]);
      expect(repo.byId('pe_core_000001')!.translations, {'zh-TW': '我需要更多時間。'});
    });

    test('in-file conflict on a built-in row counts as Conflict', () async {
      final repo = newRepo();
      final r = await run(
          repo,
          'word_id,sentence,sentence_translation\n'
          'ngsl_2809_0001,I need more time.,甲\n'
          'ngsl_2809_0001,I need more time.,乙\n');
      expect(r.conflicts.map((c) => c.row), [2, 3]);
      expect(r.builtInMatches, isEmpty);
    });
  });

  group('guarantees', () {
    const file =
        'word_id,sentence,sentence_translation,sentence_translation_ja,'
        'translation_locale,target_language\n'
        'ngsl_2809_0002,Can you help me?,你可以幫我嗎？,手伝って,,\n' // Added
        'ngsl_2809_0003,can you help me,,,,en\n' // Updated（新連結）
        'ngsl_2809_0001,I need more time.,,,,\n' // Built-in match
        'ngsl_2809_0004,Two texts.,甲,,,\n' // 檔內衝突
        'ngsl_2809_0004,Two texts.,乙,,,\n' // 檔內衝突
        'ngsl_9999_0000,Bad.,壞,,,\n' // Invalid Word ID
        'ngsl_2809_0002,Bad locale.,壞,,xx,\n'; // Invalid Row

    test('each row is counted once by its most severe result', () async {
      final r = await run(newRepo(), file);
      expect(r.added, 1);
      expect(r.updated, 1);
      expect(r.duplicate, 0);
      expect(r.builtInMatches, [4]);
      expect(r.conflicts.map((c) => c.row), [5, 6]);
      expect(r.invalidWordIds.map((e) => e.row), [7]);
      expect(r.invalidRows.map((e) => e.row), [8]);
      final total = r.added +
          r.updated +
          r.duplicate +
          r.builtInMatches.length +
          r.conflicts.length +
          r.invalidWordIds.length +
          r.invalidRows.length;
      expect(total, 7); // 第 2–8 列
    });

    test(
        'importing the same file twice changes nothing, with or without overwrite',
        () async {
      final repo = newRepo();
      await run(repo, file);
      final before = fileText();
      for (final overwrite in [false, true]) {
        final r = await run(repo, file, overwrite: overwrite);
        expect(r.added, 0);
        expect(r.updated, 0);
        expect(r.conflicts.map((c) => c.row), [5, 6]);
        expect(fileText(), before);
      }
    });

    test('all languages survive write and reload', () async {
      await run(newRepo(), file);
      final reloaded = newRepo();
      await reloaded.load();
      final s = reloaded.imported
          .firstWhere((s) => s.sentenceText == 'Can you help me?');
      expect(s.translations, {'zh-TW': '你可以幫我嗎？', 'ja': '手伝って'});
      expect(s.wordIds, ['ngsl_2809_0002', 'ngsl_2809_0003']);
    });
  });
}
