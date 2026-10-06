import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_th.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('id'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('th'),
    Locale('vi'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans')
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'智慧聽覺巡航'**
  String get appTitle;

  /// No description provided for @statsTooltip.
  ///
  /// In zh, this message translates to:
  /// **'學習統計'**
  String get statsTooltip;

  /// No description provided for @moreTooltip.
  ///
  /// In zh, this message translates to:
  /// **'更多'**
  String get moreTooltip;

  /// No description provided for @menuPremium.
  ///
  /// In zh, this message translates to:
  /// **'升級 Premium'**
  String get menuPremium;

  /// No description provided for @menuVoicePreview.
  ///
  /// In zh, this message translates to:
  /// **'語音預覽'**
  String get menuVoicePreview;

  /// No description provided for @menuImport.
  ///
  /// In zh, this message translates to:
  /// **'匯入自訂教材'**
  String get menuImport;

  /// No description provided for @menuAbout.
  ///
  /// In zh, this message translates to:
  /// **'關於本 App / 版權聲明'**
  String get menuAbout;

  /// No description provided for @wordNumberLabel.
  ///
  /// In zh, this message translates to:
  /// **'No. {current} / {total}'**
  String wordNumberLabel(int current, int total);

  /// No description provided for @cycleLabel.
  ///
  /// In zh, this message translates to:
  /// **'第 {n} 輪學習'**
  String cycleLabel(int n);

  /// No description provided for @roundProgressLabel.
  ///
  /// In zh, this message translates to:
  /// **'本輪已聽過進度：{heard} / {total} ({percent}%)'**
  String roundProgressLabel(int heard, int total, int percent);

  /// No description provided for @playButtonStart.
  ///
  /// In zh, this message translates to:
  /// **'開始巡航朗讀'**
  String get playButtonStart;

  /// No description provided for @playButtonPause.
  ///
  /// In zh, this message translates to:
  /// **'暫停巡航朗讀'**
  String get playButtonPause;

  /// No description provided for @starButton.
  ///
  /// In zh, this message translates to:
  /// **'加入不熟悉單字庫'**
  String get starButton;

  /// No description provided for @navPrevious.
  ///
  /// In zh, this message translates to:
  /// **'上一個'**
  String get navPrevious;

  /// No description provided for @navReplay.
  ///
  /// In zh, this message translates to:
  /// **'再讀一次'**
  String get navReplay;

  /// No description provided for @navNext.
  ///
  /// In zh, this message translates to:
  /// **'下一個'**
  String get navNext;

  /// No description provided for @statsTitle.
  ///
  /// In zh, this message translates to:
  /// **'學習統計'**
  String get statsTitle;

  /// No description provided for @todayLearnedLabel.
  ///
  /// In zh, this message translates to:
  /// **'今日已學習'**
  String get todayLearnedLabel;

  /// No description provided for @totalLearnedLabel.
  ///
  /// In zh, this message translates to:
  /// **'累計已學習'**
  String get totalLearnedLabel;

  /// No description provided for @unitCount.
  ///
  /// In zh, this message translates to:
  /// **'個'**
  String get unitCount;

  /// No description provided for @datasetProgressHeader.
  ///
  /// In zh, this message translates to:
  /// **'各教材學習進度'**
  String get datasetProgressHeader;

  /// No description provided for @itemsCountLabel.
  ///
  /// In zh, this message translates to:
  /// **'{learned} / {total} 個項目'**
  String itemsCountLabel(int learned, int total);

  /// No description provided for @dailyReminderHeader.
  ///
  /// In zh, this message translates to:
  /// **'每日複習提醒'**
  String get dailyReminderHeader;

  /// No description provided for @enableDailyReminder.
  ///
  /// In zh, this message translates to:
  /// **'開啟每日提醒'**
  String get enableDailyReminder;

  /// No description provided for @reminderTimeLabel.
  ///
  /// In zh, this message translates to:
  /// **'提醒時間'**
  String get reminderTimeLabel;

  /// No description provided for @reminderScheduledMessage.
  ///
  /// In zh, this message translates to:
  /// **'已排定 {time} 提醒'**
  String reminderScheduledMessage(String time);

  /// No description provided for @reminderFailedMessage.
  ///
  /// In zh, this message translates to:
  /// **'排程失敗，請確認電池優化設定或重新開啟提醒開關'**
  String get reminderFailedMessage;

  /// No description provided for @batteryOptButtonLabel.
  ///
  /// In zh, this message translates to:
  /// **'提醒沒準時跳出？點此排除電池優化限制'**
  String get batteryOptButtonLabel;

  /// No description provided for @batteryOptSnackbar.
  ///
  /// In zh, this message translates to:
  /// **'請確認「省電策略」選擇「無限制」'**
  String get batteryOptSnackbar;

  /// No description provided for @miuiAutostartButtonLabel.
  ///
  /// In zh, this message translates to:
  /// **'小米/Redmi 手機請另外開啟「自啟動」'**
  String get miuiAutostartButtonLabel;

  /// No description provided for @miuiAutostartSnackbar.
  ///
  /// In zh, this message translates to:
  /// **'小米手機請在清單裡找到本App並開啟自啟動（其他廠牌手機可忽略這個按鈕）'**
  String get miuiAutostartSnackbar;

  /// No description provided for @settingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'播放設定'**
  String get settingsTitle;

  /// No description provided for @starredCountLabel.
  ///
  /// In zh, this message translates to:
  /// **'已標記 {n} 個項目'**
  String starredCountLabel(int n);

  /// No description provided for @speakOnManualNavigateLabel.
  ///
  /// In zh, this message translates to:
  /// **'手動切換單字時發音'**
  String get speakOnManualNavigateLabel;

  /// No description provided for @showTranslationLabel.
  ///
  /// In zh, this message translates to:
  /// **'顯示翻譯'**
  String get showTranslationLabel;

  /// No description provided for @intervalSecondsLabel.
  ///
  /// In zh, this message translates to:
  /// **'單字間隔停頓：{seconds} 秒'**
  String intervalSecondsLabel(String seconds);

  /// No description provided for @speechRateLabel.
  ///
  /// In zh, this message translates to:
  /// **'朗讀語速：{rate}x'**
  String speechRateLabel(String rate);

  /// No description provided for @scopeModeLabel.
  ///
  /// In zh, this message translates to:
  /// **'播放範圍 / 模式'**
  String get scopeModeLabel;

  /// No description provided for @scopeAllRandom.
  ///
  /// In zh, this message translates to:
  /// **'全部清單（隨機播放）'**
  String get scopeAllRandom;

  /// No description provided for @scopeAllSequential.
  ///
  /// In zh, this message translates to:
  /// **'全部清單（依序播放）'**
  String get scopeAllSequential;

  /// No description provided for @scopeStarredRandom.
  ///
  /// In zh, this message translates to:
  /// **'僅不熟悉（隨機播放）'**
  String get scopeStarredRandom;

  /// No description provided for @scopeStarredSequential.
  ///
  /// In zh, this message translates to:
  /// **'僅不熟悉（依序播放）'**
  String get scopeStarredSequential;

  /// No description provided for @readModeLabel.
  ///
  /// In zh, this message translates to:
  /// **'朗讀內容模式'**
  String get readModeLabel;

  /// No description provided for @readModeBilingual.
  ///
  /// In zh, this message translates to:
  /// **'雙語朗讀（英文＋翻譯）'**
  String get readModeBilingual;

  /// No description provided for @readModeEnglishOnly.
  ///
  /// In zh, this message translates to:
  /// **'純英文'**
  String get readModeEnglishOnly;

  /// No description provided for @repeatCountLabel.
  ///
  /// In zh, this message translates to:
  /// **'英文重複朗讀次數'**
  String get repeatCountLabel;

  /// No description provided for @repeatOnce.
  ///
  /// In zh, this message translates to:
  /// **'讀 1 次'**
  String get repeatOnce;

  /// No description provided for @repeatTwice.
  ///
  /// In zh, this message translates to:
  /// **'讀 2 次（推薦）'**
  String get repeatTwice;

  /// No description provided for @repeatThrice.
  ///
  /// In zh, this message translates to:
  /// **'讀 3 次'**
  String get repeatThrice;

  /// No description provided for @commonCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In zh, this message translates to:
  /// **'刪除'**
  String get commonDelete;

  /// No description provided for @voicePreviewIntro.
  ///
  /// In zh, this message translates to:
  /// **'這裡列出手機裡可用的英文語音，點播放圖示即可試聽。正式朗讀時 App 會統一使用系統預設語音（依語言自動選擇），這裡純粹讓你先聽聽看手機裡有哪些語音。'**
  String get voicePreviewIntro;

  /// No description provided for @voicePreviewNoVoices.
  ///
  /// In zh, this message translates to:
  /// **'找不到可用的語音，請確認手機已安裝英文語音包。'**
  String get voicePreviewNoVoices;

  /// No description provided for @voicePreviewUnknownVoice.
  ///
  /// In zh, this message translates to:
  /// **'未知語音'**
  String get voicePreviewUnknownVoice;

  /// No description provided for @paywallPurchaseSuccess.
  ///
  /// In zh, this message translates to:
  /// **'訂閱成功！已解鎖完整內容並移除廣告。'**
  String get paywallPurchaseSuccess;

  /// No description provided for @paywallPurchaseFailed.
  ///
  /// In zh, this message translates to:
  /// **'購買未完成，請稍後再試一次。'**
  String get paywallPurchaseFailed;

  /// No description provided for @paywallRestoreSuccess.
  ///
  /// In zh, this message translates to:
  /// **'已恢復 Premium 訂閱！'**
  String get paywallRestoreSuccess;

  /// No description provided for @paywallRestoreNotFound.
  ///
  /// In zh, this message translates to:
  /// **'找不到可恢復的購買紀錄。'**
  String get paywallRestoreNotFound;

  /// No description provided for @paywallAlreadyPremium.
  ///
  /// In zh, this message translates to:
  /// **'您已經是 Premium 訂閱戶 🎉'**
  String get paywallAlreadyPremium;

  /// No description provided for @paywallHeadline.
  ///
  /// In zh, this message translates to:
  /// **'解鎖完整學習內容'**
  String get paywallHeadline;

  /// No description provided for @paywallBenefitAllContent.
  ///
  /// In zh, this message translates to:
  /// **'四份教材 100% 完整開放'**
  String get paywallBenefitAllContent;

  /// No description provided for @paywallBenefitNoAds.
  ///
  /// In zh, this message translates to:
  /// **'完全移除廣告'**
  String get paywallBenefitNoAds;

  /// No description provided for @paywallBenefitBackground.
  ///
  /// In zh, this message translates to:
  /// **'背景播放、鎖屏顯示'**
  String get paywallBenefitBackground;

  /// No description provided for @paywallRestoreButton.
  ///
  /// In zh, this message translates to:
  /// **'恢復先前購買'**
  String get paywallRestoreButton;

  /// No description provided for @paywallNoPackages.
  ///
  /// In zh, this message translates to:
  /// **'目前沒有可用的訂閱方案，請稍後再試。'**
  String get paywallNoPackages;

  /// No description provided for @paywallPlanMonthly.
  ///
  /// In zh, this message translates to:
  /// **'月繳方案'**
  String get paywallPlanMonthly;

  /// No description provided for @paywallPlanAnnual.
  ///
  /// In zh, this message translates to:
  /// **'年繳方案'**
  String get paywallPlanAnnual;

  /// No description provided for @paywallTermsNote.
  ///
  /// In zh, this message translates to:
  /// **'訂閱會自動續訂，可隨時在 Google Play「付款和訂閱」中取消。取消後，Premium 功能可繼續使用到本期結束，之後自動改回免費版。'**
  String get paywallTermsNote;

  /// No description provided for @paywallManageSubscription.
  ///
  /// In zh, this message translates to:
  /// **'管理 / 取消訂閱'**
  String get paywallManageSubscription;

  /// No description provided for @unlockRewardSnackbar.
  ///
  /// In zh, this message translates to:
  /// **'已多解鎖 20 個項目！'**
  String get unlockRewardSnackbar;

  /// No description provided for @unlockFreeProgress.
  ///
  /// In zh, this message translates to:
  /// **'免費版已解鎖 {unlocked} / {total} 個項目'**
  String unlockFreeProgress(int unlocked, int total);

  /// No description provided for @unlockAdLoading.
  ///
  /// In zh, this message translates to:
  /// **'廣告準備中…'**
  String get unlockAdLoading;

  /// No description provided for @unlockWatchAd.
  ///
  /// In zh, this message translates to:
  /// **'看廣告 +20'**
  String get unlockWatchAd;

  /// No description provided for @importIntro.
  ///
  /// In zh, this message translates to:
  /// **'可以匯入自己準備的單字、片語或常用例句（例如自己書上的內容），匯入後會跟內建教材一樣可以切換朗讀。'**
  String get importIntro;

  /// No description provided for @importFormatTitle.
  ///
  /// In zh, this message translates to:
  /// **'匯入格式（CSV，含表頭）'**
  String get importFormatTitle;

  /// No description provided for @importSampleApple.
  ///
  /// In zh, this message translates to:
  /// **'蘋果'**
  String get importSampleApple;

  /// No description provided for @importSampleGiveUp.
  ///
  /// In zh, this message translates to:
  /// **'放棄'**
  String get importSampleGiveUp;

  /// No description provided for @importSampleHowAreYou.
  ///
  /// In zh, this message translates to:
  /// **'你今天過得怎麼樣？'**
  String get importSampleHowAreYou;

  /// No description provided for @importFormatHint.
  ///
  /// In zh, this message translates to:
  /// **'第一欄放英文（單字、片語、整句例句都可以），第二欄放對應翻譯，存成 CSV 檔即可匯入。也可以匯入英文以外的語言，在下方選擇第一欄語言即可。'**
  String get importFormatHint;

  /// No description provided for @importGetTemplate.
  ///
  /// In zh, this message translates to:
  /// **'取得範本檔案'**
  String get importGetTemplate;

  /// No description provided for @importTemplateSaved.
  ///
  /// In zh, this message translates to:
  /// **'範本已存到暫存資料夾：{path}'**
  String importTemplateSaved(String path);

  /// No description provided for @importNameLabel.
  ///
  /// In zh, this message translates to:
  /// **'這份教材的名稱'**
  String get importNameLabel;

  /// No description provided for @importNameHint.
  ///
  /// In zh, this message translates to:
  /// **'例如：多益核心例句'**
  String get importNameHint;

  /// No description provided for @importNameRequired.
  ///
  /// In zh, this message translates to:
  /// **'請先幫這份教材取個名字'**
  String get importNameRequired;

  /// No description provided for @importTranslationLangLabel.
  ///
  /// In zh, this message translates to:
  /// **'翻譯欄位是什麼語言？'**
  String get importTranslationLangLabel;

  /// No description provided for @importLangZh.
  ///
  /// In zh, this message translates to:
  /// **'中文'**
  String get importLangZh;

  /// No description provided for @importLangJa.
  ///
  /// In zh, this message translates to:
  /// **'日文'**
  String get importLangJa;

  /// No description provided for @importLangKo.
  ///
  /// In zh, this message translates to:
  /// **'韓文'**
  String get importLangKo;

  /// No description provided for @importLangVi.
  ///
  /// In zh, this message translates to:
  /// **'越南文'**
  String get importLangVi;

  /// No description provided for @importLangEn.
  ///
  /// In zh, this message translates to:
  /// **'英文'**
  String get importLangEn;

  /// No description provided for @importButton.
  ///
  /// In zh, this message translates to:
  /// **'選擇 CSV 檔並匯入'**
  String get importButton;

  /// No description provided for @importingInProgress.
  ///
  /// In zh, this message translates to:
  /// **'匯入中…'**
  String get importingInProgress;

  /// No description provided for @importDone.
  ///
  /// In zh, this message translates to:
  /// **'匯入完成！共 {count} 筆'**
  String importDone(int count);

  /// No description provided for @importDoneWithSkipped.
  ///
  /// In zh, this message translates to:
  /// **'匯入完成！共 {count} 筆（略過 {skipped} 筆空白列）'**
  String importDoneWithSkipped(int count, int skipped);

  /// No description provided for @importFailedWithReason.
  ///
  /// In zh, this message translates to:
  /// **'匯入失敗：{reason}'**
  String importFailedWithReason(String reason);

  /// No description provided for @importFailedGeneric.
  ///
  /// In zh, this message translates to:
  /// **'匯入失敗，請確認檔案格式是否正確'**
  String get importFailedGeneric;

  /// No description provided for @importErrorEncoding.
  ///
  /// In zh, this message translates to:
  /// **'檔案編碼不是 UTF-8，無法讀取。請用 Excel「另存新檔」時選擇「CSV UTF-8（逗號分隔）」格式，或用純文字編輯器另存成 UTF-8 編碼。'**
  String get importErrorEncoding;

  /// No description provided for @importErrorParse.
  ///
  /// In zh, this message translates to:
  /// **'CSV 格式解析失敗，請確認是否為標準逗號分隔格式。'**
  String get importErrorParse;

  /// No description provided for @importErrorEmpty.
  ///
  /// In zh, this message translates to:
  /// **'檔案是空的，請確認內容格式正確。'**
  String get importErrorEmpty;

  /// No description provided for @importErrorNoRows.
  ///
  /// In zh, this message translates to:
  /// **'沒有解析到任何有效的資料列，請確認格式是否正確。'**
  String get importErrorNoRows;

  /// No description provided for @importDeleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'刪除自訂教材'**
  String get importDeleteTitle;

  /// No description provided for @importDeleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'確定要刪除「{name}」嗎？這個動作無法復原。'**
  String importDeleteConfirm(String name);

  /// No description provided for @importedListHeader.
  ///
  /// In zh, this message translates to:
  /// **'已匯入的自訂教材'**
  String get importedListHeader;

  /// No description provided for @importItemCount.
  ///
  /// In zh, this message translates to:
  /// **'{n} 個項目'**
  String importItemCount(int n);

  /// No description provided for @aboutFeedbackButton.
  ///
  /// In zh, this message translates to:
  /// **'意見回饋 / 回報問題'**
  String get aboutFeedbackButton;

  /// No description provided for @aboutAttributionIntro.
  ///
  /// In zh, this message translates to:
  /// **'本 App 之單字/語塊資料取自以下公開學術研究成果，特此致謝並標明出處：'**
  String get aboutAttributionIntro;

  /// No description provided for @aboutNgslTitle.
  ///
  /// In zh, this message translates to:
  /// **'NGSL 2809（核心單字）'**
  String get aboutNgslTitle;

  /// No description provided for @aboutSpokenTitle.
  ///
  /// In zh, this message translates to:
  /// **'NGSL-Spoken 720（口語常用字）'**
  String get aboutSpokenTitle;

  /// No description provided for @aboutPhaveTitle.
  ///
  /// In zh, this message translates to:
  /// **'PhaVE List（片語動詞）'**
  String get aboutPhaveTitle;

  /// No description provided for @aboutPhraseTitle.
  ///
  /// In zh, this message translates to:
  /// **'PHRASE List（高頻語塊）'**
  String get aboutPhraseTitle;

  /// No description provided for @aboutLicenseCcBySa.
  ///
  /// In zh, this message translates to:
  /// **'採用創用CC「姓名標示-相同方式分享 4.0 國際授權條款」（CC BY-SA 4.0）。'**
  String get aboutLicenseCcBySa;

  /// No description provided for @aboutLicenseCcBy.
  ///
  /// In zh, this message translates to:
  /// **'採用創用CC「姓名標示 4.0 國際授權條款」（CC BY 4.0）。'**
  String get aboutLicenseCcBy;

  /// No description provided for @aboutPhraseRights.
  ///
  /// In zh, this message translates to:
  /// **'版權歸原作者所有，本 App 依授權範圍使用於教學用途。'**
  String get aboutPhraseRights;

  /// No description provided for @aboutSourceLabel.
  ///
  /// In zh, this message translates to:
  /// **'原作品：{name}'**
  String aboutSourceLabel(String name);

  /// No description provided for @aboutLicenseLabel.
  ///
  /// In zh, this message translates to:
  /// **'授權條款：{name}'**
  String aboutLicenseLabel(String name);

  /// No description provided for @aboutTtsNote.
  ///
  /// In zh, this message translates to:
  /// **'朗讀語音由裝置系統內建文字轉語音引擎提供。'**
  String get aboutTtsNote;

  /// No description provided for @feedbackTitle.
  ///
  /// In zh, this message translates to:
  /// **'意見回饋'**
  String get feedbackTitle;

  /// No description provided for @feedbackCategoryLabel.
  ///
  /// In zh, this message translates to:
  /// **'類型'**
  String get feedbackCategoryLabel;

  /// No description provided for @feedbackCategoryBug.
  ///
  /// In zh, this message translates to:
  /// **'回報問題'**
  String get feedbackCategoryBug;

  /// No description provided for @feedbackCategorySuggestion.
  ///
  /// In zh, this message translates to:
  /// **'功能建議'**
  String get feedbackCategorySuggestion;

  /// No description provided for @feedbackCategoryOther.
  ///
  /// In zh, this message translates to:
  /// **'其他'**
  String get feedbackCategoryOther;

  /// No description provided for @feedbackMessageLabel.
  ///
  /// In zh, this message translates to:
  /// **'內容'**
  String get feedbackMessageLabel;

  /// No description provided for @feedbackMessageHint.
  ///
  /// In zh, this message translates to:
  /// **'告訴我們你遇到的問題，或希望增加什麼功能…'**
  String get feedbackMessageHint;

  /// No description provided for @feedbackEmailLabel.
  ///
  /// In zh, this message translates to:
  /// **'聯絡信箱（選填）'**
  String get feedbackEmailLabel;

  /// No description provided for @feedbackEmailHint.
  ///
  /// In zh, this message translates to:
  /// **'想收到回覆的話可以留信箱'**
  String get feedbackEmailHint;

  /// No description provided for @feedbackSubmit.
  ///
  /// In zh, this message translates to:
  /// **'送出回饋'**
  String get feedbackSubmit;

  /// No description provided for @feedbackEmpty.
  ///
  /// In zh, this message translates to:
  /// **'請先填寫內容再送出'**
  String get feedbackEmpty;

  /// No description provided for @feedbackThanks.
  ///
  /// In zh, this message translates to:
  /// **'感謝你的回饋，我們會盡快查看！'**
  String get feedbackThanks;

  /// No description provided for @feedbackFailed.
  ///
  /// In zh, this message translates to:
  /// **'送出失敗，請確認網路連線後再試一次'**
  String get feedbackFailed;

  /// No description provided for @statsDescNgsl.
  ///
  /// In zh, this message translates to:
  /// **'英語核心單字表，取自公開頻率研究，完整學會這 2,809 個字，可達到一般日常英文文本約 92% 的理解涵蓋率（資料來源：New General Service List Project）。'**
  String get statsDescNgsl;

  /// No description provided for @statsDescSpoken.
  ///
  /// In zh, this message translates to:
  /// **'從日常口語對話中挑出的 720 個高頻詞彙，專門加強「聽」與「說」情境的反應速度，跟 NGSL 核心單字表互補，涵蓋口語裡常用、但書面文字裡較少出現的用詞。'**
  String get statsDescSpoken;

  /// No description provided for @statsDescPhrase.
  ///
  /// In zh, this message translates to:
  /// **'506 個英語母語人士真正常用的固定搭配與語塊（例如 \"in order to\"、\"as well as\"），不是單字而是「一整組一起記」的片語，能幫助說出更自然道地的英文。'**
  String get statsDescPhrase;

  /// No description provided for @statsDescPhave.
  ///
  /// In zh, this message translates to:
  /// **'收錄 150 個最常用的片語動詞（例如 \"look after\"、\"give up\"），這類「動詞+介詞」組合是英語學習者公認最難掌握的一塊，集中複習這 150 個能涵蓋大部分日常會遇到的片語動詞。'**
  String get statsDescPhave;

  /// No description provided for @summaryReadBilingual.
  ///
  /// In zh, this message translates to:
  /// **'英雙讀'**
  String get summaryReadBilingual;

  /// No description provided for @summaryReadEnglishOnly.
  ///
  /// In zh, this message translates to:
  /// **'純英文'**
  String get summaryReadEnglishOnly;

  /// No description provided for @settingsSummaryLine.
  ///
  /// In zh, this message translates to:
  /// **'{mode}・讀{count}次・{rate}x'**
  String settingsSummaryLine(String mode, int count, String rate);

  /// No description provided for @notifChannelName.
  ///
  /// In zh, this message translates to:
  /// **'複習提醒'**
  String get notifChannelName;

  /// No description provided for @notifChannelDesc.
  ///
  /// In zh, this message translates to:
  /// **'每日英文複習提醒通知'**
  String get notifChannelDesc;

  /// No description provided for @notifDailyTitle.
  ///
  /// In zh, this message translates to:
  /// **'該複習英文囉！'**
  String get notifDailyTitle;

  /// No description provided for @notifDailyBody.
  ///
  /// In zh, this message translates to:
  /// **'回來聽幾個單字，鞏固今天學到的內容吧'**
  String get notifDailyBody;

  /// No description provided for @notifInactivityTitle.
  ///
  /// In zh, this message translates to:
  /// **'好久不見 👋'**
  String get notifInactivityTitle;

  /// No description provided for @notifInactivityBody.
  ///
  /// In zh, this message translates to:
  /// **'已經好幾天沒複習了，回來聽幾個單字，別讓記憶生疏了'**
  String get notifInactivityBody;

  /// No description provided for @audioChannelName.
  ///
  /// In zh, this message translates to:
  /// **'英語學習朗讀'**
  String get audioChannelName;

  /// No description provided for @importLangId.
  ///
  /// In zh, this message translates to:
  /// **'印尼文'**
  String get importLangId;

  /// No description provided for @datasetNameNgsl.
  ///
  /// In zh, this message translates to:
  /// **'NGSL 2809 核心單字'**
  String get datasetNameNgsl;

  /// No description provided for @datasetShortNgsl.
  ///
  /// In zh, this message translates to:
  /// **'NGSL 2809字'**
  String get datasetShortNgsl;

  /// No description provided for @datasetNameSpoken.
  ///
  /// In zh, this message translates to:
  /// **'NGSL 口語 720 字'**
  String get datasetNameSpoken;

  /// No description provided for @datasetShortSpoken.
  ///
  /// In zh, this message translates to:
  /// **'口語 720字'**
  String get datasetShortSpoken;

  /// No description provided for @datasetNamePhrase.
  ///
  /// In zh, this message translates to:
  /// **'PHRASE List 高頻語塊 (506)'**
  String get datasetNamePhrase;

  /// No description provided for @datasetShortPhrase.
  ///
  /// In zh, this message translates to:
  /// **'高頻語塊 506'**
  String get datasetShortPhrase;

  /// No description provided for @datasetNamePhave.
  ///
  /// In zh, this message translates to:
  /// **'PhaVE List 片語動詞 (150)'**
  String get datasetNamePhave;

  /// No description provided for @datasetShortPhave.
  ///
  /// In zh, this message translates to:
  /// **'片語動詞 150'**
  String get datasetShortPhave;

  /// No description provided for @updateDownloadedMessage.
  ///
  /// In zh, this message translates to:
  /// **'新版本已下載完成'**
  String get updateDownloadedMessage;

  /// No description provided for @updateRestartButton.
  ///
  /// In zh, this message translates to:
  /// **'重新啟動'**
  String get updateRestartButton;

  /// No description provided for @importLangEs.
  ///
  /// In zh, this message translates to:
  /// **'西班牙文'**
  String get importLangEs;

  /// No description provided for @importLangPt.
  ///
  /// In zh, this message translates to:
  /// **'葡萄牙文'**
  String get importLangPt;

  /// No description provided for @menuIntro.
  ///
  /// In zh, this message translates to:
  /// **'功能介紹'**
  String get menuIntro;

  /// No description provided for @introSkip.
  ///
  /// In zh, this message translates to:
  /// **'略過'**
  String get introSkip;

  /// No description provided for @introNext.
  ///
  /// In zh, this message translates to:
  /// **'下一步'**
  String get introNext;

  /// No description provided for @introStart.
  ///
  /// In zh, this message translates to:
  /// **'開始學習'**
  String get introStart;

  /// No description provided for @introTitle1.
  ///
  /// In zh, this message translates to:
  /// **'用 20/80 法則學英文'**
  String get introTitle1;

  /// No description provided for @introBody1.
  ///
  /// In zh, this message translates to:
  /// **'學會 NGSL 2,809 個核心單字，就能看懂一般日常英文約 92% 的內容。不背冷僻字，時間都花在真正用得到的地方。'**
  String get introBody1;

  /// No description provided for @introTitle2.
  ///
  /// In zh, this message translates to:
  /// **'特別寫給這樣的你'**
  String get introTitle2;

  /// No description provided for @introBody2.
  ///
  /// In zh, this message translates to:
  /// **'學過很多次英文卻總是半途而廢、年紀漸長記性不如從前、生活中沒有英文環境——這套方法就是為你設計的，幫你重新找回學英文的信心。'**
  String get introBody2;

  /// No description provided for @introTitle3.
  ///
  /// In zh, this message translates to:
  /// **'背景朗讀，零碎時間變學習時間'**
  String get introTitle3;

  /// No description provided for @introBody3.
  ///
  /// In zh, this message translates to:
  /// **'通勤、散步、做家事、運動時都能聽。鎖定螢幕或切換到其他 App，朗讀都會繼續，不用一直盯著螢幕。'**
  String get introBody3;

  /// No description provided for @introTitle4.
  ///
  /// In zh, this message translates to:
  /// **'雙語朗讀＋不熟悉單字庫'**
  String get introTitle4;

  /// No description provided for @introBody4.
  ///
  /// In zh, this message translates to:
  /// **'先念英文、再念中文意思，不看螢幕也聽得懂。不熟的字按星號標記，用「僅不熟悉」模式集中反覆聽，直到真正記住。'**
  String get introBody4;

  /// No description provided for @introTitle5.
  ///
  /// In zh, this message translates to:
  /// **'匯入自己的教材，14 種語言都能聽'**
  String get introTitle5;

  /// No description provided for @introBody5.
  ///
  /// In zh, this message translates to:
  /// **'課本單字、工作常用語、考試範圍，存成 CSV 檔就能匯入，一樣背景朗讀、標記不熟悉。不只英文——日文、韓文、法文、德文、西班牙文、泰文、阿拉伯文等 14 種語言都能朗讀，翻譯也能選你熟悉的語言。（部分語言需先在手機下載語音）'**
  String get introBody5;

  /// No description provided for @introTitle6.
  ///
  /// In zh, this message translates to:
  /// **'四大學術教材，免費開始'**
  String get introTitle6;

  /// No description provided for @introBody6.
  ///
  /// In zh, this message translates to:
  /// **'核心單字 NGSL 2809、口語常用字 720、高頻語塊 506、片語動詞 150，皆來自公開學術研究。每份教材都有免費內容，可以先體驗再決定。'**
  String get introBody6;

  /// No description provided for @importWordLangLabel.
  ///
  /// In zh, this message translates to:
  /// **'第一欄是什麼語言？（決定朗讀語音）'**
  String get importWordLangLabel;

  /// No description provided for @importVoiceMissing.
  ///
  /// In zh, this message translates to:
  /// **'手機目前沒有「{language}」的朗讀語音，會念不出來。請到手機「設定 → 文字轉語音」安裝該語言的語音包。'**
  String importVoiceMissing(String language);

  /// 選單：分享 App 給朋友（依測試者回饋新增，第十五版）
  ///
  /// In zh, this message translates to:
  /// **'分享給朋友'**
  String get menuShare;

  /// 分享文字，程式會在後面接上 Play 商店連結
  ///
  /// In zh, this message translates to:
  /// **'推薦你一個學英文的 App「智慧聽覺巡航」：用 20/80 法則，只學涵蓋 92% 日常英文的核心單字，通勤、走路、做家事時背景朗讀，雙語一起聽。免費下載：'**
  String get shareMessage;

  /// 選單：廣告隱私設定（Google UMP 隱私選項表單，只在歐洲等需要同意的地區顯示，第十七版）
  ///
  /// In zh, this message translates to:
  /// **'廣告隱私設定'**
  String get menuAdPrivacy;

  /// No description provided for @switchDatasetButton.
  ///
  /// In zh, this message translates to:
  /// **'切換教材'**
  String get switchDatasetButton;

  /// No description provided for @unlockMoreButton.
  ///
  /// In zh, this message translates to:
  /// **'解鎖更多'**
  String get unlockMoreButton;

  /// No description provided for @playShortStart.
  ///
  /// In zh, this message translates to:
  /// **'開始朗讀'**
  String get playShortStart;

  /// No description provided for @playShortPause.
  ///
  /// In zh, this message translates to:
  /// **'暫停'**
  String get playShortPause;

  /// No description provided for @cycleShort.
  ///
  /// In zh, this message translates to:
  /// **'第 {n} 輪'**
  String cycleShort(int n);

  /// No description provided for @wordSizeLabel.
  ///
  /// In zh, this message translates to:
  /// **'單字大小'**
  String get wordSizeLabel;

  /// No description provided for @wordSizeSmall.
  ///
  /// In zh, this message translates to:
  /// **'小'**
  String get wordSizeSmall;

  /// No description provided for @wordSizeMedium.
  ///
  /// In zh, this message translates to:
  /// **'中'**
  String get wordSizeMedium;

  /// No description provided for @wordSizeLarge.
  ///
  /// In zh, this message translates to:
  /// **'大'**
  String get wordSizeLarge;

  /// No description provided for @lockScreenCoverLabel.
  ///
  /// In zh, this message translates to:
  /// **'鎖屏顯示大字封面'**
  String get lockScreenCoverLabel;

  /// No description provided for @lockScreenCoverDesc.
  ///
  /// In zh, this message translates to:
  /// **'關閉後，鎖屏只顯示一般的小字卡片'**
  String get lockScreenCoverDesc;

  /// No description provided for @appearanceLabel.
  ///
  /// In zh, this message translates to:
  /// **'外觀'**
  String get appearanceLabel;

  /// No description provided for @appearanceSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟隨系統'**
  String get appearanceSystem;

  /// No description provided for @appearanceLight.
  ///
  /// In zh, this message translates to:
  /// **'淺色'**
  String get appearanceLight;

  /// No description provided for @appearanceDark.
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get appearanceDark;

  /// No description provided for @notifLastHeard.
  ///
  /// In zh, this message translates to:
  /// **'上次聽到：{word}'**
  String notifLastHeard(String word);

  /// No description provided for @notifStarredLeft.
  ///
  /// In zh, this message translates to:
  /// **'還有 {count} 個不熟悉單字'**
  String notifStarredLeft(int count);

  /// No description provided for @notifActionStart.
  ///
  /// In zh, this message translates to:
  /// **'▶ 開始朗讀'**
  String get notifActionStart;

  /// No description provided for @notifActionSnooze.
  ///
  /// In zh, this message translates to:
  /// **'稍後提醒'**
  String get notifActionSnooze;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'en',
        'es',
        'id',
        'ja',
        'ko',
        'pt',
        'th',
        'vi',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hans':
            return AppLocalizationsZhHans();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'id':
      return AppLocalizationsId();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'th':
      return AppLocalizationsTh();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
