// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Kosakata Inggris Sambil Dengar';

  @override
  String get statsTooltip => 'Statistik belajar';

  @override
  String get moreTooltip => 'Lainnya';

  @override
  String get menuPremium => 'Upgrade ke Premium';

  @override
  String get menuVoicePreview => 'Pratinjau suara';

  @override
  String get menuImport => 'Impor materi sendiri';

  @override
  String get menuAbout => 'Tentang aplikasi / Hak cipta';

  @override
  String wordNumberLabel(int current, int total) {
    return 'No. $current / $total';
  }

  @override
  String cycleLabel(int n) {
    return 'Putaran belajar ke-$n';
  }

  @override
  String roundProgressLabel(int heard, int total, int percent) {
    return 'Progres putaran ini: $heard / $total ($percent%)';
  }

  @override
  String get playButtonStart => 'Mulai membaca';

  @override
  String get playButtonPause => 'Jeda membaca';

  @override
  String get starButton => 'Tambahkan ke kata belum hafal';

  @override
  String get navPrevious => 'Sebelumnya';

  @override
  String get navReplay => 'Ulangi';

  @override
  String get navNext => 'Berikutnya';

  @override
  String get statsTitle => 'Statistik belajar';

  @override
  String get todayLearnedLabel => 'Dipelajari hari ini';

  @override
  String get totalLearnedLabel => 'Total dipelajari';

  @override
  String get unitCount => 'kata';

  @override
  String get datasetProgressHeader => 'Progres tiap materi';

  @override
  String itemsCountLabel(int learned, int total) {
    return '$learned / $total item';
  }

  @override
  String get dailyReminderHeader => 'Pengingat belajar harian';

  @override
  String get enableDailyReminder => 'Aktifkan pengingat harian';

  @override
  String get reminderTimeLabel => 'Waktu pengingat';

  @override
  String reminderScheduledMessage(String time) {
    return 'Pengingat dijadwalkan pukul $time';
  }

  @override
  String get reminderFailedMessage =>
      'Gagal menjadwalkan. Periksa pengaturan optimasi baterai atau aktifkan ulang pengingat';

  @override
  String get batteryOptButtonLabel =>
      'Pengingat tidak muncul tepat waktu? Ketuk untuk menonaktifkan batasan optimasi baterai';

  @override
  String get batteryOptSnackbar =>
      'Pastikan \"Strategi hemat baterai\" diatur ke \"Tanpa batasan\"';

  @override
  String get miuiAutostartButtonLabel =>
      'Ponsel Xiaomi/Redmi: aktifkan juga \"Mulai otomatis\"';

  @override
  String get miuiAutostartSnackbar =>
      'Di ponsel Xiaomi, cari aplikasi ini di daftar lalu aktifkan mulai otomatis (ponsel merek lain dapat mengabaikan tombol ini)';

  @override
  String get settingsTitle => 'Pengaturan pemutaran';

  @override
  String starredCountLabel(int n) {
    return '$n item ditandai';
  }

  @override
  String get speakOnManualNavigateLabel => 'Bacakan saat berpindah kata manual';

  @override
  String get showTranslationLabel => 'Tampilkan terjemahan';

  @override
  String intervalSecondsLabel(String seconds) {
    return 'Jeda antar kata: $seconds detik';
  }

  @override
  String speechRateLabel(String rate) {
    return 'Kecepatan membaca: ${rate}x';
  }

  @override
  String get scopeModeLabel => 'Cakupan / mode pemutaran';

  @override
  String get scopeAllRandom => 'Semua daftar (acak)';

  @override
  String get scopeAllSequential => 'Semua daftar (berurutan)';

  @override
  String get scopeStarredRandom => 'Hanya yang belum hafal (acak)';

  @override
  String get scopeStarredSequential => 'Hanya yang belum hafal (berurutan)';

  @override
  String get readModeLabel => 'Mode membaca';

  @override
  String get readModeBilingual => 'Dwibahasa (Inggris + terjemahan)';

  @override
  String get readModeEnglishOnly => 'Hanya bahasa Inggris';

  @override
  String get repeatCountLabel => 'Jumlah pengulangan bahasa Inggris';

  @override
  String get repeatOnce => 'Baca 1 kali';

  @override
  String get repeatTwice => 'Baca 2 kali (disarankan)';

  @override
  String get repeatThrice => 'Baca 3 kali';

  @override
  String get commonCancel => 'Batal';

  @override
  String get commonDelete => 'Hapus';

  @override
  String get voicePreviewIntro =>
      'Berikut daftar suara bahasa Inggris yang tersedia di ponsel Anda. Ketuk ikon putar untuk mendengarkan. Saat membaca, aplikasi selalu memakai suara bawaan sistem (dipilih otomatis sesuai bahasa); layar ini hanya untuk mencoba suara yang ada.';

  @override
  String get voicePreviewNoVoices =>
      'Tidak ada suara yang tersedia. Pastikan paket suara bahasa Inggris sudah terpasang di ponsel.';

  @override
  String get voicePreviewUnknownVoice => 'Suara tidak dikenal';

  @override
  String get paywallPurchaseSuccess =>
      'Berlangganan berhasil! Semua konten terbuka dan iklan dihapus.';

  @override
  String get paywallPurchaseFailed =>
      'Pembelian belum selesai, silakan coba lagi nanti.';

  @override
  String get paywallRestoreSuccess => 'Langganan Premium berhasil dipulihkan!';

  @override
  String get paywallRestoreNotFound =>
      'Tidak ditemukan riwayat pembelian untuk dipulihkan.';

  @override
  String get paywallAlreadyPremium => 'Anda sudah menjadi pelanggan Premium 🎉';

  @override
  String get paywallHeadline => 'Buka semua materi belajar';

  @override
  String get paywallBenefitAllContent => 'Keempat materi terbuka 100%';

  @override
  String get paywallBenefitNoAds => 'Tanpa iklan sama sekali';

  @override
  String get paywallBenefitBackground =>
      'Putar di latar belakang, tampil di layar kunci';

  @override
  String get paywallRestoreButton => 'Pulihkan pembelian sebelumnya';

  @override
  String get paywallNoPackages =>
      'Saat ini belum ada paket langganan, silakan coba lagi nanti.';

  @override
  String get paywallPlanMonthly => 'Paket bulanan';

  @override
  String get paywallPlanAnnual => 'Paket tahunan';

  @override
  String get paywallTermsNote =>
      'Langganan diperpanjang otomatis. Anda dapat membatalkan kapan saja di menu “Pembayaran & langganan” Google Play. Setelah dibatalkan, Premium tetap dapat digunakan hingga akhir periode berjalan, lalu otomatis kembali ke versi gratis.';

  @override
  String get paywallManageSubscription => 'Kelola / batalkan langganan';

  @override
  String get unlockRewardSnackbar => '20 item tambahan telah dibuka!';

  @override
  String unlockFreeProgress(int unlocked, int total) {
    return 'Versi gratis: $unlocked / $total item terbuka';
  }

  @override
  String get unlockAdLoading => 'Menyiapkan iklan…';

  @override
  String get unlockWatchAd => 'Tonton iklan +20';

  @override
  String get importIntro =>
      'Anda dapat mengimpor kosakata, frasa, atau contoh kalimat sendiri (misalnya dari buku Anda). Setelah diimpor, materi dapat dipilih dan dibacakan seperti materi bawaan.';

  @override
  String get importFormatTitle => 'Format impor (CSV, dengan baris judul)';

  @override
  String get importSampleApple => 'apel';

  @override
  String get importSampleGiveUp => 'menyerah';

  @override
  String get importSampleHowAreYou => 'Bagaimana harimu?';

  @override
  String get importFormatHint =>
      'Kolom pertama berisi bahasa Inggris (kata, frasa, atau kalimat lengkap), kolom kedua berisi terjemahannya. Simpan sebagai file CSV lalu impor. Bahasa selain Inggris juga bisa diimpor, cukup pilih bahasa kolom pertama di bawah.';

  @override
  String get importGetTemplate => 'Unduh file templat';

  @override
  String importTemplateSaved(String path) {
    return 'Templat disimpan di folder sementara: $path';
  }

  @override
  String get importNameLabel => 'Nama materi';

  @override
  String get importNameHint => 'Contoh: Kalimat inti TOEIC';

  @override
  String get importNameRequired =>
      'Silakan beri nama materi ini terlebih dahulu';

  @override
  String get importTranslationLangLabel => 'Kolom terjemahan dalam bahasa apa?';

  @override
  String get importLangZh => 'Bahasa Mandarin';

  @override
  String get importLangJa => 'Bahasa Jepang';

  @override
  String get importLangKo => 'Bahasa Korea';

  @override
  String get importLangVi => 'Bahasa Vietnam';

  @override
  String get importLangEn => 'Bahasa Inggris';

  @override
  String get importButton => 'Pilih file CSV dan impor';

  @override
  String get importingInProgress => 'Mengimpor…';

  @override
  String importDone(int count) {
    return 'Impor selesai! Total $count item';
  }

  @override
  String importDoneWithSkipped(int count, int skipped) {
    return 'Impor selesai! Total $count item ($skipped baris kosong dilewati)';
  }

  @override
  String importFailedWithReason(String reason) {
    return 'Impor gagal: $reason';
  }

  @override
  String get importFailedGeneric =>
      'Impor gagal, periksa apakah format file sudah benar';

  @override
  String get importErrorEncoding =>
      'File tidak menggunakan encoding UTF-8 sehingga tidak dapat dibaca. Saat “Simpan sebagai” di Excel, pilih “CSV UTF-8 (Dipisahkan koma)”, atau simpan ulang dengan encoding UTF-8 menggunakan editor teks.';

  @override
  String get importErrorParse =>
      'Gagal membaca CSV, pastikan formatnya dipisahkan dengan koma standar.';

  @override
  String get importErrorEmpty => 'File kosong, periksa isinya.';

  @override
  String get importErrorNoRows =>
      'Tidak ditemukan baris data yang valid, periksa formatnya.';

  @override
  String get importDeleteTitle => 'Hapus materi sendiri';

  @override
  String importDeleteConfirm(String name) {
    return 'Yakin ingin menghapus “$name”? Tindakan ini tidak dapat dibatalkan.';
  }

  @override
  String get importedListHeader => 'Materi yang sudah diimpor';

  @override
  String importItemCount(int n) {
    return '$n item';
  }

  @override
  String get aboutFeedbackButton => 'Kirim masukan / Laporkan masalah';

  @override
  String get aboutAttributionIntro =>
      'Data kosakata dan frasa dalam aplikasi ini berasal dari hasil penelitian akademik terbuka berikut. Dengan hormat kami sampaikan terima kasih dan mencantumkan sumbernya:';

  @override
  String get aboutNgslTitle => 'NGSL 2809 (Kosakata inti)';

  @override
  String get aboutSpokenTitle => 'NGSL-Spoken 720 (Kata umum lisan)';

  @override
  String get aboutPhaveTitle => 'PhaVE List (Kata kerja frasal)';

  @override
  String get aboutPhraseTitle => 'PHRASE List (Frasa berfrekuensi tinggi)';

  @override
  String get aboutLicenseCcBySa =>
      'Dilisensikan di bawah Creative Commons Atribusi-BerbagiSerupa 4.0 Internasional (CC BY-SA 4.0).';

  @override
  String get aboutLicenseCcBy =>
      'Dilisensikan di bawah Creative Commons Atribusi 4.0 Internasional (CC BY 4.0).';

  @override
  String get aboutPhraseRights =>
      'Hak cipta milik penulis asli; aplikasi ini menggunakannya untuk tujuan pendidikan sesuai izin.';

  @override
  String aboutSourceLabel(String name) {
    return 'Karya asli: $name';
  }

  @override
  String aboutLicenseLabel(String name) {
    return 'Lisensi: $name';
  }

  @override
  String get aboutTtsNote =>
      'Suara pembacaan disediakan oleh mesin teks-ke-suara (TTS) bawaan perangkat.';

  @override
  String get feedbackTitle => 'Masukan';

  @override
  String get feedbackCategoryLabel => 'Jenis';

  @override
  String get feedbackCategoryBug => 'Laporkan masalah';

  @override
  String get feedbackCategorySuggestion => 'Usulan fitur';

  @override
  String get feedbackCategoryOther => 'Lainnya';

  @override
  String get feedbackMessageLabel => 'Isi';

  @override
  String get feedbackMessageHint =>
      'Ceritakan masalah yang Anda alami atau fitur yang Anda inginkan…';

  @override
  String get feedbackEmailLabel => 'Email kontak (opsional)';

  @override
  String get feedbackEmailHint =>
      'Tinggalkan email jika ingin menerima balasan';

  @override
  String get feedbackSubmit => 'Kirim masukan';

  @override
  String get feedbackEmpty => 'Silakan isi masukan terlebih dahulu';

  @override
  String get feedbackThanks =>
      'Terima kasih atas masukan Anda, kami akan segera meninjaunya!';

  @override
  String get feedbackFailed =>
      'Gagal mengirim, periksa koneksi internet lalu coba lagi';

  @override
  String get statsDescNgsl =>
      'Daftar kosakata inti bahasa Inggris berdasarkan penelitian frekuensi terbuka. Menguasai 2.809 kata ini memungkinkan Anda memahami sekitar 92% teks bahasa Inggris sehari-hari (Sumber: New General Service List Project).';

  @override
  String get statsDescSpoken =>
      '720 kata berfrekuensi tinggi yang dipilih dari percakapan sehari-hari, untuk mempercepat respons saat mendengar dan berbicara. Melengkapi daftar inti NGSL dengan kata-kata yang sering dipakai secara lisan tetapi jarang muncul dalam tulisan.';

  @override
  String get statsDescPhrase =>
      '506 kolokasi dan frasa tetap yang benar-benar sering dipakai penutur asli (misalnya \"in order to\", \"as well as\"). Bukan kata tunggal, melainkan frasa yang dihafal sebagai satu kesatuan, membantu Anda berbicara bahasa Inggris dengan lebih alami.';

  @override
  String get statsDescPhave =>
      'Berisi 150 kata kerja frasal yang paling umum (misalnya \"look after\", \"give up\"). Kombinasi kata kerja + preposisi dikenal sebagai bagian tersulit bagi pelajar; mengulang 150 frasa ini secara fokus mencakup sebagian besar kata kerja frasal yang ditemui sehari-hari.';

  @override
  String get summaryReadBilingual => 'Dwibahasa';

  @override
  String get summaryReadEnglishOnly => 'Hanya Inggris';

  @override
  String settingsSummaryLine(String mode, int count, String rate) {
    return '$mode · $count kali · ${rate}x';
  }

  @override
  String get notifChannelName => 'Pengingat belajar';

  @override
  String get notifChannelDesc =>
      'Notifikasi pengingat belajar bahasa Inggris harian';

  @override
  String get notifDailyTitle => 'Waktunya mengulang bahasa Inggris!';

  @override
  String get notifDailyBody =>
      'Yuk dengarkan beberapa kata untuk memperkuat pelajaran hari ini';

  @override
  String get notifInactivityTitle => 'Lama tak jumpa 👋';

  @override
  String get notifInactivityBody =>
      'Sudah beberapa hari Anda tidak belajar. Dengarkan beberapa kata agar ingatan tetap segar';

  @override
  String get audioChannelName => 'Pembacaan belajar bahasa Inggris';

  @override
  String get importLangId => 'Bahasa Indonesia';

  @override
  String get datasetNameNgsl => 'NGSL 2809 kosakata inti';

  @override
  String get datasetShortNgsl => 'NGSL 2809 kata';

  @override
  String get datasetNameSpoken => 'NGSL 720 kata lisan';

  @override
  String get datasetShortSpoken => 'Lisan 720';

  @override
  String get datasetNamePhrase => 'PHRASE List frasa umum (506)';

  @override
  String get datasetShortPhrase => 'Frasa 506';

  @override
  String get datasetNamePhave => 'PhaVE List kata kerja frasal (150)';

  @override
  String get datasetShortPhave => 'Frasal 150';

  @override
  String get updateDownloadedMessage => 'Versi baru selesai diunduh';

  @override
  String get updateRestartButton => 'Mulai ulang';

  @override
  String get importLangEs => 'Bahasa Spanyol';

  @override
  String get importLangPt => 'Bahasa Portugis';

  @override
  String get menuIntro => 'Pengenalan fitur';

  @override
  String get introSkip => 'Lewati';

  @override
  String get introNext => 'Lanjut';

  @override
  String get introStart => 'Mulai belajar';

  @override
  String get introTitle1 => 'Belajar bahasa Inggris dengan prinsip 20/80';

  @override
  String get introBody1 =>
      'Kuasai 2.809 kata inti NGSL dan kamu bisa memahami sekitar 92% teks bahasa Inggris sehari-hari. Tidak perlu menghafal kata langka, fokuskan waktumu pada kata yang benar-benar dipakai.';

  @override
  String get introTitle2 => 'Dibuat khusus untukmu';

  @override
  String get introBody2 =>
      'Sudah berkali-kali belajar bahasa Inggris tapi selalu berhenti di tengah jalan, daya ingat tidak seperti dulu, atau tidak punya lingkungan berbahasa Inggris? Metode ini dirancang untukmu, agar kamu kembali percaya diri belajar bahasa Inggris.';

  @override
  String get introTitle3 =>
      'Dengarkan di latar belakang, manfaatkan waktu luang';

  @override
  String get introBody3 =>
      'Dengarkan saat perjalanan, jalan santai, mengerjakan pekerjaan rumah, atau berolahraga. Saat layar dikunci atau pindah ke aplikasi lain, pembacaan tetap berlanjut tanpa harus melihat layar.';

  @override
  String get introTitle4 => 'Pembacaan dua bahasa + daftar kata belum hafal';

  @override
  String get introBody4 =>
      'Bahasa Inggris dibacakan lebih dulu, lalu artinya dalam bahasa Indonesia, jadi kamu paham tanpa melihat layar. Tandai kata yang belum hafal dengan bintang, lalu gunakan mode \"Hanya yang belum hafal\" untuk mendengarkannya berulang kali sampai benar-benar ingat.';

  @override
  String get introTitle5 => 'Impor materi sendiri – 14 bahasa';

  @override
  String get introBody5 =>
      'Kosakata buku pelajaran, ungkapan kerja, materi ujian, dan lainnya bisa diimpor sebagai file CSV, lalu diputar di latar belakang dan ditandai seperti biasa. Bukan hanya bahasa Inggris: Jepang, Korea, Mandarin, Prancis, Jerman, Spanyol, Thai, Arab, dan lainnya—total 14 bahasa bisa dibacakan, dan terjemahannya bisa memakai bahasa yang kamu kuasai. (Beberapa bahasa perlu mengunduh data suara di ponsel terlebih dahulu)';

  @override
  String get introTitle6 => '4 materi akademis, mulai gratis';

  @override
  String get introBody6 =>
      'Kata inti NGSL 2809, kata lisan 720, frasa umum 506, dan phrasal verb 150, semuanya dari riset akademis terbuka. Setiap materi punya konten gratis, jadi coba dulu sebelum memutuskan.';

  @override
  String get importWordLangLabel =>
      'Bahasa apa di kolom pertama? (untuk suara pembacaan)';

  @override
  String importVoiceMissing(String language) {
    return 'Ponsel belum punya suara pembacaan \"$language\", jadi tidak bisa dibacakan. Pasang paket suaranya di \"Setelan → Text-to-speech\".';
  }

  @override
  String get menuShare => 'Bagikan ke teman';

  @override
  String get shareMessage =>
      'Coba aplikasi \"Kosakata Inggris Sambil Dengar\": belajar dengan prinsip 20/80, fokus pada kosakata inti yang mencakup 92% bahasa Inggris sehari-hari, dibacakan di latar belakang saat perjalanan, jalan kaki, atau mengerjakan pekerjaan rumah, dengan dua bahasa. Unduh gratis:';

  @override
  String get menuAdPrivacy => 'Pengaturan privasi iklan';

  @override
  String get switchDatasetButton => 'Ganti materi';

  @override
  String get unlockMoreButton => 'Buka lagi';

  @override
  String get playShortStart => 'Mulai baca';

  @override
  String get playShortPause => 'Jeda';

  @override
  String cycleShort(int n) {
    return 'Putaran $n';
  }

  @override
  String get wordSizeLabel => 'Ukuran kata';

  @override
  String get wordSizeSmall => 'Kecil';

  @override
  String get wordSizeMedium => 'Sedang';

  @override
  String get wordSizeLarge => 'Besar';

  @override
  String get lockScreenCoverLabel =>
      'Tampilkan sampul huruf besar di layar kunci';

  @override
  String get lockScreenCoverDesc =>
      'Jika dimatikan, layar kunci hanya menampilkan kartu huruf kecil biasa';

  @override
  String get appearanceLabel => 'Tampilan';

  @override
  String get appearanceSystem => 'Ikuti sistem';

  @override
  String get appearanceLight => 'Terang';

  @override
  String get appearanceDark => 'Gelap';

  @override
  String notifLastHeard(String word) {
    return 'Terakhir didengar: $word';
  }

  @override
  String notifStarredLeft(int count) {
    return 'Masih ada $count kata belum hafal';
  }

  @override
  String get notifActionStart => '▶ Mulai baca';

  @override
  String get notifActionSnooze => 'Ingatkan nanti';
}
