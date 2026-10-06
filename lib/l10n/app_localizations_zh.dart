// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '智慧聽覺巡航';

  @override
  String get statsTooltip => '學習統計';

  @override
  String get moreTooltip => '更多';

  @override
  String get menuPremium => '升級 Premium';

  @override
  String get menuVoicePreview => '語音預覽';

  @override
  String get menuImport => '匯入自訂教材';

  @override
  String get menuAbout => '關於本 App / 版權聲明';

  @override
  String wordNumberLabel(int current, int total) {
    return 'No. $current / $total';
  }

  @override
  String cycleLabel(int n) {
    return '第 $n 輪學習';
  }

  @override
  String roundProgressLabel(int heard, int total, int percent) {
    return '本輪已聽過進度：$heard / $total ($percent%)';
  }

  @override
  String get playButtonStart => '開始巡航朗讀';

  @override
  String get playButtonPause => '暫停巡航朗讀';

  @override
  String get starButton => '加入不熟悉單字庫';

  @override
  String get navPrevious => '上一個';

  @override
  String get navReplay => '再讀一次';

  @override
  String get navNext => '下一個';

  @override
  String get statsTitle => '學習統計';

  @override
  String get todayLearnedLabel => '今日已學習';

  @override
  String get totalLearnedLabel => '累計已學習';

  @override
  String get unitCount => '個';

  @override
  String get datasetProgressHeader => '各教材學習進度';

  @override
  String itemsCountLabel(int learned, int total) {
    return '$learned / $total 個項目';
  }

  @override
  String get dailyReminderHeader => '每日複習提醒';

  @override
  String get enableDailyReminder => '開啟每日提醒';

  @override
  String get reminderTimeLabel => '提醒時間';

  @override
  String reminderScheduledMessage(String time) {
    return '已排定 $time 提醒';
  }

  @override
  String get reminderFailedMessage => '排程失敗，請確認電池優化設定或重新開啟提醒開關';

  @override
  String get batteryOptButtonLabel => '提醒沒準時跳出？點此排除電池優化限制';

  @override
  String get batteryOptSnackbar => '請確認「省電策略」選擇「無限制」';

  @override
  String get miuiAutostartButtonLabel => '小米/Redmi 手機請另外開啟「自啟動」';

  @override
  String get miuiAutostartSnackbar => '小米手機請在清單裡找到本App並開啟自啟動（其他廠牌手機可忽略這個按鈕）';

  @override
  String get settingsTitle => '播放設定';

  @override
  String starredCountLabel(int n) {
    return '已標記 $n 個項目';
  }

  @override
  String get speakOnManualNavigateLabel => '手動切換單字時發音';

  @override
  String get showTranslationLabel => '顯示翻譯';

  @override
  String intervalSecondsLabel(String seconds) {
    return '單字間隔停頓：$seconds 秒';
  }

  @override
  String speechRateLabel(String rate) {
    return '朗讀語速：${rate}x';
  }

  @override
  String get scopeModeLabel => '播放範圍 / 模式';

  @override
  String get scopeAllRandom => '全部清單（隨機播放）';

  @override
  String get scopeAllSequential => '全部清單（依序播放）';

  @override
  String get scopeStarredRandom => '僅不熟悉（隨機播放）';

  @override
  String get scopeStarredSequential => '僅不熟悉（依序播放）';

  @override
  String get readModeLabel => '朗讀內容模式';

  @override
  String get readModeBilingual => '雙語朗讀（英文＋翻譯）';

  @override
  String get readModeEnglishOnly => '純英文';

  @override
  String get repeatCountLabel => '英文重複朗讀次數';

  @override
  String get repeatOnce => '讀 1 次';

  @override
  String get repeatTwice => '讀 2 次（推薦）';

  @override
  String get repeatThrice => '讀 3 次';

  @override
  String get commonCancel => '取消';

  @override
  String get commonDelete => '刪除';

  @override
  String get voicePreviewIntro =>
      '這裡列出手機裡可用的英文語音，點播放圖示即可試聽。正式朗讀時 App 會統一使用系統預設語音（依語言自動選擇），這裡純粹讓你先聽聽看手機裡有哪些語音。';

  @override
  String get voicePreviewNoVoices => '找不到可用的語音，請確認手機已安裝英文語音包。';

  @override
  String get voicePreviewUnknownVoice => '未知語音';

  @override
  String get paywallPurchaseSuccess => '訂閱成功！已解鎖完整內容並移除廣告。';

  @override
  String get paywallPurchaseFailed => '購買未完成，請稍後再試一次。';

  @override
  String get paywallRestoreSuccess => '已恢復 Premium 訂閱！';

  @override
  String get paywallRestoreNotFound => '找不到可恢復的購買紀錄。';

  @override
  String get paywallAlreadyPremium => '您已經是 Premium 訂閱戶 🎉';

  @override
  String get paywallHeadline => '解鎖完整學習內容';

  @override
  String get paywallBenefitAllContent => '四份教材 100% 完整開放';

  @override
  String get paywallBenefitNoAds => '完全移除廣告';

  @override
  String get paywallBenefitBackground => '背景播放、鎖屏顯示';

  @override
  String get paywallRestoreButton => '恢復先前購買';

  @override
  String get paywallNoPackages => '目前沒有可用的訂閱方案，請稍後再試。';

  @override
  String get paywallPlanMonthly => '月繳方案';

  @override
  String get paywallPlanAnnual => '年繳方案';

  @override
  String get paywallTermsNote =>
      '訂閱會自動續訂，可隨時在 Google Play「付款和訂閱」中取消。取消後，Premium 功能可繼續使用到本期結束，之後自動改回免費版。';

  @override
  String get paywallManageSubscription => '管理 / 取消訂閱';

  @override
  String get unlockRewardSnackbar => '已多解鎖 20 個項目！';

  @override
  String unlockFreeProgress(int unlocked, int total) {
    return '免費版已解鎖 $unlocked / $total 個項目';
  }

  @override
  String get unlockAdLoading => '廣告準備中…';

  @override
  String get unlockWatchAd => '看廣告 +20';

  @override
  String get importIntro => '可以匯入自己準備的單字、片語或常用例句（例如自己書上的內容），匯入後會跟內建教材一樣可以切換朗讀。';

  @override
  String get importFormatTitle => '匯入格式（CSV，含表頭）';

  @override
  String get importSampleApple => '蘋果';

  @override
  String get importSampleGiveUp => '放棄';

  @override
  String get importSampleHowAreYou => '你今天過得怎麼樣？';

  @override
  String get importFormatHint =>
      '第一欄放英文（單字、片語、整句例句都可以），第二欄放對應翻譯，存成 CSV 檔即可匯入。也可以匯入英文以外的語言，在下方選擇第一欄語言即可。';

  @override
  String get importGetTemplate => '取得範本檔案';

  @override
  String importTemplateSaved(String path) {
    return '範本已存到暫存資料夾：$path';
  }

  @override
  String get importNameLabel => '這份教材的名稱';

  @override
  String get importNameHint => '例如：多益核心例句';

  @override
  String get importNameRequired => '請先幫這份教材取個名字';

  @override
  String get importTranslationLangLabel => '翻譯欄位是什麼語言？';

  @override
  String get importLangZh => '中文';

  @override
  String get importLangJa => '日文';

  @override
  String get importLangKo => '韓文';

  @override
  String get importLangVi => '越南文';

  @override
  String get importLangEn => '英文';

  @override
  String get importButton => '選擇 CSV 檔並匯入';

  @override
  String get importingInProgress => '匯入中…';

  @override
  String importDone(int count) {
    return '匯入完成！共 $count 筆';
  }

  @override
  String importDoneWithSkipped(int count, int skipped) {
    return '匯入完成！共 $count 筆（略過 $skipped 筆空白列）';
  }

  @override
  String importFailedWithReason(String reason) {
    return '匯入失敗：$reason';
  }

  @override
  String get importFailedGeneric => '匯入失敗，請確認檔案格式是否正確';

  @override
  String get importErrorEncoding =>
      '檔案編碼不是 UTF-8，無法讀取。請用 Excel「另存新檔」時選擇「CSV UTF-8（逗號分隔）」格式，或用純文字編輯器另存成 UTF-8 編碼。';

  @override
  String get importErrorParse => 'CSV 格式解析失敗，請確認是否為標準逗號分隔格式。';

  @override
  String get importErrorEmpty => '檔案是空的，請確認內容格式正確。';

  @override
  String get importErrorNoRows => '沒有解析到任何有效的資料列，請確認格式是否正確。';

  @override
  String get importDeleteTitle => '刪除自訂教材';

  @override
  String importDeleteConfirm(String name) {
    return '確定要刪除「$name」嗎？這個動作無法復原。';
  }

  @override
  String get importedListHeader => '已匯入的自訂教材';

  @override
  String importItemCount(int n) {
    return '$n 個項目';
  }

  @override
  String get aboutFeedbackButton => '意見回饋 / 回報問題';

  @override
  String get aboutAttributionIntro => '本 App 之單字/語塊資料取自以下公開學術研究成果，特此致謝並標明出處：';

  @override
  String get aboutNgslTitle => 'NGSL 2809（核心單字）';

  @override
  String get aboutSpokenTitle => 'NGSL-Spoken 720（口語常用字）';

  @override
  String get aboutPhaveTitle => 'PhaVE List（片語動詞）';

  @override
  String get aboutPhraseTitle => 'PHRASE List（高頻語塊）';

  @override
  String get aboutLicenseCcBySa =>
      '採用創用CC「姓名標示-相同方式分享 4.0 國際授權條款」（CC BY-SA 4.0）。';

  @override
  String get aboutLicenseCcBy => '採用創用CC「姓名標示 4.0 國際授權條款」（CC BY 4.0）。';

  @override
  String get aboutPhraseRights => '版權歸原作者所有，本 App 依授權範圍使用於教學用途。';

  @override
  String aboutSourceLabel(String name) {
    return '原作品：$name';
  }

  @override
  String aboutLicenseLabel(String name) {
    return '授權條款：$name';
  }

  @override
  String get aboutTtsNote => '朗讀語音由裝置系統內建文字轉語音引擎提供。';

  @override
  String get feedbackTitle => '意見回饋';

  @override
  String get feedbackCategoryLabel => '類型';

  @override
  String get feedbackCategoryBug => '回報問題';

  @override
  String get feedbackCategorySuggestion => '功能建議';

  @override
  String get feedbackCategoryOther => '其他';

  @override
  String get feedbackMessageLabel => '內容';

  @override
  String get feedbackMessageHint => '告訴我們你遇到的問題，或希望增加什麼功能…';

  @override
  String get feedbackEmailLabel => '聯絡信箱（選填）';

  @override
  String get feedbackEmailHint => '想收到回覆的話可以留信箱';

  @override
  String get feedbackSubmit => '送出回饋';

  @override
  String get feedbackEmpty => '請先填寫內容再送出';

  @override
  String get feedbackThanks => '感謝你的回饋，我們會盡快查看！';

  @override
  String get feedbackFailed => '送出失敗，請確認網路連線後再試一次';

  @override
  String get statsDescNgsl =>
      '英語核心單字表，取自公開頻率研究，完整學會這 2,809 個字，可達到一般日常英文文本約 92% 的理解涵蓋率（資料來源：New General Service List Project）。';

  @override
  String get statsDescSpoken =>
      '從日常口語對話中挑出的 720 個高頻詞彙，專門加強「聽」與「說」情境的反應速度，跟 NGSL 核心單字表互補，涵蓋口語裡常用、但書面文字裡較少出現的用詞。';

  @override
  String get statsDescPhrase =>
      '506 個英語母語人士真正常用的固定搭配與語塊（例如 \"in order to\"、\"as well as\"），不是單字而是「一整組一起記」的片語，能幫助說出更自然道地的英文。';

  @override
  String get statsDescPhave =>
      '收錄 150 個最常用的片語動詞（例如 \"look after\"、\"give up\"），這類「動詞+介詞」組合是英語學習者公認最難掌握的一塊，集中複習這 150 個能涵蓋大部分日常會遇到的片語動詞。';

  @override
  String get summaryReadBilingual => '英雙讀';

  @override
  String get summaryReadEnglishOnly => '純英文';

  @override
  String settingsSummaryLine(String mode, int count, String rate) {
    return '$mode・讀$count次・${rate}x';
  }

  @override
  String get notifChannelName => '複習提醒';

  @override
  String get notifChannelDesc => '每日英文複習提醒通知';

  @override
  String get notifDailyTitle => '該複習英文囉！';

  @override
  String get notifDailyBody => '回來聽幾個單字，鞏固今天學到的內容吧';

  @override
  String get notifInactivityTitle => '好久不見 👋';

  @override
  String get notifInactivityBody => '已經好幾天沒複習了，回來聽幾個單字，別讓記憶生疏了';

  @override
  String get audioChannelName => '英語學習朗讀';

  @override
  String get importLangId => '印尼文';

  @override
  String get datasetNameNgsl => 'NGSL 2809 核心單字';

  @override
  String get datasetShortNgsl => 'NGSL 2809字';

  @override
  String get datasetNameSpoken => 'NGSL 口語 720 字';

  @override
  String get datasetShortSpoken => '口語 720字';

  @override
  String get datasetNamePhrase => 'PHRASE List 高頻語塊 (506)';

  @override
  String get datasetShortPhrase => '高頻語塊 506';

  @override
  String get datasetNamePhave => 'PhaVE List 片語動詞 (150)';

  @override
  String get datasetShortPhave => '片語動詞 150';

  @override
  String get updateDownloadedMessage => '新版本已下載完成';

  @override
  String get updateRestartButton => '重新啟動';

  @override
  String get importLangEs => '西班牙文';

  @override
  String get importLangPt => '葡萄牙文';

  @override
  String get menuIntro => '功能介紹';

  @override
  String get introSkip => '略過';

  @override
  String get introNext => '下一步';

  @override
  String get introStart => '開始學習';

  @override
  String get introTitle1 => '用 20/80 法則學英文';

  @override
  String get introBody1 =>
      '學會 NGSL 2,809 個核心單字，就能看懂一般日常英文約 92% 的內容。不背冷僻字，時間都花在真正用得到的地方。';

  @override
  String get introTitle2 => '特別寫給這樣的你';

  @override
  String get introBody2 =>
      '學過很多次英文卻總是半途而廢、年紀漸長記性不如從前、生活中沒有英文環境——這套方法就是為你設計的，幫你重新找回學英文的信心。';

  @override
  String get introTitle3 => '背景朗讀，零碎時間變學習時間';

  @override
  String get introBody3 => '通勤、散步、做家事、運動時都能聽。鎖定螢幕或切換到其他 App，朗讀都會繼續，不用一直盯著螢幕。';

  @override
  String get introTitle4 => '雙語朗讀＋不熟悉單字庫';

  @override
  String get introBody4 =>
      '先念英文、再念中文意思，不看螢幕也聽得懂。不熟的字按星號標記，用「僅不熟悉」模式集中反覆聽，直到真正記住。';

  @override
  String get introTitle5 => '匯入自己的教材，14 種語言都能聽';

  @override
  String get introBody5 =>
      '課本單字、工作常用語、考試範圍，存成 CSV 檔就能匯入，一樣背景朗讀、標記不熟悉。不只英文——日文、韓文、法文、德文、西班牙文、泰文、阿拉伯文等 14 種語言都能朗讀，翻譯也能選你熟悉的語言。（部分語言需先在手機下載語音）';

  @override
  String get introTitle6 => '四大學術教材，免費開始';

  @override
  String get introBody6 =>
      '核心單字 NGSL 2809、口語常用字 720、高頻語塊 506、片語動詞 150，皆來自公開學術研究。每份教材都有免費內容，可以先體驗再決定。';

  @override
  String get importWordLangLabel => '第一欄是什麼語言？（決定朗讀語音）';

  @override
  String importVoiceMissing(String language) {
    return '手機目前沒有「$language」的朗讀語音，會念不出來。請到手機「設定 → 文字轉語音」安裝該語言的語音包。';
  }

  @override
  String get menuShare => '分享給朋友';

  @override
  String get shareMessage =>
      '推薦你一個學英文的 App「智慧聽覺巡航」：用 20/80 法則，只學涵蓋 92% 日常英文的核心單字，通勤、走路、做家事時背景朗讀，雙語一起聽。免費下載：';

  @override
  String get menuAdPrivacy => '廣告隱私設定';

  @override
  String get switchDatasetButton => '切換教材';

  @override
  String get unlockMoreButton => '解鎖更多';

  @override
  String get playShortStart => '開始朗讀';

  @override
  String get playShortPause => '暫停';

  @override
  String cycleShort(int n) {
    return '第 $n 輪';
  }

  @override
  String get wordSizeLabel => '單字大小';

  @override
  String get wordSizeSmall => '小';

  @override
  String get wordSizeMedium => '中';

  @override
  String get wordSizeLarge => '大';

  @override
  String get lockScreenCoverLabel => '鎖屏顯示大字封面';

  @override
  String get lockScreenCoverDesc => '關閉後，鎖屏只顯示一般的小字卡片';

  @override
  String get appearanceLabel => '外觀';

  @override
  String get appearanceSystem => '跟隨系統';

  @override
  String get appearanceLight => '淺色';

  @override
  String get appearanceDark => '深色';

  @override
  String notifLastHeard(String word) {
    return '上次聽到：$word';
  }

  @override
  String notifStarredLeft(int count) {
    return '還有 $count 個不熟悉單字';
  }

  @override
  String get notifActionStart => '▶ 開始朗讀';

  @override
  String get notifActionSnooze => '稍後提醒';
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

  @override
  String get appTitle => '智慧听觉巡航';

  @override
  String get statsTooltip => '学习统计';

  @override
  String get moreTooltip => '更多';

  @override
  String get menuPremium => '升级 Premium';

  @override
  String get menuVoicePreview => '语音预览';

  @override
  String get menuImport => '导入自定义教材';

  @override
  String get menuAbout => '关于本 App / 版权声明';

  @override
  String wordNumberLabel(int current, int total) {
    return 'No. $current / $total';
  }

  @override
  String cycleLabel(int n) {
    return '第 $n 轮学习';
  }

  @override
  String roundProgressLabel(int heard, int total, int percent) {
    return '本轮已听过进度：$heard / $total ($percent%)';
  }

  @override
  String get playButtonStart => '开始巡航朗读';

  @override
  String get playButtonPause => '暂停巡航朗读';

  @override
  String get starButton => '加入不熟悉单词库';

  @override
  String get navPrevious => '上一个';

  @override
  String get navReplay => '再读一次';

  @override
  String get navNext => '下一个';

  @override
  String get statsTitle => '学习统计';

  @override
  String get todayLearnedLabel => '今日已学习';

  @override
  String get totalLearnedLabel => '累计已学习';

  @override
  String get unitCount => '个';

  @override
  String get datasetProgressHeader => '各教材学习进度';

  @override
  String itemsCountLabel(int learned, int total) {
    return '$learned / $total 个项目';
  }

  @override
  String get dailyReminderHeader => '每日复习提醒';

  @override
  String get enableDailyReminder => '打开每日提醒';

  @override
  String get reminderTimeLabel => '提醒时间';

  @override
  String reminderScheduledMessage(String time) {
    return '已排定 $time 提醒';
  }

  @override
  String get reminderFailedMessage => '调度失败，请确认电池优化设置或重新打开提醒开关';

  @override
  String get batteryOptButtonLabel => '提醒没准时跳出？点此排除电池优化限制';

  @override
  String get batteryOptSnackbar => '请确认“省电策略”选择“无限制”';

  @override
  String get miuiAutostartButtonLabel => '小米/Redmi 手机请另外打开“自启动”';

  @override
  String get miuiAutostartSnackbar => '小米手机请在清单里找到本App并打开自启动（其他厂牌手机可忽略这个按钮）';

  @override
  String get settingsTitle => '播放设置';

  @override
  String starredCountLabel(int n) {
    return '已标记 $n 个项目';
  }

  @override
  String get speakOnManualNavigateLabel => '手动切换单词时发音';

  @override
  String get showTranslationLabel => '显示翻译';

  @override
  String intervalSecondsLabel(String seconds) {
    return '单词间隔停顿：$seconds 秒';
  }

  @override
  String speechRateLabel(String rate) {
    return '朗读语速：${rate}x';
  }

  @override
  String get scopeModeLabel => '播放范围 / 模式';

  @override
  String get scopeAllRandom => '全部清单（随机播放）';

  @override
  String get scopeAllSequential => '全部清单（依序播放）';

  @override
  String get scopeStarredRandom => '仅不熟悉（随机播放）';

  @override
  String get scopeStarredSequential => '仅不熟悉（依序播放）';

  @override
  String get readModeLabel => '朗读内容模式';

  @override
  String get readModeBilingual => '双语朗读（英文＋翻译）';

  @override
  String get readModeEnglishOnly => '纯英文';

  @override
  String get repeatCountLabel => '英文重复朗读次数';

  @override
  String get repeatOnce => '读 1 次';

  @override
  String get repeatTwice => '读 2 次（推荐）';

  @override
  String get repeatThrice => '读 3 次';

  @override
  String get commonCancel => '取消';

  @override
  String get commonDelete => '删除';

  @override
  String get voicePreviewIntro =>
      '这里列出手机里可用的英文语音，点播放图标即可试听。正式朗读时 App 会统一使用系统缺省语音（依语言自动选择），这里纯粹让你先听听看手机里有哪些语音。';

  @override
  String get voicePreviewNoVoices => '找不到可用的语音，请确认手机已安装英文语音包。';

  @override
  String get voicePreviewUnknownVoice => '未知语音';

  @override
  String get paywallPurchaseSuccess => '订阅成功！已解锁完整内容并移除广告。';

  @override
  String get paywallPurchaseFailed => '购买未完成，请稍后再试一次。';

  @override
  String get paywallRestoreSuccess => '已恢复 Premium 订阅！';

  @override
  String get paywallRestoreNotFound => '找不到可恢复的购买纪录。';

  @override
  String get paywallAlreadyPremium => '您已经是 Premium 订阅户 🎉';

  @override
  String get paywallHeadline => '解锁完整学习内容';

  @override
  String get paywallBenefitAllContent => '四份教材 100% 完整开放';

  @override
  String get paywallBenefitNoAds => '完全移除广告';

  @override
  String get paywallBenefitBackground => '背景播放、锁屏显示';

  @override
  String get paywallRestoreButton => '恢复先前购买';

  @override
  String get paywallNoPackages => '目前没有可用的订阅方案，请稍后再试。';

  @override
  String get paywallPlanMonthly => '月缴方案';

  @override
  String get paywallPlanAnnual => '年缴方案';

  @override
  String get paywallTermsNote =>
      '订阅会自动续订，可随时在 Google Play“付款和订阅”中取消。取消后，Premium 功能可继续使用到本期结束，之后自动改回免费版。';

  @override
  String get paywallManageSubscription => '管理 / 取消订阅';

  @override
  String get unlockRewardSnackbar => '已多解锁 20 个项目！';

  @override
  String unlockFreeProgress(int unlocked, int total) {
    return '免费版已解锁 $unlocked / $total 个项目';
  }

  @override
  String get unlockAdLoading => '广告准备中…';

  @override
  String get unlockWatchAd => '看广告 +20';

  @override
  String get importIntro => '可以导入自己准备的单词、词组或常用例句（例如自己书上的内容），导入后会跟内置教材一样可以切换朗读。';

  @override
  String get importFormatTitle => '导入格式（CSV，含表头）';

  @override
  String get importSampleApple => '苹果';

  @override
  String get importSampleGiveUp => '放弃';

  @override
  String get importSampleHowAreYou => '你今天过得怎么样？';

  @override
  String get importFormatHint =>
      '第一栏放英文（单词、词组、整句例句都可以），第二栏放对应翻译，存成 CSV 档即可导入。也可以导入英语以外的语言，在下方选择第一栏语言即可。';

  @override
  String get importGetTemplate => '取得范本文件';

  @override
  String importTemplateSaved(String path) {
    return '范本已存到暂存文件夹：$path';
  }

  @override
  String get importNameLabel => '这份教材的名称';

  @override
  String get importNameHint => '例如：多益内核例句';

  @override
  String get importNameRequired => '请先帮这份教材取个名字';

  @override
  String get importTranslationLangLabel => '翻译字段是什么语言？';

  @override
  String get importLangZh => '中文';

  @override
  String get importLangJa => '日文';

  @override
  String get importLangKo => '韩文';

  @override
  String get importLangVi => '越南文';

  @override
  String get importLangEn => '英文';

  @override
  String get importButton => '选择 CSV 档并导入';

  @override
  String get importingInProgress => '导入中…';

  @override
  String importDone(int count) {
    return '导入完成！共 $count 笔';
  }

  @override
  String importDoneWithSkipped(int count, int skipped) {
    return '导入完成！共 $count 笔（略过 $skipped 笔空白列）';
  }

  @override
  String importFailedWithReason(String reason) {
    return '导入失败：$reason';
  }

  @override
  String get importFailedGeneric => '导入失败，请确认文件格式是否正确';

  @override
  String get importErrorEncoding =>
      '文件编码不是 UTF-8，无法读取。请用 Excel“另存新档”时选择“CSV UTF-8（逗号分隔）”格式，或用纯文本编辑器另存成 UTF-8 编码。';

  @override
  String get importErrorParse => 'CSV 格式解析失败，请确认是否为标准逗号分隔格式。';

  @override
  String get importErrorEmpty => '文件是空的，请确认内容格式正确。';

  @override
  String get importErrorNoRows => '没有解析到任何有效的数据列，请确认格式是否正确。';

  @override
  String get importDeleteTitle => '删除自定义教材';

  @override
  String importDeleteConfirm(String name) {
    return '确定要删除“$name”吗？这个动作无法复原。';
  }

  @override
  String get importedListHeader => '已导入的自定义教材';

  @override
  String importItemCount(int n) {
    return '$n 个项目';
  }

  @override
  String get aboutFeedbackButton => '意见回馈 / 回报问题';

  @override
  String get aboutAttributionIntro => '本 App 之单词/语块数据取自以下公开学术研究成果，特此致谢并标明出处：';

  @override
  String get aboutNgslTitle => 'NGSL 2809（内核单词）';

  @override
  String get aboutSpokenTitle => 'NGSL-Spoken 720（口语常用字）';

  @override
  String get aboutPhaveTitle => 'PhaVE List（词组动词）';

  @override
  String get aboutPhraseTitle => 'PHRASE List（高频语块）';

  @override
  String get aboutLicenseCcBySa =>
      '采用创用CC“姓名标示-相同方式分享 4.0 国际授权条款”（CC BY-SA 4.0）。';

  @override
  String get aboutLicenseCcBy => '采用创用CC“姓名标示 4.0 国际授权条款”（CC BY 4.0）。';

  @override
  String get aboutPhraseRights => '版权归原作者所有，本 App 依授权范围使用于教学用途。';

  @override
  String aboutSourceLabel(String name) {
    return '原作品：$name';
  }

  @override
  String aboutLicenseLabel(String name) {
    return '授权条款：$name';
  }

  @override
  String get aboutTtsNote => '朗读语音由设备系统内置文本转语音引擎提供。';

  @override
  String get feedbackTitle => '意见回馈';

  @override
  String get feedbackCategoryLabel => '类型';

  @override
  String get feedbackCategoryBug => '回报问题';

  @override
  String get feedbackCategorySuggestion => '功能建议';

  @override
  String get feedbackCategoryOther => '其他';

  @override
  String get feedbackMessageLabel => '内容';

  @override
  String get feedbackMessageHint => '告诉我们你遇到的问题，或希望增加什么功能…';

  @override
  String get feedbackEmailLabel => '联系信箱（选填）';

  @override
  String get feedbackEmailHint => '想收到回复的话可以留信箱';

  @override
  String get feedbackSubmit => '送出回馈';

  @override
  String get feedbackEmpty => '请先填写内容再送出';

  @override
  String get feedbackThanks => '感谢你的回馈，我们会尽快查看！';

  @override
  String get feedbackFailed => '送出失败，请确认网络连接后再试一次';

  @override
  String get statsDescNgsl =>
      '英语内核单词表，取自公开频率研究，完整学会这 2,809 个字，可达到一般日常英文文本约 92% 的理解涵盖率（数据源：New General Service List Project）。';

  @override
  String get statsDescSpoken =>
      '从日常口语对话中挑出的 720 个高频词汇，专门加强“听”与“说”情境的反应速度，跟 NGSL 内核单词表互补，涵盖口语里常用、但书面文本里较少出现的用词。';

  @override
  String get statsDescPhrase =>
      '506 个英语母语人士真正常用的固定搭配与语块（例如 \"in order to\"、\"as well as\"），不是单词而是“一整组一起记”的词组，能帮助说出更自然道地的英文。';

  @override
  String get statsDescPhave =>
      '收录 150 个最常用的词组动词（例如 \"look after\"、\"give up\"），这类“动词+介词”组合是英语学习者公认最难掌握的一块，集中复习这 150 个能涵盖大部分日常会遇到的词组动词。';

  @override
  String get summaryReadBilingual => '英双读';

  @override
  String get summaryReadEnglishOnly => '纯英文';

  @override
  String settingsSummaryLine(String mode, int count, String rate) {
    return '$mode・读$count次・${rate}x';
  }

  @override
  String get notifChannelName => '复习提醒';

  @override
  String get notifChannelDesc => '每日英文复习提醒通知';

  @override
  String get notifDailyTitle => '该复习英文啰！';

  @override
  String get notifDailyBody => '回来听几个单词，巩固今天学到的内容吧';

  @override
  String get notifInactivityTitle => '好久不见 👋';

  @override
  String get notifInactivityBody => '已经好几天没复习了，回来听几个单词，别让记忆生疏了';

  @override
  String get audioChannelName => '英语学习朗读';

  @override
  String get importLangId => '印尼文';

  @override
  String get datasetNameNgsl => 'NGSL 2809 内核单词';

  @override
  String get datasetShortNgsl => 'NGSL 2809字';

  @override
  String get datasetNameSpoken => 'NGSL 口语 720 字';

  @override
  String get datasetShortSpoken => '口语 720字';

  @override
  String get datasetNamePhrase => 'PHRASE List 高频语块 (506)';

  @override
  String get datasetShortPhrase => '高频语块 506';

  @override
  String get datasetNamePhave => 'PhaVE List 词组动词 (150)';

  @override
  String get datasetShortPhave => '词组动词 150';

  @override
  String get updateDownloadedMessage => '新版本已下载完成';

  @override
  String get updateRestartButton => '重新启动';

  @override
  String get importLangEs => '西班牙文';

  @override
  String get importLangPt => '葡萄牙文';

  @override
  String get menuIntro => '功能介绍';

  @override
  String get introSkip => '跳过';

  @override
  String get introNext => '下一步';

  @override
  String get introStart => '开始学习';

  @override
  String get introTitle1 => '用 20/80 法则学英语';

  @override
  String get introBody1 =>
      '学会 NGSL 2,809 个核心单词，就能看懂日常英语约 92% 的内容。不背生僻词，时间都花在真正用得到的地方。';

  @override
  String get introTitle2 => '特别写给这样的你';

  @override
  String get introBody2 =>
      '学过很多次英语却总是半途而废、年纪渐长记性不如从前、生活中没有英语环境——这套方法就是为你设计的，帮你重新找回学英语的信心。';

  @override
  String get introTitle3 => '后台朗读，碎片时间变学习时间';

  @override
  String get introBody3 => '通勤、散步、做家务、运动时都能听。锁屏或切换到其他 App，朗读都会继续，不用一直盯着屏幕。';

  @override
  String get introTitle4 => '双语朗读＋不熟悉单词库';

  @override
  String get introBody4 =>
      '先读英文、再读中文意思，不看屏幕也听得懂。不熟的词点星号标记，用“仅不熟悉”模式集中反复听，直到真正记住。';

  @override
  String get introTitle5 => '导入自己的教材，14 种语言都能听';

  @override
  String get introBody5 =>
      '课本单词、工作常用语、考试范围，存成 CSV 文件就能导入，同样后台朗读、标记不熟悉。不只英语——日语、韩语、法语、德语、西班牙语、泰语、阿拉伯语等 14 种语言都能朗读，翻译也能选你熟悉的语言。（部分语言需先在手机下载语音）';

  @override
  String get introTitle6 => '四大学术教材，免费开始';

  @override
  String get introBody6 =>
      '核心单词 NGSL 2809、口语常用词 720、高频语块 506、短语动词 150，均来自公开学术研究。每份教材都有免费内容，可以先体验再决定。';

  @override
  String get importWordLangLabel => '第一栏是什么语言？（决定朗读语音）';

  @override
  String importVoiceMissing(String language) {
    return '手机目前没有「$language」的朗读语音，会念不出来。请到手机“设置 → 文字转语音”安装该语言的语音包。';
  }

  @override
  String get menuShare => '分享给朋友';

  @override
  String get shareMessage =>
      '推荐你一个学英语的 App「智慧听觉巡航」：用 20/80 法则，只学覆盖 92% 日常英语的核心单词，通勤、走路、做家务时后台朗读，双语一起听。免费下载：';

  @override
  String get menuAdPrivacy => '广告隐私设置';

  @override
  String get switchDatasetButton => '切换教材';

  @override
  String get unlockMoreButton => '解锁更多';

  @override
  String get playShortStart => '开始朗读';

  @override
  String get playShortPause => '暂停';

  @override
  String cycleShort(int n) {
    return '第 $n 轮';
  }

  @override
  String get wordSizeLabel => '单词大小';

  @override
  String get wordSizeSmall => '小';

  @override
  String get wordSizeMedium => '中';

  @override
  String get wordSizeLarge => '大';

  @override
  String get lockScreenCoverLabel => '锁屏显示大字封面';

  @override
  String get lockScreenCoverDesc => '关闭后，锁屏只显示一般的小字卡片';

  @override
  String get appearanceLabel => '外观';

  @override
  String get appearanceSystem => '跟随系统';

  @override
  String get appearanceLight => '浅色';

  @override
  String get appearanceDark => '深色';

  @override
  String notifLastHeard(String word) {
    return '上次听到：$word';
  }

  @override
  String notifStarredLeft(int count) {
    return '还有 $count 个不熟悉单词';
  }

  @override
  String get notifActionStart => '▶ 开始朗读';

  @override
  String get notifActionSnooze => '稍后提醒';
}
