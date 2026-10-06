import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'device_quirks.dart';

/// 鎖屏／通知卡片封面與每日提醒大圖示。
/// 0.3.1（Lawrence 2026-10-06 決定）：封面不再放單字大字（當卡片背景會被裁切、
/// 疊在標題後面；小米 MIUI 當右側縮圖則和標題重複），改成無文字的鼠尾草綠底：
/// 一般手機用純綠底（assets/cover/cover_plain.png），小米系用綠底＋App 圖示
/// （cover_logo.png）。圖檔由 tools/icons/generate_cover_art.py 產生。
class CoverArt {
  static const _bg = Color(0xFF5B8A72);
  static Uri? _lockScreen;

  /// 複製到 App 支援目錄一次，之後都用同一個檔案。失敗回傳 null（系統預設卡片）。
  static Future<Uri?> lockScreen() async {
    final cached = _lockScreen;
    if (cached != null && File.fromUri(cached).existsSync()) return cached;
    try {
      final name =
          DeviceQuirks.xiaomiFamily ? 'cover_logo.png' : 'cover_plain.png';
      final data = await rootBundle.load('assets/cover/$name');
      final dir = await getApplicationSupportDirectory();
      final file = File('${dir.path}/lockscreen_$name');
      await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
      return _lockScreen = file.uri;
    } catch (_) {
      return null;
    }
  }

  /// 每日提醒的大圖示：鼠尾草綠底、白色單字（沒有單字時顯示 Aa）。
  /// 存在 App 支援目錄（不會被系統當暫存清掉），提醒觸發時才讀得到。
  static Future<String?> reminderIcon(String word) async {
    const size = 192.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(
        const Rect.fromLTWH(0, 0, size, size), Paint()..color = _bg);
    final tp = _fit(
      word,
      const TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w800,
          color: Color(0xFFFFFFFF),
          height: 1.0),
      maxSize: 64,
      minSize: 22,
      maxLines: 2,
      maxWidth: size - 28,
      direction: TextDirection.ltr,
    );
    tp.paint(canvas, Offset((size - tp.width) / 2, (size - tp.height) / 2));
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    picture.dispose();
    image.dispose();
    tp.dispose();
    if (data == null) return null;
    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}/reminder_icon.png');
    await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
    return file.path;
  }

  /// 從最大字級開始縮小，直到不超過行數、最長的單字也不超寬。
  static TextPainter _fit(
    String text,
    TextStyle style, {
    required double maxSize,
    required double minSize,
    required int maxLines,
    required double maxWidth,
    required TextDirection direction,
  }) {
    final longest = text
        .split(RegExp(r'\s+'))
        .fold<String>('', (a, b) => b.length > a.length ? b : a);
    var size = maxSize;
    while (true) {
      final s = style.copyWith(fontSize: size);
      final tp = TextPainter(
        text: TextSpan(text: text, style: s),
        textDirection: direction,
        textAlign: TextAlign.center,
        maxLines: maxLines,
        ellipsis: '…',
      )..layout(maxWidth: maxWidth);
      final wp = TextPainter(
        text: TextSpan(text: longest, style: s),
        textDirection: direction,
      )..layout();
      final fits = !tp.didExceedMaxLines && wp.width <= maxWidth;
      wp.dispose();
      if (fits || size <= minSize) return tp;
      tp.dispose();
      size -= 4;
    }
  }
}
