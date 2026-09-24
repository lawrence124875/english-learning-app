import 'dart:ui';
import '../../l10n/app_localizations.dart';

/// 語言判斷的單一來源：App 介面（MaterialApp）、通知、鎖屏、
/// 內建教材翻譯都用這裡的規則，確保各處顯示的語言一致。
///
/// 中文分成繁體與簡體：手機設定明確標示簡體（Hans），或地區是
/// 中國、新加坡、馬來西亞時用簡體；其餘（台灣、香港、澳門）用繁體。
/// App 不支援的語言一律退回繁體中文。
class BackgroundL10n {
  static const _hans = Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans');
  static const _supported = {'ja', 'ko', 'vi', 'id', 'es', 'pt'};

  static Locale resolve(Iterable<Locale> deviceLocales) {
    for (final l in deviceLocales) {
      if (l.languageCode == 'zh') {
        final isHans = l.scriptCode == 'Hans' ||
            (l.scriptCode == null &&
                const {'CN', 'SG', 'MY'}.contains(l.countryCode));
        return isHans ? _hans : const Locale('zh');
      }
      if (_supported.contains(l.languageCode)) return Locale(l.languageCode);
    }
    return const Locale('zh');
  }

  static Locale get deviceLocale =>
      resolve(PlatformDispatcher.instance.locales);

  static AppLocalizations current() => lookupAppLocalizations(deviceLocale);

  /// 內建教材翻譯要用的語言代碼（對應教材 JSON 裡 "m" 的 key），
  /// 同時也是朗讀翻譯時交給 TTS 的語言代碼。
  static String translationKey() {
    final l = deviceLocale;
    if (l.languageCode == 'zh') return l.scriptCode == 'Hans' ? 'zh-CN' : 'zh-TW';
    if (l.languageCode == 'pt') return 'pt-BR';
    return l.languageCode;
  }
}
