import 'package:csv/csv.dart';

import '../domain/models/pe_language.dart';
import '../domain/models/sentence.dart';
import '../domain/models/word_ref.dart';
import '../domain/services/sentence_id_factory.dart';
import '../domain/services/word_ref_index.dart';
import 'sentence_repository.dart';

/// 整份檔案無法匯入的原因（畫面層依介面語言翻譯）。
enum SentenceCsvFileError {
  empty,
  parseFailed,
  missingRequiredColumns,

  /// `sentence_translation_<code>` 的語言代碼不在登錄表（SPEC §8.1）。
  invalidTranslationColumn,

  /// 兩個翻譯欄正規化後是同一種語言。
  duplicateTranslationColumn,
}

class SentenceCsvFileException implements Exception {
  final SentenceCsvFileError error;

  /// 缺少的欄位，或有問題的翻譯欄（原樣）。
  final List<String> missingColumns;

  const SentenceCsvFileException(this.error, [this.missingColumns = const []]);

  /// [missingColumns] 的別名：非「缺欄」錯誤時，代表有問題的欄位。
  List<String> get columns => missingColumns;

  @override
  String toString() => 'SentenceCsvFileException($error, $missingColumns)';
}

/// 單列被判為 Invalid Row 的原因。
enum InvalidRowReason {
  missingWordId,
  missingSentence,
  invalidLocale,
  invalidTargetLanguage,
}

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

/// 翻譯衝突的列（SPEC §8.2）：與既有翻譯不同、同一檔內同句同語言有不同翻譯，
/// 或同一列的單欄與寬欄不一致。
class ConflictRow {
  final int row;

  /// 發生衝突的語言（canonical code，排序過）。
  final List<String> languages;
  const ConflictRow(this.row, this.languages);
}

/// 匯入結果摘要（SPEC §8.3）。以「列」計數：每一個非空白資料列只依
/// 最嚴重的結果算一次：Invalid Row > Invalid Word ID > Conflict >
/// Built-in match > Added > Updated > Duplicate。
class SentenceImportResult {
  final int added;
  final int updated;
  final int duplicate;
  final List<InvalidWordIdRow> invalidWordIds;
  final List<InvalidRow> invalidRows;
  final List<ConflictRow> conflicts;

  /// 對應到內建句的列號；連結與翻譯都沒有套用。
  final List<int> builtInMatches;

  /// 沒有任何翻譯的列號（警告，不是錯誤）。
  final List<int> noTranslationRows;

  /// 合併後完整的匯入句子清單（寫檔用）。
  final List<Sentence> importedSentences;

  /// 是否有寫入（新增、更新，或覆寫衝突中的翻譯）。
  final bool hasChanges;

  const SentenceImportResult({
    required this.added,
    required this.updated,
    required this.duplicate,
    required this.invalidWordIds,
    required this.invalidRows,
    this.conflicts = const [],
    this.builtInMatches = const [],
    this.noTranslationRows = const [],
    required this.importedSentences,
    bool? hasChanges,
  }) : hasChanges = hasChanges ?? (added > 0 || updated > 0);
}

/// 驗證通過、等待合併的一列。
class _Row {
  final int number;
  final String key;
  final String targetLanguage;
  final String sentenceText;
  final List<String> refs;

  /// 這列的翻譯（canonical code → 文字），已排除單欄／寬欄衝突的語言。
  final Map<String, String> translations;

  /// 這列單欄與寬欄不一致的語言。
  final Set<String> selfConflicts;
  final String? level;
  final String? category;

  _Row({
    required this.number,
    required this.key,
    required this.targetLanguage,
    required this.sentenceText,
    required this.refs,
    required this.translations,
    required this.selfConflicts,
    required this.level,
    required this.category,
  });
}

/// CSV Format B 句子匯入（SPEC §8）。
///
/// ```
/// word_id,sentence[,sentence_translation][,sentence_translation_<code>…]
///   [,target_language,translation_locale,level,category]
/// ```
/// - 必須有表頭；欄位依名稱對應（不分大小寫、順序不限）。
/// - `word_id` 可放多個 WordRef，以 `|` 分隔。
/// - 句子原文只接受英文；翻譯語言代碼經 [PeLanguages] 正規化。
/// - 先整份檔案自行比對（同句同語言有不同翻譯 → 衝突，不寫入），
///   再與已存資料比對，所以結果與列的順序無關。
/// - 整份檔案先在記憶體驗證與合併，最後一次原子寫入；寫入失敗時原資料不變。
/// - 不呼叫任何 AI。
class SentenceCsvImporter {
  static const importDatasetId = 'pe_import';
  static const defaultTargetLanguage = 'en-US';
  static const wordIdSeparator = '|';

  static const colWordId = 'word_id';
  static const colSentence = 'sentence';
  static const colTranslation = 'sentence_translation';
  static const colTranslationPrefix = 'sentence_translation_';
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

