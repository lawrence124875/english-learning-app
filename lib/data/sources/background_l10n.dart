import 'dart:ui';
import '../../l10n/app_localizations.dart';

/// 讓「沒有畫面（BuildContext）」的地方也能取得多語言文字。
///
/// 通知排程、鎖屏播放卡片、背景播放通知頻道名稱……這些都是在
/// Widget 樹之外執行的程式碼，沒辦法用 AppLocalizations.of(context)。
/// 這裡改成直接讀取裝置的系統語言清單，挑第一個 App 有支援的語言；
/// 都不支援時退回中文（跟 MaterialApp 的自動選擇邏輯一致）。
class BackgroundL10n {
  static AppLocalizations current() {
    for (final deviceLocale in PlatformDispatcher.instance.locales) {
      final locale = Locale(deviceLocale.languageCode);
      if (AppLocalizations.delegate.isSupported(locale)) {
        return lookupAppLocalizations(locale);
      }
    }
    return lookupAppLocalizations(const Locale('zh'));
  }

  /// 內建教材翻譯要用的語言代碼（對應教材 JSON 裡 "m" 的 key）。
  static String translationKey() {
    for (final deviceLocale in PlatformDispatcher.instance.locales) {
      final lang = deviceLocale.languageCode;
      if (lang == 'zh') return 'zh-TW';
      if (const {'ja', 'ko', 'vi', 'id'}.contains(lang)) return lang;
    }
    return 'zh-TW';
  }
}
