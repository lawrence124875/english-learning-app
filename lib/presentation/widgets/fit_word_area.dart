import 'package:flutter/material.dart';

/// 首頁單字卡中間的「單字＋翻譯」區塊（0.3.1）。
/// 依實際可用的寬與高決定字級：單字從設定大小開始縮小，直到
/// 寬度、行數、高度（扣掉翻譯）都放得下；翻譯太高時先減行數再縮字。
/// 0.3.0 只檢查寬度，大字＋長片語時單字會長到按鈕列後面（紅米 Note 8 回報）。
class FitWordArea extends StatelessWidget {
  final String word;
  final String? meaning;
  final double maxWordSize;
  final double meaningSize;
  final TextStyle wordStyle;
  final TextStyle meaningStyle;
  final TextDirection wordDirection;
  final TextDirection meaningDirection;

  static const double gap = 10;
  static const double minWordSize = 14;
  static const double minMeaningSize = 12;
  static const int wordMaxLines = 3;

  const FitWordArea({
    super.key,
    required this.word,
    required this.meaning,
    required this.maxWordSize,
    required this.meaningSize,
    required this.wordStyle,
    required this.meaningStyle,
    required this.wordDirection,
    required this.meaningDirection,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final scaler = MediaQuery.textScalerOf(context);
      // Text 會套上主題預設字型樣式（Material 3 行高 1.43），量的時候也要套，
      // 否則實際比量到的高，翻譯會被切掉（0.3.1 第一版實機發生）。
      final base = DefaultTextStyle.of(context).style;
      final wordStyle = base.merge(this.wordStyle);
      final meaningStyle = base.merge(this.meaningStyle);
      final width = c.maxWidth;
      final height = c.maxHeight - 2; // 留一點餘裕，避免小數誤差

      // 翻譯最多占一半高度。
      var mLines = 3;
      var mSize = meaningSize;
      var mHeight = 0.0;
      final hasMeaning = meaning != null && meaning!.isNotEmpty;
      if (hasMeaning) {
        while (true) {
          final tp = _measure(meaning!, meaningStyle.copyWith(fontSize: mSize),
              meaningDirection, mLines, width, scaler);
          mHeight = tp.height;
          tp.dispose();
          if (mHeight <= height * 0.5) break;
          if (mLines > 1) {
            mLines--;
          } else if (mSize > minMeaningSize) {
            mSize -= 1;
          } else {
            break;
          }
        }
      }
      final wordHeight =
          (height - (hasMeaning ? mHeight + gap : 0)).clamp(0.0, height);
      final wSize = fitWordSize(
        text: word,
        style: wordStyle,
        maxSize: maxWordSize,
        maxWidth: width,
        maxHeight: wordHeight,
        direction: wordDirection,
        scaler: scaler,
      );

      return ClipRect(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              word,
              textAlign: TextAlign.center,
              textDirection: wordDirection,
              maxLines: wordMaxLines,
              overflow: TextOverflow.ellipsis,
              style: wordStyle.copyWith(fontSize: wSize),
            ),
            if (hasMeaning) ...[
              const SizedBox(height: gap),
              Text(
                meaning!,
                textAlign: TextAlign.center,
                maxLines: mLines,
                overflow: TextOverflow.ellipsis,
                textDirection: meaningDirection,
                style: meaningStyle.copyWith(fontSize: mSize),
              ),
            ],
          ],
        ),
      );
    });
  }

  /// 從 [maxSize] 每次縮 2，直到不超過行數、最長的字不超寬、總高度放得下。
  static double fitWordSize({
    required String text,
    required TextStyle style,
    required double maxSize,
    required double maxWidth,
    required double maxHeight,
    required TextDirection direction,
    required TextScaler scaler,
  }) {
    final longest = text
        .split(RegExp(r'\s+'))
        .fold<String>('', (a, b) => b.length > a.length ? b : a);
    var size = maxSize;
    while (size > minWordSize) {
      final s = style.copyWith(fontSize: size);
      final tp = _measure(text, s, direction, wordMaxLines, maxWidth, scaler);
      final wp = TextPainter(
        text: TextSpan(text: longest, style: s),
        textDirection: direction,
        textScaler: scaler,
      )..layout();
      final fits = !tp.didExceedMaxLines &&
          wp.width <= maxWidth &&
          tp.height <= maxHeight;
      tp.dispose();
      wp.dispose();
      if (fits) return size;
      size -= 2;
    }
    return minWordSize;
  }

  static TextPainter _measure(String text, TextStyle style,
      TextDirection direction, int maxLines, double maxWidth, TextScaler scaler) {
    return TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: direction,
      textAlign: TextAlign.center,
      maxLines: maxLines,
      textScaler: scaler,
    )..layout(maxWidth: maxWidth);
  }
}