  /// 驗證並合併；有變更時寫檔。[translationLocale] 是匯入畫面選的預設翻譯
  /// 語言（列上沒有 `translation_locale` 時，單欄 `sentence_translation` 用它）。
  /// [overwrite]：與既有匯入句翻譯不同時改用 CSV 的翻譯（內建句不適用）。
  Future<SentenceImportResult> importCsv(String csvContent,
      {required String translationLocale, bool overwrite = false}) async {
    await _repository.load();
    final result = evaluate(csvContent,
        translationLocale: translationLocale, overwrite: overwrite);
    if (result.hasChanges) {
      await _repository.replaceImported(result.importedSentences);
    }
    return result;
  }

  static String _canonicalTarget(String raw) =>
      PeLanguages.canonicalTarget(raw) ?? raw;

  static Map<String, String> _canonicalTranslations(Map<String, String> t) => {
        for (final e in t.entries)
          (PeLanguages.canonicalize(e.key) ?? e.key): e.value
      };

  /// 只驗證與合併，不寫檔（給預覽與測試用）。
  SentenceImportResult evaluate(String csvContent,
      {required String translationLocale, bool overwrite = false}) {
    final defaultLocale =
        PeLanguages.canonicalize(translationLocale) ?? translationLocale;
    final rows = _parseRows(csvContent);
    final header = [
      for (final c in rows.first) c.toString().trim().toLowerCase()
    ];

    // 翻譯寬欄：表頭代碼無效或重複 → 整份檔案錯誤（不默默忽略）。
    final wide = <int, String>{};
    final badColumns = <String>[];
    final seenCodes = <String, String>{};
    final duplicateColumns = <String>[];
    for (var i = 0; i < header.length; i++) {
      final name = header[i];
      if (!name.startsWith(colTranslationPrefix)) continue;
      final raw = rows.first[i].toString().trim();
      final code =
          PeLanguages.canonicalize(name.substring(colTranslationPrefix.length));
      if (code == null) {
        badColumns.add(raw);
      } else if (seenCodes.containsKey(code)) {
        duplicateColumns.addAll([seenCodes[code]!, raw]);
      } else {
        seenCodes[code] = raw;
        wide[i] = code;
      }
    }

    final missing = [
      for (final c in const [colWordId, colSentence])
        if (!header.contains(c)) c,
      if (!header.contains(colTranslation) &&
          wide.isEmpty &&
          badColumns.isEmpty &&
          duplicateColumns.isEmpty)
        colTranslation,
    ];
    if (missing.isNotEmpty) {
      throw SentenceCsvFileException(
          SentenceCsvFileError.missingRequiredColumns, missing);
    }
    if (badColumns.isNotEmpty) {
      throw SentenceCsvFileException(
          SentenceCsvFileError.invalidTranslationColumn, badColumns);
    }
    if (duplicateColumns.isNotEmpty) {
      throw SentenceCsvFileException(
          SentenceCsvFileError.duplicateTranslationColumn, duplicateColumns);
    }

    int col(String name) => header.indexOf(name);
    final iWordId = col(colWordId);
    final iSentence = col(colSentence);
    final iTranslation = col(colTranslation);
    final iTarget = col(colTargetLanguage);
    final iLocale = col(colTranslationLocale);
    final iLevel = col(colLevel);
    final iCategory = col(colCategory);

    String cell(List<dynamic> row, int i) =>
        i >= 0 && i < row.length ? row[i].toString().trim() : '';

    final invalidRows = <InvalidRow>[];
    final invalidWordIds = <InvalidWordIdRow>[];
    final noTranslationRows = <int>[];
    final valid = <_Row>[];

    // 第 1 步：逐列驗證（SPEC §8.2 1–4）。
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
        invalidRows
            .add(InvalidRow(rowNumber, InvalidRowReason.missingSentence));
        continue;
      }
      final rawLocale = cell(row, iLocale);
      final locale = rawLocale.isEmpty
          ? defaultLocale
          : PeLanguages.canonicalize(rawLocale);
      if (locale == null) {
        invalidRows.add(InvalidRow(rowNumber, InvalidRowReason.invalidLocale));
        continue;
      }
      final rawTarget = cell(row, iTarget);
      final target = rawTarget.isEmpty
          ? defaultTargetLanguage
          : PeLanguages.canonicalTarget(rawTarget);
      if (target == null) {
        invalidRows
            .add(InvalidRow(rowNumber, InvalidRowReason.invalidTargetLanguage));
        continue;
      }
      final bad = refs
          .where(
              (ref) => !WordRef.isWellFormed(ref) || !_wordIndex.contains(ref))
          .toList();
      if (bad.isNotEmpty) {
        invalidWordIds.add(InvalidWordIdRow(rowNumber, bad));
        continue;
      }

      final translations = <String, String>{};
      final selfConflicts = <String>{};
      void put(String code, String text) {
        if (text.isEmpty || selfConflicts.contains(code)) return;
        final prev = translations[code];
        if (prev == null) {
          translations[code] = text;
        } else if (prev != text) {
          translations.remove(code);
          selfConflicts.add(code);
        }
      }

      wide.forEach((i, code) => put(code, cell(row, i)));
      put(locale, cell(row, iTranslation));
      if (translations.isEmpty && selfConflicts.isEmpty) {
        noTranslationRows.add(rowNumber);
      }

