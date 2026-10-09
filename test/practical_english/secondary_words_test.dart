import 'dart:io';

import 'package:english_learning_app/domain/models/word_item.dart';
import 'package:english_learning_app/practical_english/data/sentence_repository.dart';
import 'package:english_learning_app/practical_english/domain/models/sentence.dart';
import 'package:english_learning_app/practical_english/domain/models/word_learning_state.dart';
import 'package:english_learning_app/practical_english/domain/services/coverage_calculator.dart';
import 'package:english_learning_app/practical_english/domain/services/sentence_access.dart';
import 'package:english_learning_app/practical_english/domain/services/sentence_selector.dart';
import 'package:english_learning_app/practical_english/domain/services/word_ref_index.dart';
import 'package:flutter_test/flutter_test.dart';

// SPEC §4、§6.1、§9（2026-10-09）：次要詞 secondaryWordIds 與已刪除自訂教材。

WordDataset _list(String id, List<String> words) => WordDataset(
      id: id,
      name: id,
      shortName: id,
      builtIn: true,
      items: [
        for (var i = 0; i < words.length; i++)
          WordItem(
              id: '${id}_${'$i'.padLeft(4, '0')}',
              word: words[i],
              translations: const {}),
      ],
    );

final _ngsl = _list('ngsl_2809', ['the', 'be', 'and', 'of', 'to', 'door']);
final _custom = WordDataset(
  id: 'custom_2',
  name: 'mine',
  shortName: 'mine',
  items: const [WordItem(id: 'c0', word: 'close', translations: {})],
);
final _index = WordRefIndex.build([_ngsl, _custom]);

Sentence _s(String id, List<String> primary,
        [List<String> secondary = const []]) =>
    Sentence(
      id: id,
      wordIds: primary,
      secondaryWordIds: secondary,
      datasetId: 'pe_core',
      targetLanguage: 'en-US',
      sentenceText: 'Please close the door $id.',
    );

int _free(WordDataset d) => d.items.length ~/ 3; // the, be
int _premium(WordDataset d) => d.items.length;

