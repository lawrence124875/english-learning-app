import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 0.3.0 介面視覺（規格：store_assets/ui_proposals_2026-10-06/spec_0.3.0.md）。
/// 淺色＝「柔光卡片」，深色＝「夜讀深綠」。主色維持鼠尾草綠 #5B8A72；
/// 有白字的實心按鈕用同色相深一階的 #4F7C65，白字對比才達 4.5 以上，
/// 年長使用者看得清楚。暖橘只用在星號（不熟悉單字），不放白字。
class AppPalette extends ThemeExtension<AppPalette> {
  final Color bgTop; // 首頁背景上方的淡綠光暈
  final Color bgBottom; // 首頁背景下方
  final Color card; // 單字卡
  final Color cardShadow;
  final Color word; // 英文單字
  final Color translation; // 翻譯
  final Color muted; // 次要文字（編號、輪數、摘要）
  final Color pill; // 上一個／下一個小膠囊底色
  final Color onPill;
  final Color track; // 進度條底
  final Color star; // 加入不熟悉（暖橘文字）
  final Color softRow; // 解鎖列、播放設定等次要區塊底色
  final Color adArea; // 免費版橫幅廣告區底色

  const AppPalette({
    required this.bgTop,
    required this.bgBottom,
    required this.card,
    required this.cardShadow,
    required this.word,
    required this.translation,
    required this.muted,
    required this.pill,
    required this.onPill,
    required this.track,
    required this.star,
    required this.softRow,
    required this.adArea,
  });

  static const light = AppPalette(
    bgTop: Color(0xFFE3EFE7),
    bgBottom: Color(0xFFFAFAF7),
    card: Colors.white,
    cardShadow: Color(0x1F3C6450),
    word: Color(0xFF203229),
    translation: Color(0xFF5B8A72),
    muted: Color(0xFF6E7D75),
    pill: Color(0xFFEEF5F0),
    onPill: Color(0xFF4F7C65),
    track: Color(0xFFE2EDE6),
    star: Color(0xFFB0752A),
    softRow: Color(0xD9FFFFFF),
    adArea: Color(0xFFE9ECE8),
  );

  static const dark = AppPalette(
    bgTop: Color(0xFF1B2a22),
    bgBottom: Color(0xFF141C18),
    card: Color(0xFF1D2722),
    cardShadow: Color(0x66000000),
    word: Color(0xFFF2F6F3),
    translation: Color(0xFF9CC5AE),
    muted: Color(0xFF8A9C94),
    pill: Color(0xFF26332D),
    onPill: Color(0xFFB9D3C4),
    track: Color(0xFF2A3830),
    star: Color(0xFFE5B26E),
    softRow: Color(0xFF1D2722),
    adArea: Color(0xFF0E1411),
  );

  static AppPalette of(BuildContext context) =>
      Theme.of(context).extension<AppPalette>() ?? light;

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      bgTop: c(bgTop, other.bgTop),
      bgBottom: c(bgBottom, other.bgBottom),
      card: c(card, other.card),
      cardShadow: c(cardShadow, other.cardShadow),
      word: c(word, other.word),
      translation: c(translation, other.translation),
      muted: c(muted, other.muted),
      pill: c(pill, other.pill),
      onPill: c(onPill, other.onPill),
      track: c(track, other.track),
      star: c(star, other.star),
      softRow: c(softRow, other.softRow),
      adArea: c(adArea, other.adArea),
    );
  }
}

class AppTheme {
  /// 品牌主色（鎖屏封面、通知顏色也用這個，不跟深色模式切換）。
  static const brand = Color(0xFF5B8A72);

  static ThemeData light() {
    const scheme = ColorScheme.light(
      // 柔和鼠尾草綠/藍綠色：研究顯示冷色調有助於放鬆專注、
      // 利於長期記憶保存，且對眼睛負擔較小，適合長時間閱讀學習。
      primary: Color(0xFF4F7C65),
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFDCEEE1),
      onPrimaryContainer: Color(0xFF1E3A2A),
      secondary: Color(0xFF6B8CAE),
      onSecondary: Colors.white,
      // 暖色只用在需要吸引注意力的重點（例如標記不熟悉單字的
      // 星號），依色彩心理學研究應少量點綴、避免過度刺激。
      tertiary: Color(0xFFE0A458),
      onTertiary: Colors.white,
      surface: Color(0xFFFAFAF7),
      onSurface: Color(0xFF2C2C28),
      onSurfaceVariant: Color(0xFF5E6B65),
      surfaceContainerHighest: Color(0xFFF0F0EA),
      outline: Color(0xFFC9D4CD),
      outlineVariant: Color(0xFFDCE3DE),
      error: Color(0xFFC5705D),
      onError: Colors.white,
    );
    return _build(scheme, AppPalette.light, Brightness.light);
  }

  static ThemeData dark() {
    const scheme = ColorScheme.dark(
      primary: Color(0xFF8DBBA2),
      onPrimary: Color(0xFF10201A),
      primaryContainer: Color(0xFF2A4236),
      onPrimaryContainer: Color(0xFFCFE5D7),
      secondary: Color(0xFF94AFCB),
      onSecondary: Color(0xFF13202C),
      tertiary: Color(0xFFE5B26E),
      onTertiary: Color(0xFF2A1C08),
      surface: Color(0xFF141C18),
      onSurface: Color(0xFFE4ECE7),
      onSurfaceVariant: Color(0xFFA4B5AD),
      surfaceContainerLowest: Color(0xFF101713),
      surfaceContainerLow: Color(0xFF18211C),
      surfaceContainer: Color(0xFF1D2722),
      surfaceContainerHigh: Color(0xFF222D27),
      surfaceContainerHighest: Color(0xFF26332D),
      outline: Color(0xFF3A4A42),
      outlineVariant: Color(0xFF2A3830),
      error: Color(0xFFE59A86),
      onError: Color(0xFF2D110A),
    );
    return _build(scheme, AppPalette.dark, Brightness.dark);
  }

  static ThemeData _build(
      ColorScheme scheme, AppPalette palette, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    // 無邊框模式：狀態列、導覽列透明，圖示顏色跟著深淺色切換。
    final overlay = (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
        .copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      extensions: [palette],
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: overlay,
      ),
      cardTheme: CardThemeData(
        color: isDark ? palette.card : Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }

  /// 單字字級：小／中／大（約 40／52／64）。
  static double wordFontSize(int sizeIndex) =>
      const [40.0, 52.0, 64.0][sizeIndex.clamp(0, 2)];

  /// 英文單字字型（Nunito ExtraBold）。非拉丁字母（自訂教材的中、日、
  /// 阿拉伯文等）會自動退回系統字型。
  static const wordFontFamily = 'Nunito';
}
