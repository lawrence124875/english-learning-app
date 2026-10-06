// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Học Từ Vựng Tiếng Anh Qua Nghe';

  @override
  String get statsTooltip => 'Thống kê học tập';

  @override
  String get moreTooltip => 'Thêm';

  @override
  String get menuPremium => 'Nâng cấp Premium';

  @override
  String get menuVoicePreview => 'Xem trước giọng đọc';

  @override
  String get menuImport => 'Nhập tài liệu tùy chỉnh';

  @override
  String get menuAbout => 'Giới thiệu về App / Bản quyền';

  @override
  String wordNumberLabel(int current, int total) {
    return 'No. $current / $total';
  }

  @override
  String cycleLabel(int n) {
    return 'Vòng học thứ $n';
  }

  @override
  String roundProgressLabel(int heard, int total, int percent) {
    return 'Tiến độ vòng này: $heard / $total ($percent%)';
  }

  @override
  String get playButtonStart => 'Bắt đầu đọc';

  @override
  String get playButtonPause => 'Tạm dừng đọc';

  @override
  String get starButton => 'Thêm vào từ chưa thuộc';

  @override
  String get navPrevious => 'Trước';

  @override
  String get navReplay => 'Đọc lại';

  @override
  String get navNext => 'Tiếp';

  @override
  String get statsTitle => 'Thống kê học tập';

  @override
  String get todayLearnedLabel => 'Đã học hôm nay';

  @override
  String get totalLearnedLabel => 'Tổng đã học';

  @override
  String get unitCount => 'từ';

  @override
  String get datasetProgressHeader => 'Tiến độ từng bộ tài liệu';

  @override
  String itemsCountLabel(int learned, int total) {
    return '$learned / $total mục';
  }

  @override
  String get dailyReminderHeader => 'Nhắc nhở ôn tập hàng ngày';

  @override
  String get enableDailyReminder => 'Bật nhắc nhở hàng ngày';

  @override
  String get reminderTimeLabel => 'Giờ nhắc nhở';

  @override
  String reminderScheduledMessage(String time) {
    return 'Đã đặt nhắc nhở lúc $time';
  }

  @override
  String get reminderFailedMessage =>
      'Đặt lịch thất bại, vui lòng kiểm tra cài đặt tối ưu hóa pin hoặc bật lại nhắc nhở';

  @override
  String get batteryOptButtonLabel =>
      'Nhắc nhở không đúng giờ? Nhấn để bỏ giới hạn tối ưu hóa pin';

  @override
  String get batteryOptSnackbar =>
      'Vui lòng chọn \"Không giới hạn\" trong \"Chiến lược tiết kiệm pin\"';

  @override
  String get miuiAutostartButtonLabel =>
      'Máy Xiaomi/Redmi vui lòng bật thêm \"Tự khởi động\"';

  @override
  String get miuiAutostartSnackbar =>
      'Máy Xiaomi vui lòng tìm ứng dụng này trong danh sách và bật tự khởi động (máy hãng khác có thể bỏ qua)';

  @override
  String get settingsTitle => 'Cài đặt phát';

  @override
  String starredCountLabel(int n) {
    return 'Đã đánh dấu $n mục';
  }

  @override
  String get speakOnManualNavigateLabel => 'Đọc khi chuyển thủ công';

  @override
  String get showTranslationLabel => 'Hiển thị bản dịch';

  @override
  String intervalSecondsLabel(String seconds) {
    return 'Khoảng cách giữa các từ: $seconds giây';
  }

  @override
  String speechRateLabel(String rate) {
    return 'Tốc độ đọc: ${rate}x';
  }

  @override
  String get scopeModeLabel => 'Phạm vi / Chế độ phát';

  @override
  String get scopeAllRandom => 'Toàn bộ danh sách (ngẫu nhiên)';

  @override
  String get scopeAllSequential => 'Toàn bộ danh sách (tuần tự)';

  @override
  String get scopeStarredRandom => 'Chỉ từ chưa thuộc (ngẫu nhiên)';

  @override
  String get scopeStarredSequential => 'Chỉ từ chưa thuộc (tuần tự)';

  @override
  String get readModeLabel => 'Chế độ đọc';

  @override
  String get readModeBilingual => 'Đọc song ngữ (Anh + bản dịch)';

  @override
  String get readModeEnglishOnly => 'Chỉ tiếng Anh';

  @override
  String get repeatCountLabel => 'Số lần lặp lại tiếng Anh';

  @override
  String get repeatOnce => 'Đọc 1 lần';

  @override
  String get repeatTwice => 'Đọc 2 lần (khuyên dùng)';

  @override
  String get repeatThrice => 'Đọc 3 lần';

  @override
  String get commonCancel => 'Hủy';

  @override
  String get commonDelete => 'Xóa';

  @override
  String get voicePreviewIntro =>
      'Đây là danh sách giọng đọc tiếng Anh có trên điện thoại của bạn. Nhấn biểu tượng loa để nghe thử. Khi đọc chính thức, ứng dụng sẽ dùng giọng mặc định của hệ thống (tự chọn theo ngôn ngữ); màn hình này chỉ để bạn nghe thử các giọng hiện có.';

  @override
  String get voicePreviewNoVoices =>
      'Không tìm thấy giọng đọc nào. Vui lòng kiểm tra điện thoại đã cài gói giọng đọc tiếng Anh chưa.';

  @override
  String get voicePreviewUnknownVoice => 'Giọng không xác định';

  @override
  String get paywallPurchaseSuccess =>
      'Đăng ký thành công! Đã mở khóa toàn bộ nội dung và gỡ quảng cáo.';

  @override
  String get paywallPurchaseFailed =>
      'Giao dịch chưa hoàn tất, vui lòng thử lại sau.';

  @override
  String get paywallRestoreSuccess => 'Đã khôi phục gói Premium!';

  @override
  String get paywallRestoreNotFound =>
      'Không tìm thấy giao dịch nào để khôi phục.';

  @override
  String get paywallAlreadyPremium => 'Bạn đã là thành viên Premium 🎉';

  @override
  String get paywallHeadline => 'Mở khóa toàn bộ nội dung học';

  @override
  String get paywallBenefitAllContent => 'Mở 100% cả 4 bộ tài liệu';

  @override
  String get paywallBenefitNoAds => 'Loại bỏ hoàn toàn quảng cáo';

  @override
  String get paywallBenefitBackground =>
      'Phát nền, hiển thị trên màn hình khóa';

  @override
  String get paywallRestoreButton => 'Khôi phục giao dịch trước đó';

  @override
  String get paywallNoPackages =>
      'Hiện chưa có gói đăng ký nào, vui lòng thử lại sau.';

  @override
  String get paywallPlanMonthly => 'Gói theo tháng';

  @override
  String get paywallPlanAnnual => 'Gói theo năm';

  @override
  String get paywallTermsNote =>
      'Gói đăng ký sẽ tự động gia hạn. Bạn có thể hủy bất cứ lúc nào trong mục “Thanh toán và gói thuê bao” của Google Play. Sau khi hủy, bạn vẫn dùng được Premium đến hết kỳ hiện tại, sau đó tự động chuyển về bản miễn phí.';

  @override
  String get paywallManageSubscription => 'Quản lý / hủy gói đăng ký';

  @override
  String get unlockRewardSnackbar => 'Đã mở khóa thêm 20 mục!';

  @override
  String unlockFreeProgress(int unlocked, int total) {
    return 'Bản miễn phí: đã mở $unlocked / $total mục';
  }

  @override
  String get unlockAdLoading => 'Đang tải quảng cáo…';

  @override
  String get unlockWatchAd => 'Xem quảng cáo +20';

  @override
  String get importIntro =>
      'Bạn có thể nhập từ vựng, cụm từ hoặc câu mẫu do mình tự chuẩn bị (ví dụ nội dung trong sách của bạn). Sau khi nhập, có thể chuyển sang và nghe đọc giống như các bộ tài liệu có sẵn.';

  @override
  String get importFormatTitle => 'Định dạng nhập (CSV, có dòng tiêu đề)';

  @override
  String get importSampleApple => 'quả táo';

  @override
  String get importSampleGiveUp => 'từ bỏ';

  @override
  String get importSampleHowAreYou => 'Hôm nay bạn thế nào?';

  @override
  String get importFormatHint =>
      'Cột thứ nhất là tiếng Anh (từ, cụm từ hoặc cả câu đều được), cột thứ hai là bản dịch tương ứng, lưu thành file CSV là có thể nhập. Bạn cũng có thể nhập ngôn ngữ khác ngoài tiếng Anh, chỉ cần chọn ngôn ngữ của cột thứ nhất bên dưới.';

  @override
  String get importGetTemplate => 'Tải file mẫu';

  @override
  String importTemplateSaved(String path) {
    return 'Đã lưu file mẫu vào thư mục tạm: $path';
  }

  @override
  String get importNameLabel => 'Tên bộ tài liệu';

  @override
  String get importNameHint => 'Ví dụ: Câu mẫu TOEIC';

  @override
  String get importNameRequired => 'Vui lòng đặt tên cho bộ tài liệu trước';

  @override
  String get importTranslationLangLabel => 'Cột bản dịch là ngôn ngữ nào?';

  @override
  String get importLangZh => 'Tiếng Trung';

  @override
  String get importLangJa => 'Tiếng Nhật';

  @override
  String get importLangKo => 'Tiếng Hàn';

  @override
  String get importLangVi => 'Tiếng Việt';

  @override
  String get importLangEn => 'Tiếng Anh';

  @override
  String get importButton => 'Chọn file CSV để nhập';

  @override
  String get importingInProgress => 'Đang nhập…';

  @override
  String importDone(int count) {
    return 'Nhập xong! Tổng cộng $count mục';
  }

  @override
  String importDoneWithSkipped(int count, int skipped) {
    return 'Nhập xong! Tổng cộng $count mục (bỏ qua $skipped dòng trống)';
  }

  @override
  String importFailedWithReason(String reason) {
    return 'Nhập thất bại: $reason';
  }

  @override
  String get importFailedGeneric =>
      'Nhập thất bại, vui lòng kiểm tra định dạng file';

  @override
  String get importErrorEncoding =>
      'File không dùng mã hóa UTF-8 nên không đọc được. Khi “Lưu thành” trong Excel, hãy chọn “CSV UTF-8 (Phân tách bằng dấu phẩy)”, hoặc lưu lại bằng trình soạn thảo văn bản với mã hóa UTF-8.';

  @override
  String get importErrorParse =>
      'Không phân tích được CSV, vui lòng kiểm tra file có đúng định dạng phân tách bằng dấu phẩy không.';

  @override
  String get importErrorEmpty => 'File trống, vui lòng kiểm tra nội dung.';

  @override
  String get importErrorNoRows =>
      'Không tìm thấy dòng dữ liệu hợp lệ nào, vui lòng kiểm tra định dạng.';

  @override
  String get importDeleteTitle => 'Xóa tài liệu tùy chỉnh';

  @override
  String importDeleteConfirm(String name) {
    return 'Bạn có chắc muốn xóa “$name”? Thao tác này không thể hoàn tác.';
  }

  @override
  String get importedListHeader => 'Tài liệu tùy chỉnh đã nhập';

  @override
  String importItemCount(int n) {
    return '$n mục';
  }

  @override
  String get aboutFeedbackButton => 'Góp ý / Báo lỗi';

  @override
  String get aboutAttributionIntro =>
      'Dữ liệu từ vựng và cụm từ trong ứng dụng được lấy từ các công trình nghiên cứu học thuật công khai dưới đây. Xin chân thành cảm ơn và ghi rõ nguồn:';

  @override
  String get aboutNgslTitle => 'NGSL 2809 (Từ vựng cốt lõi)';

  @override
  String get aboutSpokenTitle =>
      'NGSL-Spoken 720 (Từ thông dụng trong văn nói)';

  @override
  String get aboutPhaveTitle => 'PhaVE List (Cụm động từ)';

  @override
  String get aboutPhraseTitle => 'PHRASE List (Cụm từ tần suất cao)';

  @override
  String get aboutLicenseCcBySa =>
      'Được cấp phép theo Creative Commons Ghi công - Chia sẻ tương tự 4.0 Quốc tế (CC BY-SA 4.0).';

  @override
  String get aboutLicenseCcBy =>
      'Được cấp phép theo Creative Commons Ghi công 4.0 Quốc tế (CC BY 4.0).';

  @override
  String get aboutPhraseRights =>
      'Bản quyền thuộc về tác giả gốc; ứng dụng sử dụng cho mục đích giáo dục trong phạm vi được cho phép.';

  @override
  String aboutSourceLabel(String name) {
    return 'Tác phẩm gốc: $name';
  }

  @override
  String aboutLicenseLabel(String name) {
    return 'Giấy phép: $name';
  }

  @override
  String get aboutTtsNote =>
      'Giọng đọc được cung cấp bởi công cụ chuyển văn bản thành giọng nói (TTS) có sẵn trên thiết bị.';

  @override
  String get feedbackTitle => 'Góp ý';

  @override
  String get feedbackCategoryLabel => 'Loại';

  @override
  String get feedbackCategoryBug => 'Báo lỗi';

  @override
  String get feedbackCategorySuggestion => 'Đề xuất tính năng';

  @override
  String get feedbackCategoryOther => 'Khác';

  @override
  String get feedbackMessageLabel => 'Nội dung';

  @override
  String get feedbackMessageHint =>
      'Hãy cho chúng tôi biết vấn đề bạn gặp phải hoặc tính năng bạn muốn có…';

  @override
  String get feedbackEmailLabel => 'Email liên hệ (không bắt buộc)';

  @override
  String get feedbackEmailHint => 'Để lại email nếu bạn muốn nhận phản hồi';

  @override
  String get feedbackSubmit => 'Gửi góp ý';

  @override
  String get feedbackEmpty => 'Vui lòng nhập nội dung trước khi gửi';

  @override
  String get feedbackThanks =>
      'Cảm ơn góp ý của bạn, chúng tôi sẽ xem sớm nhất!';

  @override
  String get feedbackFailed =>
      'Gửi thất bại, vui lòng kiểm tra kết nối mạng và thử lại';

  @override
  String get statsDescNgsl =>
      'Danh sách từ vựng cốt lõi tiếng Anh dựa trên nghiên cứu tần suất công khai. Nắm vững 2.809 từ này giúp bạn hiểu khoảng 92% văn bản tiếng Anh thông dụng hằng ngày (Nguồn: New General Service List Project).';

  @override
  String get statsDescSpoken =>
      '720 từ tần suất cao chọn lọc từ hội thoại hằng ngày, giúp tăng tốc độ phản xạ khi nghe và nói. Bổ sung cho danh sách NGSL cốt lõi, bao gồm những từ thường dùng khi nói nhưng ít xuất hiện trong văn viết.';

  @override
  String get statsDescPhrase =>
      '506 cụm từ cố định mà người bản xứ thực sự hay dùng (ví dụ \"in order to\", \"as well as\"). Đây không phải từ đơn mà là những cụm cần học nguyên khối, giúp bạn nói tiếng Anh tự nhiên hơn.';

  @override
  String get statsDescPhave =>
      'Gồm 150 cụm động từ thông dụng nhất (ví dụ \"look after\", \"give up\"). Tổ hợp động từ + giới từ được xem là phần khó nhất với người học; ôn tập tập trung 150 cụm này sẽ bao quát phần lớn cụm động từ gặp hằng ngày.';

  @override
  String get summaryReadBilingual => 'Song ngữ';

  @override
  String get summaryReadEnglishOnly => 'Chỉ tiếng Anh';

  @override
  String settingsSummaryLine(String mode, int count, String rate) {
    return '$mode · $count lần · ${rate}x';
  }

  @override
  String get notifChannelName => 'Nhắc nhở ôn tập';

  @override
  String get notifChannelDesc => 'Thông báo nhắc ôn tập tiếng Anh hằng ngày';

  @override
  String get notifDailyTitle => 'Đến giờ ôn tiếng Anh rồi!';

  @override
  String get notifDailyBody =>
      'Quay lại nghe vài từ để củng cố những gì đã học hôm nay nhé';

  @override
  String get notifInactivityTitle => 'Lâu rồi không gặp 👋';

  @override
  String get notifInactivityBody =>
      'Đã vài ngày bạn chưa ôn tập, quay lại nghe vài từ để không quên nhé';

  @override
  String get audioChannelName => 'Đọc học tiếng Anh';

  @override
  String get importLangId => 'Tiếng Indonesia';

  @override
  String get datasetNameNgsl => 'NGSL 2809 từ cốt lõi';

  @override
  String get datasetShortNgsl => 'NGSL 2809 từ';

  @override
  String get datasetNameSpoken => 'NGSL 720 từ văn nói';

  @override
  String get datasetShortSpoken => 'Văn nói 720';

  @override
  String get datasetNamePhrase => 'PHRASE List cụm từ thông dụng (506)';

  @override
  String get datasetShortPhrase => 'Cụm từ 506';

  @override
  String get datasetNamePhave => 'PhaVE List cụm động từ (150)';

  @override
  String get datasetShortPhave => 'Cụm động từ 150';

  @override
  String get updateDownloadedMessage => 'Đã tải xong phiên bản mới';

  @override
  String get updateRestartButton => 'Khởi động lại';

  @override
  String get importLangEs => 'Tiếng Tây Ban Nha';

  @override
  String get importLangPt => 'Tiếng Bồ Đào Nha';

  @override
  String get menuIntro => 'Giới thiệu tính năng';

  @override
  String get introSkip => 'Bỏ qua';

  @override
  String get introNext => 'Tiếp';

  @override
  String get introStart => 'Bắt đầu học';

  @override
  String get introTitle1 => 'Học tiếng Anh theo quy tắc 20/80';

  @override
  String get introBody1 =>
      'Nắm vững 2.809 từ cốt lõi NGSL là bạn hiểu được khoảng 92% nội dung tiếng Anh thường ngày. Không học từ hiếm, dồn thời gian vào những từ thật sự dùng đến.';

  @override
  String get introTitle2 => 'Dành riêng cho bạn';

  @override
  String get introBody2 =>
      'Bạn đã học tiếng Anh nhiều lần nhưng đều bỏ dở, trí nhớ không còn như trước, hay không có môi trường tiếng Anh xung quanh? Phương pháp này được thiết kế cho bạn, giúp bạn lấy lại tự tin khi học tiếng Anh.';

  @override
  String get introTitle3 => 'Nghe nền, biến thời gian rảnh thành giờ học';

  @override
  String get introBody3 =>
      'Nghe khi đi làm, đi dạo, làm việc nhà hay tập thể dục. Khóa màn hình hoặc chuyển sang ứng dụng khác, phần đọc vẫn tiếp tục, không cần nhìn màn hình.';

  @override
  String get introTitle4 => 'Đọc song ngữ + kho từ chưa thuộc';

  @override
  String get introBody4 =>
      'Đọc tiếng Anh trước, rồi đọc nghĩa tiếng Việt, không nhìn màn hình vẫn hiểu. Đánh dấu sao những từ chưa thuộc và dùng chế độ \"Chỉ từ chưa thuộc\" để nghe lại nhiều lần cho đến khi nhớ hẳn.';

  @override
  String get introTitle5 => 'Nhập tài liệu riêng – hỗ trợ 14 ngôn ngữ';

  @override
  String get introBody5 =>
      'Từ vựng trong sách, cụm từ công việc, phạm vi ôn thi… lưu thành file CSV là nhập được, cũng nghe nền và đánh dấu từ chưa thuộc như bình thường. Không chỉ tiếng Anh: tiếng Nhật, Hàn, Trung, Pháp, Đức, Tây Ban Nha, Thái, Ả Rập… tổng cộng 14 ngôn ngữ đều đọc được, phần nghĩa cũng chọn được ngôn ngữ bạn quen. (Một số ngôn ngữ cần tải giọng đọc trên điện thoại trước)';

  @override
  String get introTitle6 => '4 bộ tài liệu học thuật, bắt đầu miễn phí';

  @override
  String get introBody6 =>
      'Từ cốt lõi NGSL 2809, từ khẩu ngữ 720, cụm từ thông dụng 506, cụm động từ 150, đều từ các nghiên cứu học thuật công khai. Mỗi bộ đều có phần miễn phí để bạn trải nghiệm trước.';

  @override
  String get importWordLangLabel =>
      'Cột thứ nhất là ngôn ngữ gì? (dùng cho giọng đọc)';

  @override
  String importVoiceMissing(String language) {
    return 'Điện thoại chưa có giọng đọc \"$language\" nên sẽ không đọc được. Hãy cài gói giọng nói trong \"Cài đặt → Chuyển văn bản thành giọng nói\".';
  }

  @override
  String get menuShare => 'Chia sẻ với bạn bè';

  @override
  String get shareMessage =>
      'Mình giới thiệu ứng dụng học tiếng Anh \"Học Từ Vựng Tiếng Anh Qua Nghe\": học theo quy tắc 20/80, chỉ tập trung vào các từ cốt lõi chiếm 92% tiếng Anh hằng ngày, tự đọc nền khi bạn đi làm, đi bộ hay làm việc nhà, nghe song ngữ. Tải miễn phí:';

  @override
  String get menuAdPrivacy => 'Cài đặt quyền riêng tư quảng cáo';

  @override
  String get switchDatasetButton => 'Đổi tài liệu';

  @override
  String get unlockMoreButton => 'Mở thêm';

  @override
  String get playShortStart => 'Bắt đầu đọc';

  @override
  String get playShortPause => 'Tạm dừng';

  @override
  String cycleShort(int n) {
    return 'Vòng $n';
  }

  @override
  String get wordSizeLabel => 'Cỡ chữ của từ';

  @override
  String get wordSizeSmall => 'Nhỏ';

  @override
  String get wordSizeMedium => 'Vừa';

  @override
  String get wordSizeLarge => 'Lớn';

  @override
  String get lockScreenCoverLabel => 'Hiện ảnh bìa chữ lớn trên màn hình khóa';

  @override
  String get lockScreenCoverDesc =>
      'Khi tắt, màn hình khóa chỉ hiện thẻ chữ nhỏ thông thường';

  @override
  String get appearanceLabel => 'Giao diện';

  @override
  String get appearanceSystem => 'Theo hệ thống';

  @override
  String get appearanceLight => 'Sáng';

  @override
  String get appearanceDark => 'Tối';

  @override
  String notifLastHeard(String word) {
    return 'Lần trước nghe đến: $word';
  }

  @override
  String notifStarredLeft(int count) {
    return 'Còn $count từ chưa thuộc';
  }

  @override
  String get notifActionStart => '▶ Bắt đầu đọc';

  @override
  String get notifActionSnooze => 'Nhắc lại sau';
}
