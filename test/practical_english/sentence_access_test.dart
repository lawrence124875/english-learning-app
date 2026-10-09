import 'package:english_learning_app/domain/models/word_item.dart';
import 'package:english_learning_app/practical_english/domain/models/sentence.dart';
import 'package:english_learning_app/practical_english/domain/services/sentence_access.dart';
import 'package:english_learning_app/practical_english/domain/services/word_ref_index.dart';
import 'package:flutter_test/flutter_test.dart';

// 免費版規則 A（SPEC §12）：同一個目標詞彙在任一份清單已解鎖就算解鎖。

/// 建立 [words.length] 字的內建教材，ID 為 `<id>_0000` 起。
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
            translations: const {},
          ),
      ],
    );

// NGSL 6 字：免費前 2 個（the、be）。
final _ngsl = _list('ngsl_2809', ['the', 'be', 'such', 'need', 'help', 'time']);
// 口語 6 字：免費前 2 個（such、help）。
final _spoken =
    _list('ngsl_spoken_720', ['such', 'Help ', 'the', 'be', 'time', 'need']);
// 自訂日文教材：免費前 1 個；「such」只是同拼字的別種語言項目。
final _japanese = WordDataset(
  id: 'custom_1',
  name: 'ja',
  shortName: 'ja',
  wordLocale: 'ja-JP',
  items: const [
    WordItem(id: 'c0', word: 'such', translations: {}),
    WordItem(id: 'c1', word: 'time', translations: {}),
    WordItem(id: 'c2', word: 'need', translations: {}),
  ],
);

final _index = WordRefIndex.build([_ngsl, _spoken, _japanese]);

int _free(WordDataset d) => d.items.length ~/ 3;
int _premium(WordDataset d) => d.items.length;

Sentence _s(List<String> refs) => Sentence(
      id: 'pe_core_000001',
      wordIds: refs,
      datasetId: 'pe_core',
      targetLanguage: 'en-US',
      sentenceText: 'Test.',
    );

void main() {
  final free = SentenceAccess(_index, _free);
  final premium = SentenceAccess(_index, _premium);

  test('1. all target words unlocked → accessible', () {
    final s = _s(['ngsl_2809_0000', 'ngsl_2809_0001']);
    expect(free.isAccessible(s), isTrue);
    expect(free.isLocked(s), isFalse);
  });

  test('2. one target word locked → locked', () {
    final s = _s(['ngsl_2809_0000', 'ngsl_2809_0003']); // the + need
    expect(free.isAccessible(s), isFalse);
    expect(free.isLocked(s), isTrue);
  });

  test('3. same word unlocked in another list → accessible', () {
    // such：NGSL index 2（鎖）、口語 index 0（解鎖）。
    final s = _s(['ngsl_2809_0002', 'ngsl_spoken_720_0000']);
    expect(free.isAccessible(s), isTrue);
    // 大小寫與前後空白不同（"help" / "Help "）仍是同一個詞彙。
    expect(free.isAccessible(_s(['ngsl_2809_0004', 'ngsl_spoken_720_0001'])),
        isTrue);
  });

  test('3b. same word locked in every linked list → locked', () {
    // need：NGSL index 3、口語 index 5，都鎖。
    expect(free.isAccessible(_s(['ngsl_2809_0003', 'ngsl_spoken_720_0005'])),
        isFalse);
  });

  test('3c. only refs listed in wordIds count (no runtime linking)', () {
    // such 在口語清單已解鎖，但這句只連到 NGSL 的 such → 仍鎖住。
    expect(free.isAccessible(_s(['ngsl_2809_0002'])), isFalse);
  });

  test('3d. same spelling in a different source language is a different word',
      () {
    // such（日文自訂教材 index 0，解鎖）不能替英文 such（NGSL，鎖）解鎖。
    expect(free.isAccessible(_s(['ngsl_2809_0002', 'custom_1/c0'])), isFalse);
  });

  test('4. several target words: each must be unlocked via any of its refs',
      () {
    // such（口語解鎖）＋ help（口語解鎖）＋ the（NGSL 解鎖）→ 可學。
    final ok = _s([
      'ngsl_2809_0002', 'ngsl_spoken_720_0000', //
      'ngsl_2809_0004', 'ngsl_spoken_720_0001',
      'ngsl_2809_0000', 'ngsl_spoken_720_0002',
    ]);
    expect(free.isAccessible(ok), isTrue);
    // 再加上 time（NGSL index 5、口語 index 4，都鎖）→ 整句鎖住。
    final locked =
        _s([...ok.wordIds, 'ngsl_2809_0005', 'ngsl_spoken_720_0004']);
    expect(free.isAccessible(locked), isFalse);
    expect(free.isLocked(locked), isTrue);
  });

  test('5. premium → every resolvable sentence accessible', () {
    final s = _s(['ngsl_2809_0003', 'ngsl_2809_0005', 'ngsl_spoken_720_0005']);
    expect(premium.isAccessible(s), isTrue);
    expect(premium.isLocked(s), isFalse);
  });

  test('6. invalid or unresolvable WordRef → hidden, not counted as locked', () {
    // 同詞彙另一個 ref 已解鎖也不行：無法對應的 ref 讓整句不顯示（SPEC §4）。
    for (final access in [free, premium]) {
      final s = _s(['ngsl_spoken_720_0000', 'ngsl_2809_9999']);
      expect(access.isResolvable(s), isFalse);
      expect(access.isAccessible(s), isFalse);
      expect(access.isLocked(s), isFalse);
      expect(access.isAccessible(_s(['custom_deleted/c0'])), isFalse);
      expect(access.isAccessible(_s([])), isFalse);
    }
  });
}
