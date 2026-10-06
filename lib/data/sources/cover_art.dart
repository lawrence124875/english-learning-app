import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/painting.dart';
import 'package:path_provider/path_provider.dart';

/// 0.3.0：鎖屏／通知列的大字封面圖。
/// 每換一個字就畫一張 512×512 的正方形 PNG（鼠尾草綠底、白色大字單字＋
/// 翻譯），用 artUri 交給 audio_service。很多 Android 11 以上手機會把封面
/// 放大當鎖屏卡片背景，等於把字放大（手機系統字級 App 改不了）。
/// 效果依手機而異；畫圖失敗時回傳 null，鎖屏維持一般小字卡片。
class CoverArt {
  static const _size = 512.0;
  static const _keep = 6; // 只保留最近幾張，避免占空間
  static const _bg = Color(0xFF5B8A72);
  static const _bgLight = Color(0xFF6E9C84);

  static final Map<String, Uri> _cache = {};
  static final List<String> _order = [];
  static Directory? _dir;

  static Future<Uri?> forWord({
    required String word,
    required String meaning,
    required String footer,
    required bool meaningRtl,
  }) async {
    final key = '$word\u0000$meaning\u0000$footer';
    final hit = _cache[key];
    if (hit != null && File.fromUri(hit).existsSync()) return hit;

    final png = await _render(word, meaning, footer, meaningRtl);
    if (png == null) return null;
    final dir = _dir ??= await _coverDir();
    final file = File(
        '${dir.path}/cover_${DateTime.now().microsecondsSinceEpoch}.png');
    await file.writeAsBytes(png, flush: true);
    final uri = file.uri;
    _cache[key] = uri;
    _order.add(key);
    while (_order.length > _keep) {
      final old = _cache.remove(_order.removeAt(0));
      if (old != null) {
        try {
          File.fromUri(old).deleteSync();
        } catch (_) {}
      }
    }
    return uri;
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

  static Future<Directory> _coverDir() async {
    final base = await getTemporaryDirectory();
    final dir = Directory('${base.path}/lockscreen_cover');
    // 上次執行留下的舊圖先清掉。
    if (dir.existsSync()) {
      try {
        dir.deleteSync(recursive: true);
      } catch (_) {}
    }
    dir.createSync(recursive: true);
    return dir;
  }

  static Future<List<int>?> _render(
      String word, String meaning, String footer, bool meaningRtl) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const rect = Rect.fromLTWH(0, 0, _size, _size);
      canvas.drawRect(
        rect,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(0, -0.2),
            radius: 0.9,
            colors: [_bgLight, _bg],
          ).createShader(rect),
      );

      const maxWidth = _size - 64;
      final wordPainter = _fit(
        word,
        const TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w800,
          color: Color(0xFFFFFFFF),
          height: 1.05,
        ),
        maxSize: 112,
        minSize: 44,
        maxLines: 2,
        maxWidth: maxWidth,
        direction: TextDirection.ltr,
      );
      final meaningPainter = meaning.isEmpty
          ? null
          : _fit(
              meaning,
              const TextStyle(
                color: Color(0xF0FFFFFF),
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
              maxSize: 46,
              minSize: 24,
              maxLines: 2,
              maxWidth: maxWidth,
              direction: meaningRtl ? TextDirection.rtl : TextDirection.ltr,
            );
      final footerPainter = TextPainter(
        text: TextSpan(
          text: footer,
          style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 22),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: maxWidth);

      const gap = 22.0;
      final blockHeight = wordPainter.height +
          (meaningPainter == null ? 0 : gap + meaningPainter.height);
      var y = (_size - blockHeight) / 2 - 16;
      wordPainter.paint(canvas, Offset((_size - wordPainter.width) / 2, y));
      y += wordPainter.height;
      if (meaningPainter != null) {
        y += gap;
        meaningPainter.paint(
            canvas, Offset((_size - meaningPainter.width) / 2, y));
      }
      footerPainter.paint(
        canvas,
        Offset((_size - footerPainter.width) / 2,
            _size - 40 - footerPainter.height),
      );

      final picture = recorder.endRecording();
      final image = await picture.toImage(_size.toInt(), _size.toInt());
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      picture.dispose();
      image.dispose();
      wordPainter.dispose();
      meaningPainter?.dispose();
      footerPainter.dispose();
      return data?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
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
