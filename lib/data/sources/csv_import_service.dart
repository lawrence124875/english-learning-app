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
/// 匯入失敗的原因代碼。錯誤訊息文字由畫面層依介面語言翻譯，
/// 資料層只負責回報「是哪一種錯誤」。
enum CsvImportError { encoding, parseFailed, empty, noValidRows }

class CsvImportException implements Exception {
  final CsvImportError error;
  CsvImportException(this.error);
  @override
  String toString() => 'CsvImportException($error)';
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
    // 去除檔案開頭的 BOM（Excel/部分工具存 CSV 時常見的隱藏字元），
    // 沒處理的話可能導致第一欄的內容判斷失準。
    var content = csvContent;
    if (content.isNotEmpty && content.codeUnitAt(0) == 0xFEFF) {
      content = content.substring(1);
    }
    // 統一換行符號，避免不同作業系統/工具產生的 \r\n、\r 造成解析落差。
    content = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

    List<List<dynamic>> rows;
    try {
      rows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
          .convert(content, fieldDelimiter: ',');
    } catch (e) {
      throw CsvImportException(CsvImportError.parseFailed);
    }

    if (rows.isEmpty) {
      throw CsvImportException(CsvImportError.empty);
    }

    // 備援處理：有些工具匯出 CSV 時，會把整行都包進同一組引號裡
    // （例如 "english,translation" 整個當成一個欄位），導致每一列
    // 都被解析成只有一欄。偵測到這種情況時，改成用第一個逗號
    // 手動切成兩欄。
    rows = rows.map((row) {
      if (row.length == 1 && row[0].toString().contains(',')) {
        final text = row[0].toString();
        final idx = text.indexOf(',');
        return [text.substring(0, idx), text.substring(idx + 1)];
      }
      return row;
    }).toList();

    // 判斷第一列是不是表頭（english/translation 之類的文字），是的話跳過。
    var startIndex = 0;
    final firstCell = rows[0].isNotEmpty ? rows[0][0].toString().trim().toLowerCase() : '';
    const headerWords = {'english', 'word', '英文', '英語', '영어', 'tiếng anh'};
    if (headerWords.contains(firstCell)) {
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
      throw CsvImportException(CsvImportError.noValidRows);
    }

    return CsvImportResult(items: items, skippedRows: skipped);
  }

  /// 提供下載用的 CSV 範本內容。範例翻譯由畫面層依介面語言傳入，
  /// 讓日/韓/越南使用者拿到的範本也是自己的語言。
  static String templateCsv({
    required String apple,
    required String giveUp,
    required String howAreYou,
  }) {
    final rows = [
      ['english', 'translation'],
      ['apple', apple],
      ['give up', giveUp],
      ['How are you doing today?', howAreYou],
    ];
    return const ListToCsvConverter().convert(rows);
  }
}
