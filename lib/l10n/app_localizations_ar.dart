// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'تعلم الإنجليزية بالاستماع';

  @override
  String get statsTooltip => 'إحصاءات التعلّم';

  @override
  String get moreTooltip => 'المزيد';

  @override
  String get menuPremium => 'الترقية إلى بريميوم';

  @override
  String get menuVoicePreview => 'معاينة الأصوات';

  @override
  String get menuImport => 'استيراد قائمتك الخاصة';

  @override
  String get menuAbout => 'حول التطبيق / المصادر';

  @override
  String wordNumberLabel(int current, int total) {
    return 'رقم $current / $total';
  }

  @override
  String cycleLabel(int n) {
    return 'الجولة $n';
  }

  @override
  String roundProgressLabel(int heard, int total, int percent) {
    return 'المسموع في هذه الجولة: $heard / $total ($percent%)';
  }

  @override
  String get playButtonStart => 'ابدأ الاستماع';

  @override
  String get playButtonPause => 'إيقاف مؤقت';

  @override
  String get starButton => 'إضافة إلى الكلمات غير المألوفة';

  @override
  String get navPrevious => 'السابق';

  @override
  String get navReplay => 'إعادة';

  @override
  String get navNext => 'التالي';

  @override
  String get statsTitle => 'إحصاءات التعلّم';

  @override
  String get todayLearnedLabel => 'تعلّمت اليوم';

  @override
  String get totalLearnedLabel => 'الإجمالي';

  @override
  String get unitCount => 'كلمة';

  @override
  String get datasetProgressHeader => 'التقدّم في كل قائمة';

  @override
  String itemsCountLabel(int learned, int total) {
    return '$learned / $total عنصر';
  }

  @override
  String get dailyReminderHeader => 'تذكير المراجعة اليومي';

  @override
  String get enableDailyReminder => 'تفعيل التذكير اليومي';

  @override
  String get reminderTimeLabel => 'وقت التذكير';

  @override
  String reminderScheduledMessage(String time) {
    return 'تم ضبط التذكير على $time';
  }

  @override
  String get reminderFailedMessage =>
      'تعذّر جدولة التذكير. تحقّق من إعدادات توفير البطارية أو أعد تفعيل التذكير.';

  @override
  String get batteryOptButtonLabel =>
      'التذكير لا يصل في وقته؟ اضغط لإزالة قيود البطارية';

  @override
  String get batteryOptSnackbar =>
      'يُرجى ضبط خيار توفير البطارية على \"بلا قيود\"';

  @override
  String get miuiAutostartButtonLabel =>
      'هواتف Xiaomi/Redmi: فعّل أيضًا \"التشغيل التلقائي\"';

  @override
  String get miuiAutostartSnackbar =>
      'في هواتف Xiaomi ابحث عن هذا التطبيق في القائمة وفعّل التشغيل التلقائي (يمكن تجاهل هذا الزر في العلامات الأخرى)';

  @override
  String get settingsTitle => 'إعدادات التشغيل';

  @override
  String starredCountLabel(int n) {
    return '$n عنصر محدّد';
  }

  @override
  String get speakOnManualNavigateLabel =>
      'النطق عند التنقل اليدوي بين الكلمات';

  @override
  String get showTranslationLabel => 'إظهار الترجمة';

  @override
  String intervalSecondsLabel(String seconds) {
    return 'الفاصل بين الكلمات: $seconds ث';
  }

  @override
  String speechRateLabel(String rate) {
    return 'سرعة النطق: ${rate}x';
  }

  @override
  String get scopeModeLabel => 'نطاق / وضع التشغيل';

  @override
  String get scopeAllRandom => 'القائمة كاملة (عشوائي)';

  @override
  String get scopeAllSequential => 'القائمة كاملة (بالترتيب)';

  @override
  String get scopeStarredRandom => 'غير المألوفة فقط (عشوائي)';

  @override
  String get scopeStarredSequential => 'غير المألوفة فقط (بالترتيب)';

  @override
  String get readModeLabel => 'ما الذي يُقرأ بصوت عالٍ';

  @override
  String get readModeBilingual => 'ثنائي اللغة (الكلمة + الترجمة)';

  @override
  String get readModeEnglishOnly => 'الكلمة فقط';

  @override
  String get repeatCountLabel => 'عدد مرات تكرار كل كلمة';

  @override
  String get repeatOnce => 'مرة واحدة';

  @override
  String get repeatTwice => 'مرتان (موصى به)';

  @override
  String get repeatThrice => '3 مرات';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonDelete => 'حذف';

  @override
  String get voicePreviewIntro =>
      'هذه هي الأصوات الإنجليزية المتوفرة على هاتفك. اضغط على أيقونة التشغيل للاستماع. أثناء التشغيل يستخدم التطبيق الصوت الافتراضي للنظام لكل لغة؛ هذه الصفحة فقط لتسمع ما هو مثبّت.';

  @override
  String get voicePreviewNoVoices =>
      'لم يتم العثور على أصوات. تأكّد من تثبيت حزمة صوت إنجليزية.';

  @override
  String get voicePreviewUnknownVoice => 'صوت غير معروف';

  @override
  String get paywallPurchaseSuccess =>
      'تم الاشتراك! تم فتح كل المحتوى وإزالة الإعلانات.';

  @override
  String get paywallPurchaseFailed =>
      'لم تكتمل عملية الشراء. يُرجى المحاولة لاحقًا.';

  @override
  String get paywallRestoreSuccess => 'تمت استعادة اشتراك بريميوم!';

  @override
  String get paywallRestoreNotFound => 'لا توجد مشتريات لاستعادتها.';

  @override
  String get paywallAlreadyPremium => 'أنت مشترك في بريميوم بالفعل 🎉';

  @override
  String get paywallHeadline => 'افتح كل محتوى التعلّم';

  @override
  String get paywallBenefitAllContent => 'القوائم الأربع مفتوحة 100%';

  @override
  String get paywallBenefitNoAds => 'بلا أي إعلانات';

  @override
  String get paywallBenefitBackground =>
      'التشغيل في الخلفية والعرض على شاشة القفل';

  @override
  String get paywallRestoreButton => 'استعادة المشتريات';

  @override
  String get paywallNoPackages =>
      'لا تتوفر خطط اشتراك حاليًا. يُرجى المحاولة لاحقًا.';

  @override
  String get paywallPlanMonthly => 'الخطة الشهرية';

  @override
  String get paywallPlanAnnual => 'الخطة السنوية';

  @override
  String get paywallTermsNote =>
      'يتجدد الاشتراك تلقائيًا. يمكنك الإلغاء في أي وقت من Google Play ضمن \"الدفعات والاشتراكات\". بعد الإلغاء يظل بريميوم فعّالًا حتى نهاية الفترة الحالية، ثم يعود التطبيق إلى النسخة المجانية.';

  @override
  String get paywallManageSubscription => 'إدارة / إلغاء الاشتراك';

  @override
  String get unlockRewardSnackbar => 'تم فتح 20 عنصرًا إضافيًا!';

  @override
  String unlockFreeProgress(int unlocked, int total) {
    return 'النسخة المجانية: $unlocked / $total عنصر مفتوح';
  }

  @override
  String get unlockAdLoading => 'جارٍ تحميل الإعلان…';

  @override
  String get unlockWatchAd => 'شاهد إعلانًا +20';

  @override
  String get importIntro =>
      'استورد كلماتك أو عباراتك أو جملك الخاصة (مثلًا من كتابك المدرسي). بعد الاستيراد تعمل تمامًا مثل القوائم المدمجة.';

  @override
  String get importFormatTitle => 'صيغة الاستيراد (CSV مع صف عناوين)';

  @override
  String get importSampleApple => 'تفاحة (فاكهة)';

  @override
  String get importSampleGiveUp => 'يستسلم';

  @override
  String get importSampleHowAreYou => 'تحية ودية';

  @override
  String get importFormatHint =>
      'ضع النص المراد تعلّمه في العمود الأول (كلمات أو عبارات أو جمل كاملة) وترجمته في العمود الثاني، ثم احفظه كملف CSV. تعمل لغات أخرى أيضًا: فقط اختر لغة العمود الأول أدناه.';

  @override
  String get importGetTemplate => 'الحصول على ملف نموذجي';

  @override
  String importTemplateSaved(String path) {
    return 'تم حفظ الملف النموذجي في المجلد المؤقت: $path';
  }

  @override
  String get importNameLabel => 'اسم هذه القائمة';

  @override
  String get importNameHint => 'مثال: جمل TOEIC الأساسية';

  @override
  String get importNameRequired => 'يُرجى تسمية هذه القائمة أولًا';

  @override
  String get importTranslationLangLabel => 'ما لغة عمود الترجمة؟';

  @override
  String get importLangZh => 'الصينية';

  @override
  String get importLangJa => 'اليابانية';

  @override
  String get importLangKo => 'الكورية';

  @override
  String get importLangVi => 'الفيتنامية';

  @override
  String get importLangEn => 'الإنجليزية';

  @override
  String get importButton => 'اختر ملف CSV واستورده';

  @override
  String get importingInProgress => 'جارٍ الاستيراد…';

  @override
  String importDone(int count) {
    return 'تم استيراد $count عنصر!';
  }

  @override
  String importDoneWithSkipped(int count, int skipped) {
    return 'تم استيراد $count عنصر! (تم تخطي $skipped صف فارغ)';
  }

  @override
  String importFailedWithReason(String reason) {
    return 'فشل الاستيراد: $reason';
  }

  @override
  String get importFailedGeneric =>
      'فشل الاستيراد. يُرجى التحقق من صيغة الملف.';

  @override
  String get importErrorEncoding =>
      'الملف ليس بترميز UTF-8 ولا يمكن قراءته. في Excel استخدم \"حفظ باسم\" واختر \"CSV UTF-8 (محدد بفواصل)\"، أو احفظه بترميز UTF-8 في محرر نصوص.';

  @override
  String get importErrorParse =>
      'تعذّر تحليل ملف CSV. تأكّد من أنه ملف قياسي مفصول بفواصل.';

  @override
  String get importErrorEmpty => 'الملف فارغ. يُرجى التحقق من محتواه.';

  @override
  String get importErrorNoRows =>
      'لم يتم العثور على صفوف صالحة. يُرجى التحقق من الصيغة.';

  @override
  String get importDeleteTitle => 'حذف القائمة المستوردة';

  @override
  String importDeleteConfirm(String name) {
    return 'حذف \"$name\"؟ لا يمكن التراجع عن ذلك.';
  }

  @override
  String get importedListHeader => 'القوائم المستوردة';

  @override
  String importItemCount(int n) {
    return '$n عنصر';
  }

  @override
  String get aboutFeedbackButton => 'ملاحظات / الإبلاغ عن مشكلة';

  @override
  String get aboutAttributionIntro =>
      'بيانات الكلمات والعبارات في هذا التطبيق مأخوذة من الأبحاث الأكاديمية المنشورة التالية، مع الشكر والإسناد:';

  @override
  String get aboutNgslTitle => 'NGSL 2809 (المفردات الأساسية)';

  @override
  String get aboutSpokenTitle => 'NGSL-Spoken 720 (مفردات المحادثة)';

  @override
  String get aboutPhaveTitle => 'PhaVE List (الأفعال المركبة)';

  @override
  String get aboutPhraseTitle => 'PHRASE List (العبارات الشائعة)';

  @override
  String get aboutLicenseCcBySa =>
      'مرخّص بموجب Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0).';

  @override
  String get aboutLicenseCcBy =>
      'مرخّص بموجب Creative Commons Attribution 4.0 International (CC BY 4.0).';

  @override
  String get aboutPhraseRights =>
      'حقوق النشر للمؤلفين الأصليين؛ يُستخدم في هذا التطبيق لأغراض تعليمية ضمن حدود الترخيص.';

  @override
  String aboutSourceLabel(String name) {
    return 'العمل الأصلي: $name';
  }

  @override
  String aboutLicenseLabel(String name) {
    return 'الترخيص: $name';
  }

  @override
  String get aboutTtsNote =>
      'النطق مقدَّم من محرك تحويل النص إلى كلام المدمج في جهازك.';

  @override
  String get feedbackTitle => 'الملاحظات';

  @override
  String get feedbackCategoryLabel => 'النوع';

  @override
  String get feedbackCategoryBug => 'الإبلاغ عن مشكلة';

  @override
  String get feedbackCategorySuggestion => 'اقتراح ميزة';

  @override
  String get feedbackCategoryOther => 'أخرى';

  @override
  String get feedbackMessageLabel => 'الرسالة';

  @override
  String get feedbackMessageHint => 'أخبرنا عن مشكلة واجهتك أو ميزة تريدها…';

  @override
  String get feedbackEmailLabel => 'البريد الإلكتروني للتواصل (اختياري)';

  @override
  String get feedbackEmailHint => 'اترك بريدك إذا أردت ردًّا';

  @override
  String get feedbackSubmit => 'إرسال الملاحظات';

  @override
  String get feedbackEmpty => 'يُرجى كتابة شيء قبل الإرسال';

  @override
  String get feedbackThanks => 'شكرًا على ملاحظاتك! سنطّلع عليها قريبًا.';

  @override
  String get feedbackFailed => 'تعذّر الإرسال. تحقّق من الاتصال وحاول مجددًا.';

  @override
  String get statsDescNgsl =>
      'قائمة كلمات إنجليزية أساسية مبنية على أبحاث تكرار منشورة. تعلّم الكلمات الـ 2,809 كلها يغطي نحو 92% من النصوص الإنجليزية اليومية (المصدر: New General Service List Project).';

  @override
  String get statsDescSpoken =>
      '720 كلمة شائعة مختارة من المحادثات اليومية لتسريع الاستماع والتحدث. تُكمل قائمة NGSL الأساسية بكلمات شائعة في الكلام وأقل شيوعًا في الكتابة.';

  @override
  String get statsDescPhrase =>
      '506 تعبيرات ثابتة يستخدمها الناطقون بالإنجليزية فعلًا (مثل \"in order to\" و\"as well as\"). تعلّمها كوحدات كاملة يجعل كلامك أكثر طبيعية.';

  @override
  String get statsDescPhave =>
      'أكثر 150 فعلًا مركبًا شيوعًا (مثل \"look after\" و\"give up\"). تراكيب الفعل + الأداة هذه صعبة على المتعلمين، وهذه الـ 150 تغطي معظم ما ستصادفه يوميًا.';

  @override
  String get summaryReadBilingual => 'ثنائي اللغة';

  @override
  String get summaryReadEnglishOnly => 'الكلمة فقط';

  @override
  String settingsSummaryLine(String mode, int count, String rate) {
    return '$mode · ×$count · ${rate}x';
  }

  @override
  String get notifChannelName => 'تذكيرات المراجعة';

  @override
  String get notifChannelDesc => 'تذكيرات يومية لمراجعة الإنجليزية';

  @override
  String get notifDailyTitle => 'حان وقت مراجعة الإنجليزية!';

  @override
  String get notifDailyBody =>
      'عُد واستمع إلى بضع كلمات لتثبيت ما تعلّمته اليوم';

  @override
  String get notifInactivityTitle => 'اشتقنا إليك 👋';

  @override
  String get notifInactivityBody =>
      'مرّت أيام منذ آخر مراجعة. استمع إلى بضع كلمات قبل أن تنساها';

  @override
  String get audioChannelName => 'تشغيل الصوت الإنجليزي';

  @override
  String get importLangId => 'الإندونيسية';

  @override
  String get datasetNameNgsl => 'NGSL 2809 الكلمات الأساسية';

  @override
  String get datasetShortNgsl => 'NGSL 2809';

  @override
  String get datasetNameSpoken => 'NGSL Spoken 720 المحادثة';

  @override
  String get datasetShortSpoken => 'المحادثة 720';

  @override
  String get datasetNamePhrase => 'PHRASE List العبارات (506)';

  @override
  String get datasetShortPhrase => 'العبارات 506';

  @override
  String get datasetNamePhave => 'PhaVE List الأفعال المركبة (150)';

  @override
  String get datasetShortPhave => 'الأفعال المركبة 150';

  @override
  String get updateDownloadedMessage => 'تم تنزيل إصدار جديد';

  @override
  String get updateRestartButton => 'إعادة التشغيل';

  @override
  String get importLangEs => 'الإسبانية';

  @override
  String get importLangPt => 'البرتغالية';

  @override
  String get menuIntro => 'جولة في الميزات';

  @override
  String get introSkip => 'تخطٍّ';

  @override
  String get introNext => 'التالي';

  @override
  String get introStart => 'ابدأ التعلّم';

  @override
  String get introTitle1 => 'تعلّم الإنجليزية بقاعدة 80/20';

  @override
  String get introBody1 =>
      'أتقن الكلمات الأساسية الـ 2,809 في NGSL وستفهم نحو 92% من الإنجليزية اليومية. لا مفردات نادرة: وقتك يذهب إلى كلمات ستستخدمها فعلًا.';

  @override
  String get introTitle2 => 'مصمَّم لأشخاص مثلك';

  @override
  String get introBody2 =>
      'درست الإنجليزية مرات عديدة ولم تثبت؟ الذاكرة لم تعد كما كانت؟ لا توجد إنجليزية حولك يوميًا؟ هذه الطريقة مصممة لك لتستعيد ثقتك.';

  @override
  String get introTitle3 =>
      'التشغيل في الخلفية يحوّل أوقات الفراغ إلى وقت تعلّم';

  @override
  String get introBody3 =>
      'استمع أثناء التنقل أو المشي أو الأعمال المنزلية أو الرياضة. اقفل الشاشة أو انتقل إلى تطبيق آخر ويستمر التشغيل، فلا حاجة إلى التحديق في هاتفك.';

  @override
  String get introTitle4 => 'صوت ثنائي اللغة + قائمة الكلمات غير المألوفة';

  @override
  String get introBody4 =>
      'اسمع الكلمة الإنجليزية ثم معناها دون النظر إلى الشاشة. ضع نجمة على الكلمات التي لا تعرفها وأعد تشغيلها في وضع \"غير المألوفة فقط\" حتى تحفظها.';

  @override
  String get introTitle5 => 'استورد موادك: 14 لغة';

  @override
  String get introBody5 =>
      'مفردات الكتاب المدرسي أو عبارات العمل أو قوائم الامتحانات: استوردها كملف CSV واستمع إليها في الخلفية وضع علامة على الصعبة منها. ليست الإنجليزية فقط: الفرنسية والألمانية والإسبانية والصينية واليابانية والكورية والتايلاندية وغيرها، 14 لغة في المجموع، مع الترجمة باللغة التي تفضّلها. (بعض اللغات تتطلب تنزيل الصوت على الهاتف أولًا)';

  @override
  String get introTitle6 => 'أربع قوائم أكاديمية، ابدأ مجانًا';

  @override
  String get introBody6 =>
      'NGSL 2809 الكلمات الأساسية و Spoken 720 و PHRASE List 506 و PhaVE List 150، كلها من أبحاث أكاديمية منشورة. كل قائمة فيها محتوى مجاني لتجرّب قبل أن تقرر.';

  @override
  String get importWordLangLabel => 'ما لغة العمود الأول؟ (تحدد صوت القراءة)';

  @override
  String importVoiceMissing(String language) {
    return 'لا يوجد في هاتفك صوت لتحويل النص إلى كلام بلغة \"$language\"، لذا لا يمكن قراءتها. ثبّت صوتًا من الإعدادات ← تحويل النص إلى كلام.';
  }

  @override
  String get menuShare => 'شارك مع الأصدقاء';

  @override
  String get shareMessage =>
      'أنصحك بتطبيق \"تعلم الإنجليزية بالاستماع\": تعلّم بقاعدة 80/20 الكلمات الأساسية التي تغطي 92% من الإنجليزية اليومية، مع قراءتها في الخلفية أثناء التنقل أو المشي أو الأعمال المنزلية، بلغتين معًا. تنزيل مجاني:';

  @override
  String get menuAdPrivacy => 'إعدادات خصوصية الإعلانات';

  @override
  String get switchDatasetButton => 'تغيير المادة';

  @override
  String get unlockMoreButton => 'فتح المزيد';

  @override
  String get playShortStart => 'ابدأ';

  @override
  String get playShortPause => 'إيقاف مؤقت';

  @override
  String cycleShort(int n) {
    return 'الجولة $n';
  }

  @override
  String get wordSizeLabel => 'حجم الكلمة';

  @override
  String get wordSizeSmall => 'صغير';

  @override
  String get wordSizeMedium => 'متوسط';

  @override
  String get wordSizeLarge => 'كبير';

  @override
  String get lockScreenCoverLabel => 'غلاف بخط كبير على شاشة القفل';

  @override
  String get lockScreenCoverDesc =>
      'عند الإيقاف تعرض شاشة القفل البطاقة العادية بخط صغير فقط';

  @override
  String get appearanceLabel => 'المظهر';

  @override
  String get appearanceSystem => 'حسب النظام';

  @override
  String get appearanceLight => 'فاتح';

  @override
  String get appearanceDark => 'داكن';

  @override
  String notifLastHeard(String word) {
    return 'آخر كلمة: $word';
  }

  @override
  String notifStarredLeft(int count) {
    return 'تبقّى $count كلمة غير مألوفة';
  }

  @override
  String get notifActionStart => '▶ ابدأ الاستماع';

  @override
  String get notifActionSnooze => 'ذكّرني لاحقًا';
}
