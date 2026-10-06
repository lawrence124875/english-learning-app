// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appTitle => 'คำศัพท์ภาษาอังกฤษ ฝึกฟัง';

  @override
  String get statsTooltip => 'สถิติการเรียน';

  @override
  String get moreTooltip => 'เพิ่มเติม';

  @override
  String get menuPremium => 'อัปเกรดเป็นพรีเมียม';

  @override
  String get menuVoicePreview => 'ฟังตัวอย่างเสียง';

  @override
  String get menuImport => 'นำเข้าบทเรียนของคุณเอง';

  @override
  String get menuAbout => 'เกี่ยวกับ / แหล่งที่มา';

  @override
  String wordNumberLabel(int current, int total) {
    return 'ลำดับที่ $current / $total';
  }

  @override
  String cycleLabel(int n) {
    return 'รอบที่ $n';
  }

  @override
  String roundProgressLabel(int heard, int total, int percent) {
    return 'ฟังแล้วในรอบนี้: $heard / $total ($percent%)';
  }

  @override
  String get playButtonStart => 'เริ่มฟัง';

  @override
  String get playButtonPause => 'หยุดชั่วคราว';

  @override
  String get starButton => 'เพิ่มในคำที่ยังไม่คุ้น';

  @override
  String get navPrevious => 'ก่อนหน้า';

  @override
  String get navReplay => 'เล่นซ้ำ';

  @override
  String get navNext => 'ถัดไป';

  @override
  String get statsTitle => 'สถิติการเรียน';

  @override
  String get todayLearnedLabel => 'เรียนวันนี้';

  @override
  String get totalLearnedLabel => 'เรียนทั้งหมด';

  @override
  String get unitCount => 'คำ';

  @override
  String get datasetProgressHeader => 'ความคืบหน้าแต่ละบทเรียน';

  @override
  String itemsCountLabel(int learned, int total) {
    return '$learned / $total รายการ';
  }

  @override
  String get dailyReminderHeader => 'แจ้งเตือนทบทวนประจำวัน';

  @override
  String get enableDailyReminder => 'เปิดการแจ้งเตือนประจำวัน';

  @override
  String get reminderTimeLabel => 'เวลาแจ้งเตือน';

  @override
  String reminderScheduledMessage(String time) {
    return 'ตั้งการแจ้งเตือนเวลา $time แล้ว';
  }

  @override
  String get reminderFailedMessage =>
      'ตั้งการแจ้งเตือนไม่สำเร็จ โปรดตรวจสอบการประหยัดแบตเตอรี่ หรือปิดแล้วเปิดการแจ้งเตือนอีกครั้ง';

  @override
  String get batteryOptButtonLabel =>
      'แจ้งเตือนไม่ตรงเวลา? แตะเพื่อยกเลิกข้อจำกัดแบตเตอรี่';

  @override
  String get batteryOptSnackbar =>
      'โปรดตั้งค่าตัวประหยัดแบตเตอรี่เป็น \"ไม่จำกัด\"';

  @override
  String get miuiAutostartButtonLabel =>
      'โทรศัพท์ Xiaomi/Redmi: โปรดเปิด \"เริ่มอัตโนมัติ\" ด้วย';

  @override
  String get miuiAutostartSnackbar =>
      'สำหรับ Xiaomi ให้หาแอปนี้ในรายการแล้วเปิดเริ่มอัตโนมัติ (ยี่ห้ออื่นไม่ต้องสนใจปุ่มนี้)';

  @override
  String get settingsTitle => 'การตั้งค่าการเล่น';

  @override
  String starredCountLabel(int n) {
    return 'ทำเครื่องหมายแล้ว $n รายการ';
  }

  @override
  String get speakOnManualNavigateLabel => 'อ่านออกเสียงเมื่อเปลี่ยนคำเอง';

  @override
  String get showTranslationLabel => 'แสดงคำแปล';

  @override
  String intervalSecondsLabel(String seconds) {
    return 'เว้นระหว่างคำ: $seconds วินาที';
  }

  @override
  String speechRateLabel(String rate) {
    return 'ความเร็วเสียง: ${rate}x';
  }

  @override
  String get scopeModeLabel => 'ขอบเขต / รูปแบบการเล่น';

  @override
  String get scopeAllRandom => 'ทั้งหมด (สุ่ม)';

  @override
  String get scopeAllSequential => 'ทั้งหมด (ตามลำดับ)';

  @override
  String get scopeStarredRandom => 'เฉพาะคำที่ยังไม่คุ้น (สุ่ม)';

  @override
  String get scopeStarredSequential => 'เฉพาะคำที่ยังไม่คุ้น (ตามลำดับ)';

  @override
  String get readModeLabel => 'อ่านออกเสียงอะไร';

  @override
  String get readModeBilingual => 'สองภาษา (คำ + คำแปล)';

  @override
  String get readModeEnglishOnly => 'เฉพาะคำ';

  @override
  String get repeatCountLabel => 'จำนวนครั้งที่อ่านซ้ำต่อคำ';

  @override
  String get repeatOnce => '1 ครั้ง';

  @override
  String get repeatTwice => '2 ครั้ง (แนะนำ)';

  @override
  String get repeatThrice => '3 ครั้ง';

  @override
  String get commonCancel => 'ยกเลิก';

  @override
  String get commonDelete => 'ลบ';

  @override
  String get voicePreviewIntro =>
      'นี่คือเสียงภาษาอังกฤษที่มีในโทรศัพท์ของคุณ แตะไอคอนเล่นเพื่อฟัง ขณะเล่น แอปจะใช้เสียงเริ่มต้นของระบบในแต่ละภาษา หน้านี้มีไว้ให้ฟังว่าติดตั้งเสียงใดไว้บ้าง';

  @override
  String get voicePreviewNoVoices =>
      'ไม่พบเสียง โปรดตรวจสอบว่าได้ติดตั้งชุดเสียงภาษาอังกฤษแล้ว';

  @override
  String get voicePreviewUnknownVoice => 'เสียงที่ไม่ทราบชื่อ';

  @override
  String get paywallPurchaseSuccess =>
      'สมัครสำเร็จ! ปลดล็อกเนื้อหาทั้งหมดและนำโฆษณาออกแล้ว';

  @override
  String get paywallPurchaseFailed => 'การซื้อไม่สำเร็จ โปรดลองอีกครั้งภายหลัง';

  @override
  String get paywallRestoreSuccess => 'กู้คืนการสมัครพรีเมียมแล้ว!';

  @override
  String get paywallRestoreNotFound => 'ไม่พบรายการซื้อที่กู้คืนได้';

  @override
  String get paywallAlreadyPremium => 'คุณเป็นสมาชิกพรีเมียมอยู่แล้ว 🎉';

  @override
  String get paywallHeadline => 'ปลดล็อกเนื้อหาการเรียนทั้งหมด';

  @override
  String get paywallBenefitAllContent => 'บทเรียนทั้ง 4 ชุด ปลดล็อก 100%';

  @override
  String get paywallBenefitNoAds => 'ไม่มีโฆษณาเลย';

  @override
  String get paywallBenefitBackground => 'เล่นเบื้องหลังและแสดงบนหน้าจอล็อก';

  @override
  String get paywallRestoreButton => 'กู้คืนการซื้อ';

  @override
  String get paywallNoPackages =>
      'ขณะนี้ยังไม่มีแผนสมาชิก โปรดลองอีกครั้งภายหลัง';

  @override
  String get paywallPlanMonthly => 'แผนรายเดือน';

  @override
  String get paywallPlanAnnual => 'แผนรายปี';

  @override
  String get paywallTermsNote =>
      'การสมัครจะต่ออายุอัตโนมัติ ยกเลิกได้ทุกเมื่อใน Google Play ที่ \"การชำระเงินและการสมัครใช้บริการ\" หลังยกเลิก พรีเมียมยังใช้ได้จนสิ้นสุดรอบปัจจุบัน แล้วจะกลับเป็นเวอร์ชันฟรี';

  @override
  String get paywallManageSubscription => 'จัดการ / ยกเลิกการสมัคร';

  @override
  String get unlockRewardSnackbar => 'ปลดล็อกเพิ่มอีก 20 รายการแล้ว!';

  @override
  String unlockFreeProgress(int unlocked, int total) {
    return 'เวอร์ชันฟรี: ปลดล็อกแล้ว $unlocked / $total รายการ';
  }

  @override
  String get unlockAdLoading => 'กำลังโหลดโฆษณา…';

  @override
  String get unlockWatchAd => 'ดูโฆษณา +20';

  @override
  String get importIntro =>
      'นำเข้าคำศัพท์ วลี หรือประโยคตัวอย่างของคุณเอง (เช่น จากหนังสือเรียน) เมื่อนำเข้าแล้วจะใช้งานได้เหมือนบทเรียนในตัวแอป';

  @override
  String get importFormatTitle => 'รูปแบบการนำเข้า (CSV มีแถวหัวตาราง)';

  @override
  String get importSampleApple => 'แอปเปิล (ผลไม้)';

  @override
  String get importSampleGiveUp => 'ยอมแพ้';

  @override
  String get importSampleHowAreYou => 'คำทักทายอย่างเป็นมิตร';

  @override
  String get importFormatHint =>
      'ใส่ข้อความที่จะเรียนในคอลัมน์แรก (คำ วลี หรือประโยค) และคำแปลในคอลัมน์ที่สอง แล้วบันทึกเป็นไฟล์ CSV ใช้ภาษาอื่นได้ด้วย เพียงเลือกภาษาของคอลัมน์แรกด้านล่าง';

  @override
  String get importGetTemplate => 'รับไฟล์ตัวอย่าง';

  @override
  String importTemplateSaved(String path) {
    return 'บันทึกไฟล์ตัวอย่างไว้ในโฟลเดอร์ชั่วคราว: $path';
  }

  @override
  String get importNameLabel => 'ชื่อบทเรียนนี้';

  @override
  String get importNameHint => 'เช่น ประโยคสำคัญ TOEIC';

  @override
  String get importNameRequired => 'โปรดตั้งชื่อบทเรียนนี้ก่อน';

  @override
  String get importTranslationLangLabel => 'คอลัมน์คำแปลเป็นภาษาอะไร?';

  @override
  String get importLangZh => 'จีน';

  @override
  String get importLangJa => 'ญี่ปุ่น';

  @override
  String get importLangKo => 'เกาหลี';

  @override
  String get importLangVi => 'เวียดนาม';

  @override
  String get importLangEn => 'อังกฤษ';

  @override
  String get importButton => 'เลือกไฟล์ CSV แล้วนำเข้า';

  @override
  String get importingInProgress => 'กำลังนำเข้า…';

  @override
  String importDone(int count) {
    return 'นำเข้า $count รายการแล้ว!';
  }

  @override
  String importDoneWithSkipped(int count, int skipped) {
    return 'นำเข้า $count รายการแล้ว! (ข้ามแถวว่าง $skipped แถว)';
  }

  @override
  String importFailedWithReason(String reason) {
    return 'นำเข้าไม่สำเร็จ: $reason';
  }

  @override
  String get importFailedGeneric => 'นำเข้าไม่สำเร็จ โปรดตรวจสอบรูปแบบไฟล์';

  @override
  String get importErrorEncoding =>
      'ไฟล์ไม่ได้เข้ารหัสแบบ UTF-8 จึงอ่านไม่ได้ ใน Excel ให้ใช้ \"บันทึกเป็น\" แล้วเลือก \"CSV UTF-8 (คั่นด้วยจุลภาค)\" หรือบันทึกเป็น UTF-8 ในโปรแกรมแก้ไขข้อความ';

  @override
  String get importErrorParse =>
      'อ่าน CSV ไม่ได้ โปรดตรวจสอบว่าเป็นไฟล์ที่คั่นด้วยจุลภาคแบบมาตรฐาน';

  @override
  String get importErrorEmpty => 'ไฟล์ว่างเปล่า โปรดตรวจสอบเนื้อหา';

  @override
  String get importErrorNoRows => 'ไม่พบแถวที่ใช้ได้ โปรดตรวจสอบรูปแบบ';

  @override
  String get importDeleteTitle => 'ลบบทเรียนที่นำเข้า';

  @override
  String importDeleteConfirm(String name) {
    return 'ลบ \"$name\" หรือไม่? ไม่สามารถกู้คืนได้';
  }

  @override
  String get importedListHeader => 'บทเรียนที่นำเข้า';

  @override
  String importItemCount(int n) {
    return '$n รายการ';
  }

  @override
  String get aboutFeedbackButton => 'ความคิดเห็น / แจ้งปัญหา';

  @override
  String get aboutAttributionIntro =>
      'ข้อมูลคำศัพท์และวลีในแอปนี้มาจากงานวิจัยทางวิชาการที่เผยแพร่ต่อไปนี้ ขอขอบคุณและอ้างอิงแหล่งที่มา:';

  @override
  String get aboutNgslTitle => 'NGSL 2809 (คำศัพท์หลัก)';

  @override
  String get aboutSpokenTitle => 'NGSL-Spoken 720 (คำศัพท์ภาษาพูด)';

  @override
  String get aboutPhaveTitle => 'PhaVE List (กริยาวลี)';

  @override
  String get aboutPhraseTitle => 'PHRASE List (วลีที่ใช้บ่อย)';

  @override
  String get aboutLicenseCcBySa =>
      'อนุญาตภายใต้ Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)';

  @override
  String get aboutLicenseCcBy =>
      'อนุญาตภายใต้ Creative Commons Attribution 4.0 International (CC BY 4.0)';

  @override
  String get aboutPhraseRights =>
      'ลิขสิทธิ์เป็นของผู้เขียนต้นฉบับ แอปนี้ใช้เพื่อการศึกษาภายในขอบเขตของสัญญาอนุญาต';

  @override
  String aboutSourceLabel(String name) {
    return 'ต้นฉบับ: $name';
  }

  @override
  String aboutLicenseLabel(String name) {
    return 'สัญญาอนุญาต: $name';
  }

  @override
  String get aboutTtsNote =>
      'เสียงอ่านมาจากระบบแปลงข้อความเป็นเสียงในตัวเครื่องของคุณ';

  @override
  String get feedbackTitle => 'ความคิดเห็น';

  @override
  String get feedbackCategoryLabel => 'ประเภท';

  @override
  String get feedbackCategoryBug => 'แจ้งปัญหา';

  @override
  String get feedbackCategorySuggestion => 'เสนอฟีเจอร์';

  @override
  String get feedbackCategoryOther => 'อื่น ๆ';

  @override
  String get feedbackMessageLabel => 'ข้อความ';

  @override
  String get feedbackMessageHint => 'เล่าปัญหาที่พบ หรือฟีเจอร์ที่อยากได้…';

  @override
  String get feedbackEmailLabel => 'อีเมลติดต่อ (ไม่บังคับ)';

  @override
  String get feedbackEmailHint => 'ใส่อีเมลหากต้องการให้ตอบกลับ';

  @override
  String get feedbackSubmit => 'ส่งความคิดเห็น';

  @override
  String get feedbackEmpty => 'โปรดเขียนข้อความก่อนส่ง';

  @override
  String get feedbackThanks => 'ขอบคุณสำหรับความคิดเห็น! เราจะรีบตรวจสอบ';

  @override
  String get feedbackFailed =>
      'ส่งไม่สำเร็จ โปรดตรวจสอบการเชื่อมต่อแล้วลองอีกครั้ง';

  @override
  String get statsDescNgsl =>
      'รายการคำศัพท์ภาษาอังกฤษหลักจากงานวิจัยความถี่ที่เผยแพร่แล้ว เรียนครบ 2,809 คำจะเข้าใจข้อความภาษาอังกฤษในชีวิตประจำวันได้ประมาณ 92% (ที่มา: New General Service List Project)';

  @override
  String get statsDescSpoken =>
      '720 คำที่ใช้บ่อยจากบทสนทนาในชีวิตประจำวัน ช่วยเร่งการฟังและพูด เสริมรายการหลัก NGSL ด้วยคำที่พบบ่อยในการพูดแต่พบน้อยในการเขียน';

  @override
  String get statsDescPhrase =>
      '506 สำนวนตายตัวที่เจ้าของภาษาใช้จริง (เช่น \"in order to\" และ \"as well as\") เรียนเป็นก้อนทั้งวลี ช่วยให้พูดได้เป็นธรรมชาติขึ้น';

  @override
  String get statsDescPhave =>
      '150 กริยาวลีที่ใช้บ่อยที่สุด (เช่น \"look after\" และ \"give up\") การผสมกริยา + คำเล็ก ๆ แบบนี้ขึ้นชื่อว่ายากสำหรับผู้เรียน 150 คำนี้ครอบคลุมส่วนใหญ่ที่คุณจะเจอในชีวิตประจำวัน';

  @override
  String get summaryReadBilingual => 'สองภาษา';

  @override
  String get summaryReadEnglishOnly => 'เฉพาะคำ';

  @override
  String settingsSummaryLine(String mode, int count, String rate) {
    return '$mode · ×$count · ${rate}x';
  }

  @override
  String get notifChannelName => 'แจ้งเตือนทบทวน';

  @override
  String get notifChannelDesc => 'แจ้งเตือนทบทวนภาษาอังกฤษประจำวัน';

  @override
  String get notifDailyTitle => 'ได้เวลาทบทวนภาษาอังกฤษแล้ว!';

  @override
  String get notifDailyBody =>
      'กลับมาฟังสักสองสามคำ เพื่อจำสิ่งที่เรียนวันนี้ให้แม่น';

  @override
  String get notifInactivityTitle => 'ไม่ได้เจอกันนานเลย 👋';

  @override
  String get notifInactivityBody =>
      'ผ่านไปหลายวันแล้วตั้งแต่ทบทวนครั้งล่าสุด ฟังสักสองสามคำก่อนจะลืมนะ';

  @override
  String get audioChannelName => 'การเล่นเสียงภาษาอังกฤษ';

  @override
  String get importLangId => 'อินโดนีเซีย';

  @override
  String get datasetNameNgsl => 'NGSL 2809 คำศัพท์หลัก';

  @override
  String get datasetShortNgsl => 'NGSL 2809';

  @override
  String get datasetNameSpoken => 'NGSL Spoken 720 ภาษาพูด';

  @override
  String get datasetShortSpoken => 'ภาษาพูด 720';

  @override
  String get datasetNamePhrase => 'PHRASE List วลี (506)';

  @override
  String get datasetShortPhrase => 'วลี 506';

  @override
  String get datasetNamePhave => 'PhaVE List กริยาวลี (150)';

  @override
  String get datasetShortPhave => 'กริยาวลี 150';

  @override
  String get updateDownloadedMessage => 'ดาวน์โหลดเวอร์ชันใหม่แล้ว';

  @override
  String get updateRestartButton => 'เริ่มใหม่';

  @override
  String get importLangEs => 'สเปน';

  @override
  String get importLangPt => 'โปรตุเกส';

  @override
  String get menuIntro => 'แนะนำฟีเจอร์';

  @override
  String get introSkip => 'ข้าม';

  @override
  String get introNext => 'ถัดไป';

  @override
  String get introStart => 'เริ่มเรียน';

  @override
  String get introTitle1 => 'เรียนภาษาอังกฤษด้วยกฎ 80/20';

  @override
  String get introBody1 =>
      'เชี่ยวชาญคำศัพท์หลัก NGSL 2,809 คำ แล้วคุณจะเข้าใจภาษาอังกฤษในชีวิตประจำวันได้ประมาณ 92% ไม่มีคำยากที่ไม่ค่อยได้ใช้ เวลาของคุณทุ่มไปกับคำที่ได้ใช้จริง';

  @override
  String get introTitle2 => 'ออกแบบมาเพื่อคนอย่างคุณ';

  @override
  String get introBody2 =>
      'เรียนภาษาอังกฤษมาหลายรอบแต่ไม่เคยติด? ความจำไม่เหมือนเดิม? รอบตัวไม่มีภาษาอังกฤษให้ใช้? วิธีนี้ออกแบบมาเพื่อคุณ ช่วยให้คุณกลับมามั่นใจอีกครั้ง';

  @override
  String get introTitle3 => 'เล่นเบื้องหลัง เปลี่ยนเวลาว่างเป็นเวลาเรียน';

  @override
  String get introBody3 =>
      'ฟังระหว่างเดินทาง เดินเล่น ทำงานบ้าน หรือออกกำลังกาย ล็อกหน้าจอหรือสลับแอปก็ยังเล่นต่อ ไม่ต้องจ้องโทรศัพท์';

  @override
  String get introTitle4 => 'เสียงสองภาษา + รายการคำที่ยังไม่คุ้น';

  @override
  String get introBody4 =>
      'ฟังคำภาษาอังกฤษแล้วตามด้วยความหมาย โดยไม่ต้องดูหน้าจอ ติดดาวคำที่ไม่รู้ แล้วเล่นซ้ำในโหมด \"เฉพาะคำที่ยังไม่คุ้น\" จนจำได้';

  @override
  String get introTitle5 => 'นำเข้าสื่อของคุณเอง รองรับ 14 ภาษา';

  @override
  String get introBody5 =>
      'คำศัพท์ในหนังสือเรียน วลีที่ใช้ในงาน รายการสอบ บันทึกเป็นไฟล์ CSV แล้วนำเข้า ฟังเบื้องหลังและทำเครื่องหมายคำที่ยังไม่คุ้นได้เหมือนเดิม ไม่ใช่แค่ภาษาอังกฤษ ยังมีจีน ญี่ปุ่น เกาหลี ฝรั่งเศส เยอรมัน สเปน อาหรับ และอื่น ๆ รวม 14 ภาษา เลือกภาษาคำแปลที่คุณถนัดได้ (บางภาษาต้องดาวน์โหลดเสียงในโทรศัพท์ก่อน)';

  @override
  String get introTitle6 => 'คำศัพท์วิชาการ 4 ชุด เริ่มใช้ฟรี';

  @override
  String get introBody6 =>
      'NGSL 2809 คำศัพท์หลัก, Spoken 720, PHRASE List 506 และ PhaVE List 150 ทั้งหมดจากงานวิจัยทางวิชาการที่เผยแพร่แล้ว ทุกชุดมีเนื้อหาฟรีให้ลองก่อนตัดสินใจ';

  @override
  String get importWordLangLabel =>
      'คอลัมน์แรกเป็นภาษาอะไร? (ใช้กำหนดเสียงอ่าน)';

  @override
  String importVoiceMissing(String language) {
    return 'โทรศัพท์ของคุณไม่มีเสียงอ่านสำหรับ \"$language\" จึงอ่านออกเสียงไม่ได้ ติดตั้งได้ที่ การตั้งค่า → การแปลงข้อความเป็นเสียง';
  }

  @override
  String get menuShare => 'แชร์ให้เพื่อน';

  @override
  String get shareMessage =>
      'ขอแนะนำแอป \"คำศัพท์ภาษาอังกฤษ ฝึกฟัง\" เรียนด้วยกฎ 80/20 เฉพาะคำศัพท์หลักที่ครอบคลุม 92% ของภาษาอังกฤษในชีวิตประจำวัน อ่านออกเสียงเบื้องหลังระหว่างเดินทาง เดิน หรือทำงานบ้าน ฟังได้สองภาษา ดาวน์โหลดฟรี:';

  @override
  String get menuAdPrivacy => 'การตั้งค่าความเป็นส่วนตัวของโฆษณา';

  @override
  String get switchDatasetButton => 'เปลี่ยนชุดคำ';

  @override
  String get unlockMoreButton => 'ปลดล็อกเพิ่ม';

  @override
  String get playShortStart => 'เริ่มฟัง';

  @override
  String get playShortPause => 'หยุดชั่วคราว';

  @override
  String cycleShort(int n) {
    return 'รอบที่ $n';
  }

  @override
  String get wordSizeLabel => 'ขนาดคำศัพท์';

  @override
  String get wordSizeSmall => 'เล็ก';

  @override
  String get wordSizeMedium => 'กลาง';

  @override
  String get wordSizeLarge => 'ใหญ่';

  @override
  String get lockScreenCoverLabel => 'แสดงปกตัวอักษรใหญ่บนหน้าจอล็อก';

  @override
  String get lockScreenCoverDesc =>
      'เมื่อปิด หน้าจอล็อกจะแสดงการ์ดตัวอักษรเล็กแบบปกติ';

  @override
  String get appearanceLabel => 'รูปแบบการแสดงผล';

  @override
  String get appearanceSystem => 'ตามระบบ';

  @override
  String get appearanceLight => 'สว่าง';

  @override
  String get appearanceDark => 'มืด';

  @override
  String notifLastHeard(String word) {
    return 'ฟังล่าสุด: $word';
  }

  @override
  String notifStarredLeft(int count) {
    return 'ยังมีคำที่ยังไม่คุ้นอีก $count คำ';
  }

  @override
  String get notifActionStart => '▶ เริ่มฟัง';

  @override
  String get notifActionSnooze => 'เตือนภายหลัง';
}
