import 'dart:convert';
import 'dart:io';

import 'package:english_learning_app/domain/models/word_item.dart';
import 'package:english_learning_app/practical_english/data/sentence_csv_importer.dart';
import 'package:english_learning_app/practical_english/data/sentence_repository.dart';
import 'package:english_learning_app/practical_english/domain/models/sentence.dart';
import 'package:english_learning_app/practical_english/domain/services/sentence_id_factory.dart';
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
  WordDataset(
      id: 'custom_1', name: 'C', shortName: 'C', items: [_w('custom_0_7')]),
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  setUp(() async => dir = await Directory.systemTemp.createTemp('pe_csv'));
  tearDown(() async => dir.delete(recursive: true));

  SentenceRepository newRepo() => SentenceRepository(
      loadBuiltInAsset: () async => _builtInCorpus(),
      baseDir: () async => dir);

  SentenceCsvImporter importer(SentenceRepository repo) => SentenceCsvImporter(
      repository: repo, wordIndex: WordRefIndex.build(_datasets));

  // 一份涵蓋所有結果類型的檔案（表頭是第 1 列）
  const mixed = 'word_id,sentence,sentence_translation\n'
      'ngsl_2809_0002,Can you help me?,你可以幫我嗎？\n' // 2 Added
      'ngsl_2809_0003|custom_1/custom_0_7,I like apples.,我喜歡蘋果。\n' // 3 Added（多字）
      'ngsl_2809_0004,can you  help me,\n' // 4 同句＋新字 → Updated（併入第 2 列）
      'ngsl_2809_0001,I need more time!,\n' // 5 與內建句子相同 → Built-in match
      'ngsl_9999_0000,Hello there.,你好。\n' // 6 Invalid Word ID
      'custom_0_7,Bare custom id.,\n' // 7 自訂字未加教材 → Invalid Word ID
      ',No word id.,\n' // 8 Invalid Row
      'ngsl_2809_0000,,翻譯\n' // 9 Invalid Row
      '\n'; // 空白列略過

  test('mixed file produces exact counts', () async {
    final repo = newRepo();
    final r = await importer(repo).importCsv(mixed, translationLocale: 'zh-TW');
    expect(r.added, 2);
    expect(r.updated, 1);
    expect(r.duplicate, 0);
    expect(r.builtInMatches, [5]);
    expect(r.conflicts, isEmpty);
    expect(r.noTranslationRows, [4, 5]);
    expect(r.invalidWordIds.map((e) => e.row), [6, 7]);
    expect(r.invalidWordIds.first.wordIds, ['ngsl_9999_0000']);
    expect(r.invalidRows.map((e) => '${e.row}:${e.reason.name}'),
        ['8:missingWordId', '9:missingSentence']);

    final help = repo.imported.firstWhere((s) => s.sentenceText == 'Can you help me?');
    expect(help.wordIds, ['ngsl_2809_0002', 'ngsl_2809_0004']);
    expect(help.datasetId, 'pe_import');
    expect(help.targetLanguage, 'en-US');
    expect(help.translations, {'zh-TW': '你可以幫我嗎？'});
    expect(help.id,
        SentenceIdFactory.importedIdFor(SentenceIdFactory.dedupKey('en-US', 'Can you help me?')));
    expect(repo.sentencesForWord('custom_1/custom_0_7').single.sentenceText,
        'I like apples.');
    // 內建句子不被修改
    expect(repo.byId('pe_core_000001')!.wordIds, ['ngsl_2809_0001']);
  });

  test('re-importing the same file is idempotent', () async {
    final repo = newRepo();
    await importer(repo).importCsv(mixed, translationLocale: 'zh-TW');
    final before = await File('${dir.path}/imported_sentences.json').readAsString();

    final again = await importer(repo).importCsv(mixed, translationLocale: 'zh-TW');
    expect(again.added, 0);
    expect(again.updated, 0);
    expect(again.duplicate, 3); // 第 2、3、4 列
    expect(again.builtInMatches, [5]);
    expect(await File('${dir.path}/imported_sentences.json').readAsString(), before);

    // 重新啟動（新的 repository 從磁碟載入）再匯入，結果仍相同
    final reloaded = newRepo();
    final third = await importer(reloaded).importCsv(mixed, translationLocale: 'zh-TW');
    expect(third.added, 0);
    expect(third.updated, 0);
    expect(reloaded.imported.length, 2);
  });

  test('Updated: new word link or new translation locale; different text is a Conflict',
      () async {
    final repo = newRepo();
    await importer(repo).importCsv(
        'word_id,sentence,sentence_translation\nngsl_2809_0002,Can you help me?,你可以幫我嗎？\n',
        translationLocale: 'zh-TW');
    final id = repo.imported.single.id;

    final r = await importer(repo).importCsv(
        'word_id,sentence,sentence_translation,translation_locale\n'
        'ngsl_2809_0003,Can you help me?,,\n' // 新連結 → Updated
        'ngsl_2809_0002,Can you help me?,手伝ってくれますか？,ja\n' // 新語言 → Updated
        'ngsl_2809_0002,Can you help me?,不同的翻譯,zh-TW\n', // 已有 zh-TW → Conflict
        translationLocale: 'zh-TW');
    expect(r.added, 0);
    expect(r.updated, 2);
    expect(r.duplicate, 0);
    expect(r.conflicts.map((c) => '${c.row}:${c.languages}'), ['4:[zh-TW]']);
    final s = repo.imported.single;
    expect(s.id, id); // ID 不變
    expect(s.wordIds, ['ngsl_2809_0002', 'ngsl_2809_0003']);
    expect(s.translations, {'zh-TW': '你可以幫我嗎？', 'ja': '手伝ってくれますか？'});
  });

  test('optional columns, column order, delimiter and BOM', () async {
    final repo = newRepo();
    final r = await importer(repo).importCsv(
        '﻿sentence;WORD_ID;sentence_translation;level;category;target_language\r\n'
        'How are you?;ngsl_2809_0000;你好嗎？;A1;daily;en-GB\r\n',
        translationLocale: 'zh-TW');
    expect(r.added, 1);
    final s = repo.imported.single;
    expect(s.level, 'A1');
    expect(s.category, 'daily');
    expect(s.targetLanguage, 'en-GB');
    expect(s.patternId, isNull);
  });

  test('quoted fields with commas and line breaks', () async {
    final repo = newRepo();
    final r = await importer(repo).importCsv(
        'word_id,sentence,sentence_translation\n'
        'ngsl_2809_0000,"Well, I think so.","嗯，\n我想是的。"\n',
        translationLocale: 'zh-TW');
    expect(r.added, 1);
    expect(repo.imported.single.sentenceText, 'Well, I think so.');
    expect(repo.imported.single.translations['zh-TW'], '嗯，\n我想是的。');
  });

  test('file-level errors', () {
    final imp = importer(newRepo());
    expect(
        () => imp.evaluate('', translationLocale: 'zh-TW'),
        throwsA(isA<SentenceCsvFileException>()
            .having((e) => e.error, 'error', SentenceCsvFileError.empty)));
    expect(
        () => imp.evaluate('word,translation\napple,蘋果\n', translationLocale: 'zh-TW'),
        throwsA(isA<SentenceCsvFileException>().having((e) => e.missingColumns,
            'missing', ['word_id', 'sentence', 'sentence_translation'])));
  });

  test('nothing valid → no file written', () async {
    final repo = newRepo();
    final r = await importer(repo).importCsv(
        'word_id,sentence,sentence_translation\nbad_id,Hi.,\n',
        translationLocale: 'zh-TW');
    expect(r.hasChanges, isFalse);
    expect(await File('${dir.path}/imported_sentences.json').exists(), isFalse);
  });

  test('ID collision with an existing imported sentence gets a suffix and stays stable',
      () async {
    final repo = newRepo();
    await repo.load();
    final key = SentenceIdFactory.dedupKey('en-US', 'Brand new line.');
    final base = SentenceIdFactory.importedIdFor(key);
    // 模擬：既有匯入句子剛好佔用了這個 ID（不同內容）
    await repo.replaceImported([
      Sentence(
          id: base,
          wordIds: const ['ngsl_2809_0001'],
          datasetId: 'pe_import',
          targetLanguage: 'en-US',
          sentenceText: 'Some other sentence.'),
    ]);
    final csv = 'word_id,sentence,sentence_translation\nngsl_2809_0000,Brand new line.,\n';
    final r = await importer(repo).importCsv(csv, translationLocale: 'zh-TW');
    expect(r.added, 1);
    final added = repo.imported.firstWhere((s) => s.sentenceText == 'Brand new line.');
    expect(added.id, '$base-2');
    final again = await importer(repo).importCsv(csv, translationLocale: 'zh-TW');
    expect(again.added, 0);
    expect(repo.imported.where((s) => s.sentenceText == 'Brand new line.').single.id,
        '$base-2');
  });

  test('write failure keeps previous data', () async {
    final repo = newRepo();
    await importer(repo).importCsv(
        'word_id,sentence,sentence_translation\nngsl_2809_0000,First.,\n',
        translationLocale: 'zh-TW');
    final file = File('${dir.path}/imported_sentences.json');
    final before = await file.readAsString();
    // 讓 .tmp 路徑變成資料夾，迫使寫入失敗
    await Directory('${file.path}.tmp').create();
    await expectLater(
        importer(repo).importCsv(
            'word_id,sentence,sentence_translation\nngsl_2809_0001,Second.,\n',
            translationLocale: 'zh-TW'),
        throwsA(anything));
    expect(await file.readAsString(), before);
  });
}