void main() {
  group('model', () {
    test('json round trip keeps secondaryWordIds; omitted when empty', () {
      final s = _s('a', ['ngsl_2809_0000'], ['ngsl_2809_0005']);
      final json = s.toJson();
      expect(json['secondaryWordIds'], ['ngsl_2809_0005']);
      expect(Sentence.fromJson(json).secondaryWordIds, ['ngsl_2809_0005']);
      expect(
          _s('b', ['ngsl_2809_0000']).toJson().containsKey('secondaryWordIds'),
          isFalse);
    });

    test('older data without the field still loads', () {
      final s = Sentence.fromJson({
        'id': 'pe_core_000001',
        'wordIds': ['ngsl_2809_0000'],
        'datasetId': 'pe_core',
        'targetLanguage': 'en-US',
        'sentenceText': 'Hi.',
      });
      expect(s.secondaryWordIds, isEmpty);
    });

    test('allWordIds dedups; a ref in both lists counts as primary only', () {
      final s =
          _s('a', ['ngsl_2809_0000'], ['ngsl_2809_0005', 'ngsl_2809_0000']);
      expect(s.allWordIds, ['ngsl_2809_0000', 'ngsl_2809_0005']);
      expect(s.secondaryOnlyWordIds, ['ngsl_2809_0005']);
    });
  });

  group('access and coverage ignore secondary words', () {
    final free = SentenceAccess(_index, _free);

    test('locked secondary word does not lock the sentence', () {
      // the（免費）＋ door（鎖住，次要詞）→ 可學
      final s = _s('a', ['ngsl_2809_0000'], ['ngsl_2809_0005']);
      expect(free.isAccessible(s), isTrue);
    });

    test('unresolvable secondary word does not hide the sentence', () {
      final s = _s('a', ['ngsl_2809_0000'], ['ngsl_2809_9999', 'gone/x']);
      expect(free.isResolvable(s), isTrue);
      expect(free.isAccessible(s), isTrue);
    });

    test('coverage counts primary words only', () {
      final c = PracticalEnglishCoverage.compute(
        index: _index,
        sentences: [
          _s('a', ['ngsl_2809_0000'], ['ngsl_2809_0005', 'ngsl_2809_0004']),
        ],
        access: SentenceAccess(_index, _premium),
        stateOf: (_) => const WordLearningState(),
      );
      expect(c.wordsWithSentences, 1);
    });
  });

  group('deleted custom dataset (SPEC §4)', () {
    final premium = SentenceAccess(_index, _premium);

    test('refs to a deleted custom dataset are ignored when others resolve',
        () {
      final s = _s('a', ['custom_1/c0', 'custom_2/c0']);
      expect(premium.isResolvable(s), isTrue);
      expect(premium.isAccessible(s), isTrue);
      expect(premium.effectiveWordIds(s), ['custom_2/c0']);
    });

    test('only refs to deleted datasets → hidden', () {
      expect(premium.isResolvable(_s('a', ['custom_1/c0'])), isFalse);
    });

    test('missing word in an existing dataset still hides the sentence', () {
      expect(premium.isResolvable(_s('a', ['custom_2/zz', 'ngsl_2809_0000'])),
          isFalse);
    });

    test('unknown built-in id still hides the sentence', () {
      expect(
          premium.isResolvable(_s('a', ['ngsl_2809_9999', 'ngsl_2809_0000'])),
          isFalse);
    });

    test('free rule judged by remaining refs', () {
      final free = SentenceAccess(_index, _free);
      // custom_2 只有 1 字，免費 0 個 → 鎖住；刪除的 custom_1 不影響結果
      expect(free.isLocked(_s('a', ['custom_1/c0', 'custom_2/c0'])), isTrue);
      expect(free.isAccessible(_s('b', ['custom_1/c0', 'ngsl_2809_0000'])),
          isTrue);
    });
  });

  group('selector uses primary + secondary for weak modes', () {
    WordLearningState Function(String) states(Set<String> weak) =>
        (ref) => WordLearningState(weak: weak.contains(ref));

    test('weak secondary word qualifies for weak-only and adds score', () {
      final a = _s('a', ['ngsl_2809_0000'], ['ngsl_2809_0005']);
      final b = _s('b', ['ngsl_2809_0001']);
      final stateOf = states({'ngsl_2809_0005'});
      expect(
          SentenceSelector.order([a, b], LearningMode.weakOnly, stateOf)
              .map((s) => s.id),
          ['a']);
      expect(SentenceSelector.score(a, stateOf), 3 + 1);
      expect(
          SentenceSelector.order([b, a], LearningMode.weakPriority, stateOf)
              .first
              .id,
          'a');
    });

    test('unresolvable refs are not scored when isKnown is given', () {
      final a = _s('a', ['ngsl_2809_0000'], ['ngsl_2809_9999']);
      expect(
          SentenceSelector.score(a, (_) => const WordLearningState(),
              isKnown: _index.contains),
          1);
    });
  });

  test('reverse index finds a sentence through its secondary words', () async {
    final dir = await Directory.systemTemp.createTemp('pe_secondary');
    addTearDown(() => dir.delete(recursive: true));
    final repo = SentenceRepository(
      loadBuiltInAsset: () async =>
          '{"schema":1,"sentences":[{"id":"pe_core_000001","wordIds":["ngsl_2809_0000"],'
          '"secondaryWordIds":["ngsl_2809_0005"],"datasetId":"pe_core",'
          '"targetLanguage":"en-US","sentenceText":"Close the door."}]}',
      baseDir: () async => dir,
    );
    await repo.load();
    expect(repo.sentencesForWord('ngsl_2809_0005').single.id, 'pe_core_000001');
    expect(repo.sentencesForWord('ngsl_2809_0000').single.id, 'pe_core_000001');
  });
}
