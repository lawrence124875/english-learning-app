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
  /// 表頭偵測字（一律小寫比對）：欄位名稱＋各語言名稱（英文寫法、
  /// 各語言自己的寫法，以及 App 各介面語言對「英文/翻譯/意思」的說法）。
  static const _headerWords = {
    // 欄位名稱
    'word', 'words', 'text', 'phrase', 'source', 'term', 'front', 'back',
    'translation', 'meaning', 'definition', 'target', 'native',
    '翻譯', '翻译', '意思', '中文意思', '單字', '单词', '訳', '意味', '単語',
    '번역', '뜻', '단어', 'nghĩa', 'bản dịch', 'từ', 'terjemahan', 'arti', 'kata',
    'traducción', 'traduccion', 'significado', 'palabra', 'tradução', 'traducao', 'palavra',
    // 語言名稱（英文寫法）
    'english', 'chinese', 'japanese', 'korean', 'vietnamese', 'indonesian',
    'spanish', 'portuguese', 'french', 'german', 'italian', 'thai',
    'mandarin', 'cantonese', 'traditional chinese', 'simplified chinese',
    'russian', 'arabic', 'hindi', 'turkish', 'dutch', 'polish', 'malay',
    'tagalog', 'filipino',
    // 語言名稱（各語言寫法／App 介面語言的說法）
    '英文', '英語', '英语', '中文', '繁體中文', '简体中文', '繁中', '簡中', '简中', '日文', '日語', '日语', '日本語', '韓文', '韓語', '韩语',
    '한국어', '영어', '일본어', '중국어', 'tiếng anh', 'tiếng việt', 'tiếng nhật',
    'inggris', 'bahasa inggris', 'bahasa indonesia', 'jepang', 'bahasa jepang',
    'inglés', 'ingles', 'español', 'espanol', 'japonés', 'japones',
    'inglês', 'português', 'portugues', 'japonês',
    'français', 'francais', 'deutsch', 'italiano', 'ไทย', 'อังกฤษ', 'ภาษาอังกฤษ',
    // 泰文（第 11 版）
    'ภาษาไทย', 'คำ', 'คำศัพท์', 'คำแปล', 'ความหมาย', 'วลี', 'ประโยค',
    // 阿拉伯文（第 11 版；含有無 hamza 的常見寫法）
    'العربية', 'عربي', 'الإنجليزية', 'الانجليزية', 'إنجليزي', 'انجليزي',
    'كلمة', 'الكلمة', 'كلمات', 'الكلمات', 'ترجمة', 'الترجمة', 'معنى', 'المعنى',
    'عبارة', 'العبارة', 'جملة', 'الجملة',
  };

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

    // 分隔符號：預設逗號。第一列完全沒有逗號時，改用它含有的 Tab、
    // 分號，或阿拉伯文分號「؛」、阿拉伯文逗號「،」（第 11 版：阿拉伯文、
    // 歐洲地區的 Excel 常匯出分號分隔，阿拉伯文輸入法也常打出「،」）。
    final firstLine = content
        .split('\n')
        .firstWhere((l) => l.trim().isNotEmpty, orElse: () => '');
    var delimiter = ',';
    if (!firstLine.contains(',')) {
      for (final d in const ['\t', ';', '\u061B', '\u060C']) {
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

    // 判斷第一列是不是表頭，是的話跳過。第一欄或第二欄任一格是
    // 常見表頭字（english/word/translation…）或語言名稱（japanese、
    // 日本語、español…）就當表頭——學其他語言的人常把表頭寫成
    // 「japanese,english」，只看第一欄會把表頭當成一筆資料匯入。
    var startIndex = 0;
    String cell(int c) =>
        rows[0].length > c ? rows[0][c].toString().trim().toLowerCase() : '';
    if (_headerWords.contains(cell(0)) || _headerWords.contains(cell(1))) {
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
