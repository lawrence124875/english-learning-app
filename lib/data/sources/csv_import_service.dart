import 'package:csv/csv.dart';
import '../../domain/models/word_item.dart';

/// 解析使用者上傳的 CSV 檔案，轉換成教材資料。
///
/// 匯入格式（CSV，含表頭列）：
///   english,translation
///   apple,蘋果
///   give up,放棄
///   How are you doing today?,你今天過得怎麼樣？
///
/// 每一列可以是單字、片語，或一整句常用例句——App 內部把這三種
/// 一視同仁處理（都只是「一段要朗讀＋顯示翻譯的英文文字」），
/// 不需要另外分類欄位，格式維持越簡單越好。
class CsvImportException implements Exception {
  final String message;
  CsvImportException(this.message);
  @override
  String toString() => message;
}

class CsvImportResult {
  final List<WordItem> items;
  final int skippedRows;
  CsvImportResult({required this.items, required this.skippedRows});
}

class CsvImportService {
  /// [translationLocale] 例如 "zh-TW"、"ja"、"ko"、"vi"、"en" 等，
  /// 由使用者在匯入畫面上選擇，決定這個檔案的「翻譯」欄位要存進
  /// 哪個語言代碼底下。
  static CsvImportResult parse(String csvContent, String translationLocale) {
    final rows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
        .convert(csvContent, fieldDelimiter: ',');

    if (rows.isEmpty) {
      throw CsvImportException('檔案是空的，請確認內容格式正確。');
    }

    // 判斷第一列是不是表頭（english/translation 之類的文字），是的話跳過。
    var startIndex = 0;
    final firstCell = rows[0].isNotEmpty ? rows[0][0].toString().trim().toLowerCase() : '';
    if (firstCell == 'english' || firstCell == 'word' || firstCell == '英文') {
      startIndex = 1;
    }

    final items = <WordItem>[];
    var skipped = 0;
    for (var i = startIndex; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty) continue;
      final english = row[0].toString().trim();
      final translation = row.length > 1 ? row[1].toString().trim() : '';
      if (english.isEmpty) {
        skipped++;
        continue;
      }
      items.add(WordItem(
        id: 'custom_${i}_${english.hashCode}',
        word: english,
        translations: translation.isEmpty ? {} : {translationLocale: translation},
      ));
    }

    if (items.isEmpty) {
      throw CsvImportException('沒有解析到任何有效的資料列，請確認格式是否正確。');
    }

    return CsvImportResult(items: items, skippedRows: skipped);
  }

  /// 提供下載用的 CSV 範本內容。
  static String templateCsv() {
    const rows = [
      ['english', 'translation'],
      ['apple', '蘋果'],
      ['give up', '放棄'],
      ['How are you doing today?', '你今天過得怎麼樣？'],
    ];
    return const ListToCsvConverter().convert(rows);
  }
}
