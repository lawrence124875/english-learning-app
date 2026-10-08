import 'package:csv/csv.dart';

import '../domain/models/sentence.dart';
import '../domain/models/word_ref.dart';
import '../domain/services/sentence_id_factory.dart';
import '../domain/services/word_ref_index.dart';
import 'sentence_repository.dart';

/// 整份檔案無法匯入的原因（畫面層依介面語言翻譯）。
enum SentenceCsvFileError { empty, parseFailed, missingRequiredColumns }

class SentenceCsvFileException implements Exception {
  final SentenceCsvFileError error;

  /// [SentenceCsvFileError.missingRequiredColumns] 時列出缺少的欄位。
  final List<String> missingColumns;

  const SentenceCsvFileException(this.error, [this.missingColumns = const []]);

  @override
  String toString() => 'SentenceCsvFileException($error, $missingColumns)';
}

/// 單列被判為 Invalid Row 的原因。
enum InvalidRowReason { missingWordId, missingSentence }

class InvalidRow {
  /// CSV 列號（表頭是第 1 列）。
  final int row;
  final InvalidRowReason reason;
  const InvalidRow(this.row, this.reason);
}

class InvalidWordIdRow {
  final int row;

  /// 無法對應的 word_id（原樣）。
  final List<String> wordIds;
  const InvalidWordIdRow(this.row, this.wordIds);
}

/// 匯入結果摘要（SPEC §8.3）。以「列」計數：每一個非空白資料列
/// 剛好落在 Added／Updated／Duplicate／Invalid Word ID／Invalid Row 其中一類。
class SentenceImportResult {
  final int added;
  final int updated;
  final int duplicate;
  final List<InvalidWordIdRow> invalidWordIds;
  final List<InvalidRow> invalidRows;

  /// 合併後完整的匯入句子清單（寫檔用）。
  final List<Sentence> importedSentences;

  const SentenceImportResult({
    required this.added,
    required this.updated,
    required this.duplicate,
    required this.invalidWordIds,
    required this.invalidRows,
    required this.importedSentences,
  });

  bool get hasChanges => added > 0 || updated > 0;
}

/// CSV Format B 句子匯入（SPEC §8）。
///
/// ```
/// word_id,sentence,sentence_translation[,target_language,translation_locale,level,category]
/// ```
/// - 必須有表頭；欄位依名稱對應（不分大小寫、順序不限）。
/// - `word_id` 可放多個 WordRef，以 `|` 分隔。
/// - 整份檔案先在記憶體驗證與合併，最後一次原子寫入；寫入失敗時原資料不變。
/// - 不呼叫任何 AI。
class SentenceCsvImporter {
  static const importDatasetId = 'pe_import';
  static const defaultTargetLanguage = 'en-US';
  static const wordIdSeparator = '|';

  static const colWordId = 'word_id';
  static const colSentence = 'sentence';
  static const colTranslation = 'sentence_translation';
  static const colTargetLanguage = 'target_language';
  static const colTranslationLocale = 'translation_locale';
  static const colLevel = 'level';
  static const colCategory = 'category';
  static const requiredColumns = [colWordId, colSentence, colTranslation];

  final SentenceRepository _repository;
  final WordRefIndex _wordIndex;

  SentenceCsvImporter({
    required SentenceRepository repository,
    required WordRefIndex wordIndex,
  })  : _repository = repository,
        _wordIndex = wordIndex;

  /// 驗證並合併；有新增或更新時寫檔。[translationLocale] 是匯入畫面選的
  /// 預設翻譯語言（列上沒有 `translation_locale` 時使用）。
  Future<SentenceImportResult> importCsv(String csvContent,
      {required String translationLocale}) async {
    await _repository.load();
    final result = evaluate(csvContent, translationLocale: translationLocale);
    if (result.hasChanges) {
      await _repository.replaceImported(result.importedSentences);
    }
    return result;
  }

