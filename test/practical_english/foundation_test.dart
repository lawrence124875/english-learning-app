import 'dart:convert';
import 'dart:io';

import 'package:english_learning_app/domain/models/word_item.dart';
import 'package:english_learning_app/practical_english/data/json_file_store.dart';
import 'package:english_learning_app/practical_english/data/sentence_repository.dart';
import 'package:english_learning_app/practical_english/domain/models/sentence.dart';
import 'package:english_learning_app/practical_english/domain/models/word_ref.dart';
import 'package:english_learning_app/practical_english/domain/services/sentence_id_factory.dart';
import 'package:english_learning_app/practical_english/domain/services/word_ref_index.dart';
import 'package:flutter_test/flutter_test.dart';

WordItem _w(String id, String word) =>
    WordItem(id: id, word: word, translations: const {});

void main() {
  group('Fnv1a64', () {
    // 期望值以獨立的 Python 實作計算，確保跨平台結果一致。
    test('matches reference values', () {
      expect(Fnv1a64.hex(''), 'cbf29ce484222325');
      expect(Fnv1a64.hex('a'), 'af63dc4c8601ec8c');
      expect(Fnv1a64.hex('en-US\u0001i need more time'), '36c1fb69e940acb3');
    });
  });

  group('SentenceIdFactory', () {
    test('normalize collapses whitespace, quotes, trailing punctuation, case',
        () {
      expect(SentenceIdFactory.normalize('  I  need\tmore time.  '),
          'i need more time');
      expect(SentenceIdFactory.normalize('It’s fine!?'), "it's fine");
      expect(SentenceIdFactory.normalize('我需要時間。'), '我需要時間');
    });

    test('imported id is stable and derived from dedupKey', () {
      final key = SentenceIdFactory.dedupKey('en-US', 'I need more time.');
      expect(key, 'en-US\u0001i need more time');
      expect(SentenceIdFactory.importedIdFor(key), 'imp_36c1fb69e940acb3');
      // 不同寫法、同一句 → 同一個 ID
      final key2 = SentenceIdFactory.dedupKey('en-US', ' i NEED more  time ');
      expect(SentenceIdFactory.importedIdFor(key2), 'imp_36c1fb69e940acb3');
      // 不同語言 → 不同 ID
      expect(
          SentenceIdFactory.importedIdFor(
              SentenceIdFactory.dedupKey('en-GB', 'I need more time.')),
          isNot('imp_36c1fb69e940acb3'));
    });

    test('assign returns existing id and resolves collisions with suffix', () {
      final idByKey = <String, String>{};
      final keyById = <String, String>{};
      final key = SentenceIdFactory.dedupKey('en-US', 'Hello');
      final base = SentenceIdFactory.importedIdFor(key);
      // 模擬碰撞：base ID 已被另一個 dedupKey 佔用。
      keyById[base] = 'other-key';
      final id1 = SentenceIdFactory.assign(key,
          idByKey: idByKey, keyById: keyById);
      expect(id1, '$base-2');
      // 再次指派同一個 key → 同一個 ID（冪等）
      final id2 = SentenceIdFactory.assign(key,
          idByKey: idByKey, keyById: keyById);
      expect(id2, id1);
    });

    test('built-in and imported prefixes never overlap', () {
      expect(SentenceIdFactory.builtInPrefix,
          isNot(startsWith(SentenceIdFactory.importedPrefix)));
      expect(SentenceIdFactory.importedPrefix,
          isNot(startsWith(SentenceIdFactory.builtInPrefix)));
    });
  });

  group('WordRef / WordRefIndex', () {
    final builtIn = WordDataset(
      id: 'ngsl_2809',
      name: 'NGSL',
      shortName: 'NGSL',
      builtIn: true,
      items: [_w('ngsl_2809_0000', 'the'), _w('ngsl_2809_0001', 'be')],
    );
    // 兩份自訂教材含有相同的 WordItem.id
    final customA = WordDataset(
        id: 'custom_1', name: 'A', shortName: 'A',
        items: [_w('custom_1_99', 'apple')]);
    final customB = WordDataset(
        id: 'custom_2', name: 'B', shortName: 'B',
        items: [_w('custom_1_99', 'banana')]);

    test('built-in uses WordItem.id, custom is qualified', () {
      expect(WordRef.of(builtIn, builtIn.items[1]), 'ngsl_2809_0001');
      expect(WordRef.of(customA, customA.items[0]), 'custom_1/custom_1_99');
      expect(WordRef.isQualified('custom_1/custom_1_99'), isTrue);
      expect(WordRef.datasetIdOf('custom_1/custom_1_99'), 'custom_1');
      expect(WordRef.datasetIdOf('ngsl_2809_0001'), isNull);
    });

    test('well-formed check', () {
      expect(WordRef.isWellFormed('ngsl_2809_0001'), isTrue);
      expect(WordRef.isWellFormed('a/b'), isTrue);
      expect(WordRef.isWellFormed(''), isFalse);
      expect(WordRef.isWellFormed(' a'), isFalse);
      expect(WordRef.isWellFormed('a/'), isFalse);
      expect(WordRef.isWellFormed('a/b/c'), isFalse);
    });

    test('index resolves colliding custom ids to the right dataset', () {
      final index = WordRefIndex.build([builtIn, customA, customB]);
      expect(index.length, 4);
      expect(index.resolve('custom_1/custom_1_99')!.item.word, 'apple');
      expect(index.resolve('custom_2/custom_1_99')!.item.word, 'banana');
      expect(index.resolve('ngsl_2809_0001')!.index, 1);
      expect(index.resolve('custom_1_99'), isNull);
    });
  });

  group('Sentence model', () {
    test('json round trip and translation fallback', () {
      const s = Sentence(
        id: 'pe_core_000001',
        wordIds: ['ngsl_2809_0001'],
        datasetId: 'pe_core',
        targetLanguage: 'en-US',
        sentenceText: 'I need more time.',
        translations: {'zh-TW': '我需要更多時間。'},
        level: 'A1',
      );
      final back = Sentence.fromJson(
          jsonDecode(jsonEncode(s.toJson())) as Map<String, dynamic>);
      expect(back.id, s.id);
      expect(back.wordIds, s.wordIds);
      expect(back.level, 'A1');
      expect(back.patternId, isNull);
      expect(back.translationFor('ja'), '我需要更多時間。'); // 退回 zh-TW
      expect(back.translationFor('zh-TW'), '我需要更多時間。');
      expect(const Sentence(
              id: 'x', wordIds: ['a'], datasetId: 'd',
              targetLanguage: 'en-US', sentenceText: 't')
          .translationFor('ja'), isNull);
    });

    test('rejects missing required fields', () {
      expect(() => Sentence.fromJson({'id': 'x'}), throwsFormatException);
      expect(
          () => Sentence.fromJson({
                'id': 'x', 'wordIds': [], 'datasetId': 'd',
                'targetLanguage': 'en-US', 'sentenceText': 't'
              }),
          throwsFormatException);
    });
  });

  group('JsonFileStore', () {
    late Directory dir;
    setUp(() async => dir = await Directory.systemTemp.createTemp('pe_store'));
    tearDown(() async => dir.delete(recursive: true));

    test('missing file reads as null without error', () async {
      var errors = 0;
      final store = JsonFileStore(File('${dir.path}/a.json'),
          onError: (_, __) => errors++);
      expect(await store.read(), isNull);
      expect(errors, 0);
    });

    test('atomic write keeps previous version as .bak', () async {
      final f = File('${dir.path}/a.json');
      final store = JsonFileStore(f);
      await store.write({'v': 1});
      await store.write({'v': 2});
      expect(await store.read(), {'v': 2});
      expect(jsonDecode(await File('${f.path}.bak').readAsString()), {'v': 1});
      expect(await File('${f.path}.tmp').exists(), isFalse);
    });

    test('corrupted main file falls back to .bak', () async {
      final f = File('${dir.path}/a.json');
      final store = JsonFileStore(f);
      await store.write({'v': 1});
      await store.write({'v': 2});
      await f.writeAsString('{broken');
      expect(await store.read(), {'v': 1});
    });

    test('both corrupted → null, error reported, bad files kept', () async {
      final f = File('${dir.path}/a.json');
      await f.writeAsString('{broken');
      await File('${f.path}.bak').writeAsString('also broken');
      var errors = 0;
      final store = JsonFileStore(f, onError: (_, __) => errors++);
      expect(await store.read(), isNull);
      expect(errors, 1);
      final names = dir.listSync().map((e) => e.uri.pathSegments.last);
      expect(names.where((n) => n.contains('.corrupt-')).length, 2);
      expect(await f.exists(), isFalse);
    });

    test('debounced writes coalesce and flush writes the latest', () async {
      final f = File('${dir.path}/a.json');
      final store =
          JsonFileStore(f, debounce: const Duration(milliseconds: 50));
      store.scheduleWrite({'v': 1});
      store.scheduleWrite({'v': 2});
      expect(store.hasPendingWrite, isTrue);
      await store.flush();
      expect(store.hasPendingWrite, isFalse);
      expect(await store.read(), {'v': 2});
      expect(await File('${f.path}.bak').exists(), isFalse); // 只寫了一次
    });
  });

  group('SentenceRepository', () {
    late Directory dir;
    setUp(() async => dir = await Directory.systemTemp.createTemp('pe_repo'));
    tearDown(() async => dir.delete(recursive: true));

    String corpus(List<Map<String, dynamic>> sentences) =>
        jsonEncode({'schema': 1, 'datasetId': 'pe_core', 'sentences': sentences});

    Map<String, dynamic> s(String id, List<String> words) => {
          'id': id,
          'wordIds': words,
          'datasetId': 'pe_core',
          'targetLanguage': 'en-US',
          'sentenceText': 'text $id',
          'translations': {'zh-TW': '翻譯 $id'},
        };

    test('loads built-in, skips invalid entries, builds reverse index',
        () async {
      final repo = SentenceRepository(
        loadBuiltInAsset: () async => corpus([
          s('pe_core_000001', ['w1', 'w2']),
          s('pe_core_000002', ['w2']),
          {'id': 'broken'},
        ]),
        baseDir: () async => dir,
      );
      await repo.load();
      expect(repo.length, 2);
      expect(repo.skippedEntries, 1);
      expect(repo.sentencesForWord('w2').map((e) => e.id),
          ['pe_core_000001', 'pe_core_000002']);
      expect(repo.sentencesForWord('w1').single.id, 'pe_core_000001');
      expect(repo.sentencesForWord('none'), isEmpty);
      expect(repo.wordRefsWithSentences.toSet(), {'w1', 'w2'});
    });

    test('missing asset and no imported file → empty, no error', () async {
      final repo = SentenceRepository(
          loadBuiltInAsset: () async => null, baseDir: () async => dir);
      await repo.load();
      expect(repo.length, 0);
    });

    test('imported sentences persist and are indexed after reload', () async {
      final repo = SentenceRepository(
        loadBuiltInAsset: () async => corpus([s('pe_core_000001', ['w1'])]),
        baseDir: () async => dir,
      );
      await repo.load();
      await repo.replaceImported([
        Sentence.fromJson(s('imp_0000000000000001', ['w1', 'w3'])),
      ]);
      expect(repo.sentencesForWord('w1').length, 2);

      final reloaded = SentenceRepository(
        loadBuiltInAsset: () async => corpus([s('pe_core_000001', ['w1'])]),
        baseDir: () async => dir,
      );
      await reloaded.load();
      expect(reloaded.imported.single.id, 'imp_0000000000000001');
      expect(reloaded.sentencesForWord('w3').single.id,
          'imp_0000000000000001');
    });

    test('duplicate id: built-in wins over imported', () async {
      final repo = SentenceRepository(
        loadBuiltInAsset: () async => corpus([s('same', ['w1'])]),
        baseDir: () async => dir,
      );
      await repo.load();
      await repo.replaceImported([Sentence.fromJson(s('same', ['w9']))]);
      expect(repo.length, 1);
      expect(repo.byId('same')!.wordIds, ['w1']);
      expect(repo.sentencesForWord('w9'), isEmpty);
    });

    test('bundled pe_core.json asset is valid', () async {
      final raw = await File(SentenceRepository.builtInAssetPath).readAsString();
      final parsed = parseSentenceFile(raw);
      expect(parsed.skipped, 0);
    });
  });
}
