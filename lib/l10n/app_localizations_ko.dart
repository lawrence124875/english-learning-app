// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '스마트 리스닝 크루즈';

  @override
  String get statsTooltip => '학습 통계';

  @override
  String get moreTooltip => '더보기';

  @override
  String get menuPremium => 'Premium 업그레이드';

  @override
  String get menuVoicePreview => '음성 미리듣기';

  @override
  String get menuImport => '사용자 지정 교재 가져오기';

  @override
  String get menuAbout => '앱 정보 / 저작권 안내';

  @override
  String wordNumberLabel(int current, int total) {
    return 'No. $current / $total';
  }

  @override
  String cycleLabel(int n) {
    return '$n회차 학습';
  }

  @override
  String roundProgressLabel(int heard, int total, int percent) {
    return '이번 회차 진행률: $heard / $total ($percent%)';
  }

  @override
  String get playButtonStart => '순항 낭독 시작';

  @override
  String get playButtonPause => '순항 낭독 일시정지';

  @override
  String get starButton => '모르는 단어에 추가';

  @override
  String get navPrevious => '이전';

  @override
  String get navReplay => '다시 듣기';

  @override
  String get navNext => '다음';

  @override
  String get statsTitle => '학습 통계';

  @override
  String get todayLearnedLabel => '오늘 학습한 단어';

  @override
  String get totalLearnedLabel => '누적 학습한 단어';

  @override
  String get unitCount => '개';

  @override
  String get datasetProgressHeader => '교재별 학습 진행률';

  @override
  String itemsCountLabel(int learned, int total) {
    return '$learned / $total개 항목';
  }

  @override
  String get dailyReminderHeader => '매일 복습 알림';

  @override
  String get enableDailyReminder => '매일 알림 켜기';

  @override
  String get reminderTimeLabel => '알림 시간';

  @override
  String reminderScheduledMessage(String time) {
    return '$time에 알림이 설정되었습니다';
  }

  @override
  String get reminderFailedMessage =>
      '설정에 실패했습니다. 배터리 최적화 설정을 확인하거나 알림을 다시 켜주세요';

  @override
  String get batteryOptButtonLabel => '알림이 제때 오지 않나요? 배터리 최적화 제한 해제';

  @override
  String get batteryOptSnackbar => '\'절전 전략\'에서 \'무제한\'을 선택해 주세요';

  @override
  String get miuiAutostartButtonLabel => '샤오미/Redmi 기기는 \'자동 시작\'도 켜주세요';

  @override
  String get miuiAutostartSnackbar =>
      '샤오미 기기는 목록에서 이 앱을 찾아 자동 시작을 켜주세요 (다른 제조사 기기는 무시 가능)';

  @override
  String get settingsTitle => '재생 설정';

  @override
  String starredCountLabel(int n) {
    return '$n개 항목을 표시했습니다';
  }

  @override
  String get speakOnManualNavigateLabel => '수동 전환 시 발음하기';

  @override
  String get showTranslationLabel => '번역 표시';

  @override
  String intervalSecondsLabel(String seconds) {
    return '단어 간격: $seconds초';
  }

  @override
  String speechRateLabel(String rate) {
    return '낭독 속도: ${rate}x';
  }

  @override
  String get scopeModeLabel => '재생 범위 / 모드';

  @override
  String get scopeAllRandom => '전체 목록 (무작위 재생)';

  @override
  String get scopeAllSequential => '전체 목록 (순서대로 재생)';

  @override
  String get scopeStarredRandom => '모르는 단어만 (무작위 재생)';

  @override
  String get scopeStarredSequential => '모르는 단어만 (순서대로 재생)';

  @override
  String get readModeLabel => '낭독 모드';

  @override
  String get readModeBilingual => '이중 언어 낭독 (영어+번역)';

  @override
  String get readModeEnglishOnly => '영어만';

  @override
  String get repeatCountLabel => '영어 반복 횟수';

  @override
  String get repeatOnce => '1회 읽기';

  @override
  String get repeatTwice => '2회 읽기 (추천)';

  @override
  String get repeatThrice => '3회 읽기';

  @override
  String get commonCancel => '취소';

  @override
  String get commonDelete => '삭제';

  @override
  String get voicePreviewIntro =>
      '휴대폰에서 사용할 수 있는 영어 음성 목록입니다. 재생 아이콘을 누르면 미리 들을 수 있습니다. 실제 낭독 시에는 시스템 기본 음성(언어에 따라 자동 선택)을 사용하며, 이 화면은 어떤 음성이 있는지 들어보기 위한 용도입니다.';

  @override
  String get voicePreviewNoVoices =>
      '사용 가능한 음성을 찾을 수 없습니다. 휴대폰에 영어 음성 데이터가 설치되어 있는지 확인해 주세요.';

  @override
  String get voicePreviewUnknownVoice => '알 수 없는 음성';

  @override
  String get paywallPurchaseSuccess => '구독 완료! 전체 콘텐츠가 열리고 광고가 제거되었습니다.';

  @override
  String get paywallPurchaseFailed => '구매가 완료되지 않았습니다. 잠시 후 다시 시도해 주세요.';

  @override
  String get paywallRestoreSuccess => 'Premium 구독이 복원되었습니다!';

  @override
  String get paywallRestoreNotFound => '복원할 구매 내역이 없습니다.';

  @override
  String get paywallAlreadyPremium => '이미 Premium 구독 중입니다 🎉';

  @override
  String get paywallHeadline => '전체 학습 콘텐츠 잠금 해제';

  @override
  String get paywallBenefitAllContent => '4가지 교재 100% 전체 이용';

  @override
  String get paywallBenefitNoAds => '광고 완전 제거';

  @override
  String get paywallBenefitBackground => '백그라운드 재생, 잠금 화면 표시';

  @override
  String get paywallRestoreButton => '이전 구매 복원';

  @override
  String get paywallNoPackages => '현재 이용 가능한 구독 플랜이 없습니다. 잠시 후 다시 시도해 주세요.';

  @override
  String get paywallPlanMonthly => '월간 구독';

  @override
  String get paywallPlanAnnual => '연간 구독';

  @override
  String get paywallTermsNote =>
      '구독은 자동으로 갱신되며, Google Play의 “결제 및 정기 결제”에서 언제든지 해지할 수 있습니다. 해지 후에도 현재 결제 기간이 끝날 때까지 Premium을 이용할 수 있으며, 이후 자동으로 무료 버전으로 전환됩니다.';

  @override
  String get paywallManageSubscription => '구독 관리 / 해지';

  @override
  String get unlockRewardSnackbar => '20개 항목이 추가로 열렸습니다!';

  @override
  String unlockFreeProgress(int unlocked, int total) {
    return '무료 버전: $unlocked / $total개 항목 이용 가능';
  }

  @override
  String get unlockAdLoading => '광고 준비 중…';

  @override
  String get unlockWatchAd => '광고 보고 +20';

  @override
  String get importIntro =>
      '직접 준비한 단어, 구문, 자주 쓰는 예문(가지고 있는 책 내용 등)을 가져올 수 있습니다. 가져온 후에는 기본 교재처럼 전환하여 낭독할 수 있습니다.';

  @override
  String get importFormatTitle => '가져오기 형식 (CSV, 헤더 포함)';

  @override
  String get importSampleApple => '사과';

  @override
  String get importSampleGiveUp => '포기하다';

  @override
  String get importSampleHowAreYou => '오늘 어떻게 지내?';

  @override
  String get importFormatHint =>
      '첫 번째 열에는 영어(단어, 구문, 예문 모두 가능), 두 번째 열에는 번역을 넣고 CSV 파일로 저장하면 가져올 수 있습니다. 영어 이외의 언어도 가져올 수 있습니다. 아래에서 첫 번째 열의 언어를 선택하세요.';

  @override
  String get importGetTemplate => '템플릿 파일 받기';

  @override
  String importTemplateSaved(String path) {
    return '템플릿을 임시 폴더에 저장했습니다: $path';
  }

  @override
  String get importNameLabel => '교재 이름';

  @override
  String get importNameHint => '예: 토익 핵심 예문';

  @override
  String get importNameRequired => '먼저 교재 이름을 입력해 주세요';

  @override
  String get importTranslationLangLabel => '번역 열은 어떤 언어인가요?';

  @override
  String get importLangZh => '중국어';

  @override
  String get importLangJa => '일본어';

  @override
  String get importLangKo => '한국어';

  @override
  String get importLangVi => '베트남어';

  @override
  String get importLangEn => '영어';

  @override
  String get importButton => 'CSV 파일 선택 후 가져오기';

  @override
  String get importingInProgress => '가져오는 중…';

  @override
  String importDone(int count) {
    return '가져오기 완료! 총 $count개';
  }

  @override
  String importDoneWithSkipped(int count, int skipped) {
    return '가져오기 완료! 총 $count개 (빈 행 $skipped개 건너뜀)';
  }

  @override
  String importFailedWithReason(String reason) {
    return '가져오기 실패: $reason';
  }

  @override
  String get importFailedGeneric => '가져오기에 실패했습니다. 파일 형식을 확인해 주세요';

  @override
  String get importErrorEncoding =>
      '파일 인코딩이 UTF-8이 아니어서 읽을 수 없습니다. Excel에서 “다른 이름으로 저장” 시 “CSV UTF-8(쉼표로 분리)”을 선택하거나, 텍스트 편집기에서 UTF-8로 다시 저장해 주세요.';

  @override
  String get importErrorParse => 'CSV 분석에 실패했습니다. 표준 쉼표 구분 형식인지 확인해 주세요.';

  @override
  String get importErrorEmpty => '파일이 비어 있습니다. 내용을 확인해 주세요.';

  @override
  String get importErrorNoRows => '유효한 데이터 행을 찾지 못했습니다. 형식을 확인해 주세요.';

  @override
  String get importDeleteTitle => '사용자 지정 교재 삭제';

  @override
  String importDeleteConfirm(String name) {
    return '“$name”을(를) 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.';
  }

  @override
  String get importedListHeader => '가져온 사용자 지정 교재';

  @override
  String importItemCount(int n) {
    return '$n개 항목';
  }

  @override
  String get aboutFeedbackButton => '의견 보내기 / 문제 신고';

  @override
  String get aboutAttributionIntro =>
      '이 앱의 단어·구문 데이터는 아래의 공개 학술 연구 성과를 바탕으로 하며, 감사의 뜻과 함께 출처를 밝힙니다:';

  @override
  String get aboutNgslTitle => 'NGSL 2809 (핵심 단어)';

  @override
  String get aboutSpokenTitle => 'NGSL-Spoken 720 (구어 빈출 단어)';

  @override
  String get aboutPhaveTitle => 'PhaVE List (구동사)';

  @override
  String get aboutPhraseTitle => 'PHRASE List (고빈도 청크)';

  @override
  String get aboutLicenseCcBySa =>
      '크리에이티브 커먼즈 “저작자표시-동일조건변경허락 4.0 국제” 라이선스(CC BY-SA 4.0)에 따라 제공됩니다.';

  @override
  String get aboutLicenseCcBy =>
      '크리에이티브 커먼즈 “저작자표시 4.0 국제” 라이선스(CC BY 4.0)에 따라 제공됩니다.';

  @override
  String get aboutPhraseRights =>
      '저작권은 원저자에게 있으며, 이 앱은 허용된 범위 내에서 교육 목적으로 사용합니다.';

  @override
  String aboutSourceLabel(String name) {
    return '원저작물: $name';
  }

  @override
  String aboutLicenseLabel(String name) {
    return '라이선스: $name';
  }

  @override
  String get aboutTtsNote => '낭독 음성은 기기에 내장된 TTS(텍스트 음성 변환) 엔진으로 제공됩니다.';

  @override
  String get feedbackTitle => '의견 보내기';

  @override
  String get feedbackCategoryLabel => '유형';

  @override
  String get feedbackCategoryBug => '문제 신고';

  @override
  String get feedbackCategorySuggestion => '기능 제안';

  @override
  String get feedbackCategoryOther => '기타';

  @override
  String get feedbackMessageLabel => '내용';

  @override
  String get feedbackMessageHint => '겪은 문제나 추가되었으면 하는 기능을 알려주세요…';

  @override
  String get feedbackEmailLabel => '연락처 이메일 (선택)';

  @override
  String get feedbackEmailHint => '답변을 받고 싶으시면 이메일을 남겨 주세요';

  @override
  String get feedbackSubmit => '보내기';

  @override
  String get feedbackEmpty => '내용을 입력한 후 보내 주세요';

  @override
  String get feedbackThanks => '소중한 의견 감사합니다. 빠르게 확인하겠습니다!';

  @override
  String get feedbackFailed => '전송에 실패했습니다. 네트워크 연결을 확인한 후 다시 시도해 주세요';

  @override
  String get statsDescNgsl =>
      '공개된 빈도 연구에서 추출한 영어 핵심 단어 목록입니다. 이 2,809개 단어를 익히면 일상적인 영어 텍스트의 약 92%를 이해할 수 있습니다 (출처: New General Service List Project).';

  @override
  String get statsDescSpoken =>
      '일상 대화에서 선별한 720개의 고빈도 어휘로, 듣기와 말하기 상황의 반응 속도를 높여 줍니다. NGSL 핵심 단어를 보완하며, 글에서는 드물지만 말할 때 자주 쓰는 표현을 다룹니다.';

  @override
  String get statsDescPhrase =>
      '원어민이 실제로 자주 쓰는 506개의 연어·고정 표현(예: \"in order to\", \"as well as\")입니다. 단어가 아니라 한 덩어리로 외우는 구문으로, 더 자연스러운 영어를 구사하는 데 도움이 됩니다.';

  @override
  String get statsDescPhave =>
      '가장 많이 쓰이는 구동사 150개(예: \"look after\", \"give up\")를 수록했습니다. 동사+전치사 조합은 학습자들이 가장 어려워하는 부분으로, 이 150개를 집중 복습하면 일상에서 만나는 구동사 대부분을 커버할 수 있습니다.';

  @override
  String get summaryReadBilingual => '영+번역';

  @override
  String get summaryReadEnglishOnly => '영어만';

  @override
  String settingsSummaryLine(String mode, int count, String rate) {
    return '$mode・$count회・${rate}x';
  }

  @override
  String get notifChannelName => '복습 알림';

  @override
  String get notifChannelDesc => '매일 영어 복습 알림';

  @override
  String get notifDailyTitle => '영어 복습할 시간이에요!';

  @override
  String get notifDailyBody => '단어 몇 개를 들으며 오늘 배운 내용을 다져 보세요';

  @override
  String get notifInactivityTitle => '오랜만이에요 👋';

  @override
  String get notifInactivityBody => '며칠 동안 복습하지 않았어요. 단어 몇 개를 들으며 기억을 되살려 보세요';

  @override
  String get audioChannelName => '영어 학습 낭독';

  @override
  String get importLangId => '인도네시아어';

  @override
  String get datasetNameNgsl => 'NGSL 2809 핵심 단어';

  @override
  String get datasetShortNgsl => 'NGSL 2809단어';

  @override
  String get datasetNameSpoken => 'NGSL 구어 720단어';

  @override
  String get datasetShortSpoken => '구어 720';

  @override
  String get datasetNamePhrase => 'PHRASE List 고빈도 청크 (506)';

  @override
  String get datasetShortPhrase => '청크 506';

  @override
  String get datasetNamePhave => 'PhaVE List 구동사 (150)';

  @override
  String get datasetShortPhave => '구동사 150';

  @override
  String get updateDownloadedMessage => '새 버전 다운로드가 완료되었습니다';

  @override
  String get updateRestartButton => '다시 시작';

  @override
  String get importLangEs => '스페인어';

  @override
  String get importLangPt => '포르투갈어';

  @override
  String get menuIntro => '기능 소개';

  @override
  String get introSkip => '건너뛰기';

  @override
  String get introNext => '다음';

  @override
  String get introStart => '학습 시작하기';

  @override
  String get introTitle1 => '20/80 법칙으로 영어 배우기';

  @override
  String get introBody1 =>
      'NGSL 핵심 단어 2,809개를 익히면 일상 영어 문장의 약 92%를 이해할 수 있습니다. 잘 쓰지 않는 어려운 단어 대신, 실제로 쓰이는 단어에 시간을 집중합니다.';

  @override
  String get introTitle2 => '이런 분들을 위해 만들었습니다';

  @override
  String get introBody2 =>
      '영어를 여러 번 시작했지만 매번 중간에 포기한 분, 나이가 들며 기억력이 예전 같지 않은 분, 주변에 영어 환경이 없는 분을 위해 설계했습니다. 영어 공부에 대한 자신감을 다시 찾아보세요.';

  @override
  String get introTitle3 => '백그라운드 낭독, 자투리 시간을 학습 시간으로';

  @override
  String get introBody3 =>
      '출퇴근, 산책, 집안일, 운동 중에도 들을 수 있습니다. 화면을 잠그거나 다른 앱으로 전환해도 낭독이 계속되므로 화면을 계속 볼 필요가 없습니다.';

  @override
  String get introTitle4 => '2개 국어 낭독 + 모르는 단어장';

  @override
  String get introBody4 =>
      '영어를 읽은 뒤 한국어 뜻을 읽어 주므로 화면을 보지 않아도 뜻을 알 수 있습니다. 모르는 단어는 별표로 표시하고 \'모르는 단어만\' 모드로 외울 때까지 집중해서 반복해 들을 수 있습니다.';

  @override
  String get introTitle5 => '나만의 교재 가져오기: 14개 언어 지원';

  @override
  String get introBody5 =>
      '교과서 단어, 업무 표현, 시험 범위 등을 CSV 파일로 가져오면 똑같이 백그라운드 낭독과 모르는 단어 표시가 가능합니다. 영어뿐 아니라 일본어, 중국어, 프랑스어, 독일어, 스페인어, 태국어, 아랍어 등 14개 언어 낭독을 지원하며, 번역도 익숙한 언어로 고를 수 있습니다. (일부 언어는 기기에서 음성 데이터를 먼저 내려받아야 합니다)';

  @override
  String get introTitle6 => '4가지 학술 교재, 무료로 시작';

  @override
  String get introBody6 =>
      '핵심 단어 NGSL 2809, 구어 빈출 단어 720, 빈출 어구 506, 구동사 150. 모두 공개된 학술 연구에 기반합니다. 교재마다 무료 콘텐츠가 있으니 먼저 체험해 보세요.';

  @override
  String get importWordLangLabel => '첫 번째 열의 언어는? (읽기 음성에 사용)';

  @override
  String importVoiceMissing(String language) {
    return '이 휴대폰에는 「$language」 읽기 음성이 없어 읽을 수 없습니다. 휴대폰 「설정 → 텍스트 음성 변환」에서 해당 언어 음성을 설치하세요.';
  }

  @override
  String get menuShare => '친구에게 공유';

  @override
  String get shareMessage =>
      '영어 학습 앱 「스마트 리스닝 크루즈」를 추천해요. 20/80 법칙으로 일상 영어의 92%를 차지하는 핵심 단어만 학습하고, 출퇴근·산책·집안일 중에 백그라운드로 읽어 주며 모국어와 함께 들을 수 있어요. 무료 다운로드:';

  @override
  String get menuAdPrivacy => '광고 개인정보 설정';

  @override
  String get switchDatasetButton => '교재 바꾸기';

  @override
  String get unlockMoreButton => '더 열기';

  @override
  String get playShortStart => '낭독 시작';

  @override
  String get playShortPause => '일시정지';

  @override
  String cycleShort(int n) {
    return '$n회차';
  }

  @override
  String get wordSizeLabel => '단어 크기';

  @override
  String get wordSizeSmall => '작게';

  @override
  String get wordSizeMedium => '보통';

  @override
  String get wordSizeLarge => '크게';

  @override
  String get lockScreenCoverLabel => '잠금 화면에 큰 글자 표지 표시';

  @override
  String get lockScreenCoverDesc => '끄면 잠금 화면에 일반 작은 글자 카드만 표시됩니다';

  @override
  String get appearanceLabel => '화면 모드';

  @override
  String get appearanceSystem => '시스템 설정 따르기';

  @override
  String get appearanceLight => '라이트';

  @override
  String get appearanceDark => '다크';

  @override
  String notifLastHeard(String word) {
    return '지난번 단어: $word';
  }

  @override
  String notifStarredLeft(int count) {
    return '모르는 단어가 $count개 남았어요';
  }

  @override
  String get notifActionStart => '▶ 낭독 시작';

  @override
  String get notifActionSnooze => '나중에 알림';
}