  /// 只驗證與合併，不寫檔（給預覽與測試用）。
  SentenceImportResult evaluate(String csvContent,
      {required String translationLocale}) {
    final rows = _parseRows(csvContent);
    final header = [for (final c in rows.first) c.toString().trim().toLowerCase()];
    final missing = requiredColumns.where((c) => !header.contains(c)).toList();
    if (missing.isNotEmpty) {
      throw SentenceCsvFileException(
          SentenceCsvFileError.missingRequiredColumns, missing);
    }
    int col(String name) => header.indexOf(name);
    final iWordId = col(colWordId);
    final iSentence = col(colSentence);
    final iTranslation = col(colTranslation);
    final iTarget = col(colTargetLanguage);
    final iLocale = col(colTranslationLocale);
    final iLevel = col(colLevel);
    final iCategory = col(colCategory);

    // 內建句子的去重鍵：匯入不得修改內建句子，命中即 Duplicate。
    final builtInKeys = {
      for (final s in _repository.builtIn)
        SentenceIdFactory.dedupKey(s.targetLanguage, s.sentenceText)
    };

    // 既有匯入句子：dedupKey → 句子，以及 ID 對照（避免碰撞、保持 ID 穩定）。
    final order = <String>[];
    final byKey = <String, Sentence>{};
    final idByKey = <String, String>{};
    final keyById = <String, String>{};
    for (final s in _repository.imported) {
      final key = SentenceIdFactory.dedupKey(s.targetLanguage, s.sentenceText);
      if (byKey.containsKey(key)) continue;
      order.add(key);
      byKey[key] = s;
      idByKey[key] = s.id;
      keyById[s.id] = key;
    }
    // 內建 ID 也列入佔用，確保匯入 ID 絕不與任何既有 ID 相同。
    for (final s in _repository.builtIn) {
      keyById.putIfAbsent(s.id, () => '\u0000builtin:${s.id}');
    }

    var added = 0, updated = 0, duplicate = 0;
    final invalidRows = <InvalidRow>[];
    final invalidWordIds = <InvalidWordIdRow>[];

    String cell(List<dynamic> row, int i) =>
        i >= 0 && i < row.length ? row[i].toString().trim() : '';

    for (var r = 1; r < rows.length; r++) {
      final row = rows[r];
      final rowNumber = r + 1;
      if (row.every((c) => c.toString().trim().isEmpty)) continue; // 空白列

      final sentenceText = cell(row, iSentence);
      final refs = cell(row, iWordId)
          .split(wordIdSeparator)
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (refs.isEmpty) {
        invalidRows.add(InvalidRow(rowNumber, InvalidRowReason.missingWordId));
        continue;
      }
      if (sentenceText.isEmpty) {
        invalidRows.add(InvalidRow(rowNumber, InvalidRowReason.missingSentence));
        continue;
      }
      final bad = refs
          .where((ref) => !WordRef.isWellFormed(ref) || !_wordIndex.contains(ref))
          .toList();
      if (bad.isNotEmpty) {
        invalidWordIds.add(InvalidWordIdRow(rowNumber, bad));
        continue;
      }

      final target = cell(row, iTarget).isEmpty
          ? defaultTargetLanguage
          : cell(row, iTarget);
      final locale = cell(row, iLocale).isEmpty
          ? translationLocale
          : cell(row, iLocale);
      final translation = cell(row, iTranslation);
      final key = SentenceIdFactory.dedupKey(target, sentenceText);
      final uniqueRefs = {...refs}.toList();

      if (builtInKeys.contains(key)) {
        duplicate++;
        continue;
      }

      final existing = byKey[key];
      if (existing == null) {
        final id = SentenceIdFactory.assign(key,
            idByKey: idByKey, keyById: keyById);
        byKey[key] = Sentence(
          id: id,
          wordIds: uniqueRefs,
          datasetId: importDatasetId,
          targetLanguage: target,
          sentenceText: sentenceText,
          translations: translation.isEmpty ? const {} : {locale: translation},
          level: cell(row, iLevel).isEmpty ? null : cell(row, iLevel),
          category: cell(row, iCategory).isEmpty ? null : cell(row, iCategory),
        );
        order.add(key);
        added++;
        continue;
      }

      final newRefs = uniqueRefs.where((r) => !existing.wordIds.contains(r));
      final addTranslation = translation.isNotEmpty &&
          !existing.translations.containsKey(locale);
      if (newRefs.isEmpty && !addTranslation) {
        duplicate++;
        continue;
      }
      byKey[key] = existing.copyWith(
        wordIds: [...existing.wordIds, ...newRefs],
        translations: addTranslation
            ? {...existing.translations, locale: translation}
            : existing.translations,
      );
      updated++;
    }

    return SentenceImportResult(
      added: added,
      updated: updated,
      duplicate: duplicate,
      invalidWordIds: invalidWordIds,
      invalidRows: invalidRows,
      importedSentences: List.unmodifiable([for (final k in order) byKey[k]!]),
    );
  }

  /// 與 V1 CSV 匯入相同的前處理：去 BOM、統一換行、偵測分隔符號。
  static List<List<dynamic>> _parseRows(String csvContent) {
    var content = csvContent;
    if (content.isNotEmpty && content.codeUnitAt(0) == 0xFEFF) {
      content = content.substring(1);
    }
    content = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    if (content.trim().isEmpty) {
      throw const SentenceCsvFileException(SentenceCsvFileError.empty);
    }
    final firstLine = content
        .split('\n')
        .firstWhere((l) => l.trim().isNotEmpty, orElse: () => '');
    var delimiter = ',';
    if (!firstLine.contains(',')) {
      for (final d in const ['\t', ';', '؛', '،']) {
        if (firstLine.contains(d)) {
          delimiter = d;
          break;
        }
      }
    }
    List<List<dynamic>> rows;
    try {
      rows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
          .convert(content, fieldDelimiter: delimiter);
    } catch (_) {
      throw const SentenceCsvFileException(SentenceCsvFileError.parseFailed);
    }
    // 去掉開頭的空白列，讓第一個非空白列當表頭。
    while (rows.isNotEmpty &&
        rows.first.every((c) => c.toString().trim().isEmpty)) {
      rows.removeAt(0);
    }
    if (rows.isEmpty) {
      throw const SentenceCsvFileException(SentenceCsvFileError.empty);
    }
    return rows;
  }
}