      valid.add(_Row(
        number: rowNumber,
        key: SentenceIdFactory.dedupKey(target, sentenceText),
        targetLanguage: target,
        sentenceText: sentenceText,
        refs: {...refs}.toList(),
        translations: translations,
        selfConflicts: selfConflicts,
        level: cell(row, iLevel).isEmpty ? null : cell(row, iLevel),
        category: cell(row, iCategory).isEmpty ? null : cell(row, iCategory),
      ));
    }

    // 第 2 步：檔案自行比對。同一 dedupKey＋語言出現兩種以上翻譯 → 該語言
    // 在檔內衝突，涉及的每一列都算 Conflict，不寫入，覆寫也不適用。
    final fileTexts = <String, Map<String, Set<String>>>{};
    final fileConflicts = <String, Set<String>>{};
    for (final row in valid) {
      final texts = fileTexts[row.key] ??= {};
      row.translations.forEach((code, text) {
        (texts[code] ??= <String>{}).add(text);
      });
      if (row.selfConflicts.isNotEmpty) {
        (fileConflicts[row.key] ??= <String>{}).addAll(row.selfConflicts);
      }
    }
    fileTexts.forEach((key, byCode) {
      byCode.forEach((code, texts) {
        if (texts.length > 1) (fileConflicts[key] ??= <String>{}).add(code);
      });
    });

    // 第 3 步：與已存資料比對（SPEC §8.2 5–6）。
    final builtInKeys = {
      for (final s in _repository.builtIn)
        SentenceIdFactory.dedupKey(
            _canonicalTarget(s.targetLanguage), s.sentenceText)
    };

    // 既有匯入句子：dedupKey → 句子，以及 ID 對照（避免碰撞、保持 ID 穩定）。
    final order = <String>[];
    final byKey = <String, Sentence>{};
    final idByKey = <String, String>{};
    final keyById = <String, String>{};
    for (final s in _repository.imported) {
      final key = SentenceIdFactory.dedupKey(
          _canonicalTarget(s.targetLanguage), s.sentenceText);
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
    // 算作 Conflict 的列仍可能新增句子或連結（衝突語言以外的部分）。
    var conflictRowWrote = false;
    final conflicts = <ConflictRow>[];
    final builtInMatches = <int>[];

    for (final row in valid) {
      final inFile = fileConflicts[row.key] ?? const <String>{};
      final rowConflicts = <String>{
        ...row.selfConflicts,
        ...row.translations.keys.where(inFile.contains),
      };
      final usable = {
        for (final e in row.translations.entries)
          if (!inFile.contains(e.key)) e.key: e.value
      };

      if (builtInKeys.contains(row.key)) {
        if (rowConflicts.isNotEmpty) {
          conflicts.add(ConflictRow(row.number, rowConflicts.toList()..sort()));
        } else {
          builtInMatches.add(row.number);
        }
        continue;
      }

      final existing = byKey[row.key];
      if (existing == null) {
        final id = SentenceIdFactory.assign(row.key,
            idByKey: idByKey, keyById: keyById);
        byKey[row.key] = Sentence(
          id: id,
          wordIds: row.refs,
          datasetId: importDatasetId,
          targetLanguage: row.targetLanguage,
          sentenceText: row.sentenceText,
          translations: usable,
          level: row.level,
          category: row.category,
        );
        order.add(row.key);
        if (rowConflicts.isNotEmpty) {
          conflicts.add(ConflictRow(row.number, rowConflicts.toList()..sort()));
          conflictRowWrote = true; // 句子仍新增，必須寫檔
        } else {
          added++;
        }
        continue;
      }

      final current = _canonicalTranslations(existing.translations);
      final newRefs =
          row.refs.where((r) => !existing.wordIds.contains(r)).toList();
      final next = Map<String, String>.of(current);
      var changed = newRefs.isNotEmpty;
      usable.forEach((code, text) {
        final old = current[code];
        if (old == null) {
          next[code] = text;
          changed = true;
        } else if (old != text) {
          if (overwrite) {
            next[code] = text;
            changed = true;
          } else {
            rowConflicts.add(code);
          }
        }
      });
      if (changed) {
        byKey[row.key] = existing.copyWith(
          wordIds: [...existing.wordIds, ...newRefs],
          translations: next,
        );
      }
      if (rowConflicts.isNotEmpty) {
        conflicts.add(ConflictRow(row.number, rowConflicts.toList()..sort()));
        if (changed) conflictRowWrote = true;
      } else if (changed) {
        updated++;
      } else {
        duplicate++;
      }
    }

    return SentenceImportResult(
      added: added,
      updated: updated,
      duplicate: duplicate,
      invalidWordIds: invalidWordIds,
      invalidRows: invalidRows,
      conflicts: conflicts,
      builtInMatches: builtInMatches,
      noTranslationRows: noTranslationRows,
      importedSentences: List.unmodifiable([for (final k in order) byKey[k]!]),
      hasChanges: added > 0 || updated > 0 || conflictRowWrote,
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
