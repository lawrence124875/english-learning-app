// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'スマートリスニング・クルーズ';

  @override
  String get statsTooltip => '学習統計';

  @override
  String get moreTooltip => 'その他';

  @override
  String get menuPremium => 'Premiumにアップグレード';

  @override
  String get menuVoicePreview => '音声プレビュー';

  @override
  String get menuImport => 'カスタム教材をインポート';

  @override
  String get menuAbout => 'このアプリについて / 著作権表示';

  @override
  String wordNumberLabel(int current, int total) {
    return 'No. $current / $total';
  }

  @override
  String cycleLabel(int n) {
    return '$n周目の学習';
  }

  @override
  String roundProgressLabel(int heard, int total, int percent) {
    return '今回の進捗：$heard / $total（$percent%）';
  }

  @override
  String get playButtonStart => '巡航読み上げ開始';

  @override
  String get playButtonPause => '巡航読み上げ一時停止';

  @override
  String get starButton => '苦手な単語に追加';

  @override
  String get navPrevious => '前へ';

  @override
  String get navReplay => 'もう一度';

  @override
  String get navNext => '次へ';

  @override
  String get statsTitle => '学習統計';

  @override
  String get todayLearnedLabel => '今日の学習数';

  @override
  String get totalLearnedLabel => '累計学習数';

  @override
  String get unitCount => '個';

  @override
  String get datasetProgressHeader => '教材ごとの学習進捗';

  @override
  String itemsCountLabel(int learned, int total) {
    return '$learned / $total 項目';
  }

  @override
  String get dailyReminderHeader => '毎日の復習リマインダー';

  @override
  String get enableDailyReminder => '毎日のリマインダーをオン';

  @override
  String get reminderTimeLabel => 'リマインダー時刻';

  @override
  String reminderScheduledMessage(String time) {
    return '$time にリマインダーを設定しました';
  }

  @override
  String get reminderFailedMessage =>
      '設定に失敗しました。バッテリー最適化設定を確認するか、リマインダーを再度オンにしてください';

  @override
  String get batteryOptButtonLabel => 'リマインダーが表示されない場合はこちら（バッテリー最適化解除）';

  @override
  String get batteryOptSnackbar => '「省電力ポリシー」で「制限なし」を選択してください';

  @override
  String get miuiAutostartButtonLabel => 'Xiaomi/Redmi端末は「自動起動」も有効にしてください';

  @override
  String get miuiAutostartSnackbar =>
      'Xiaomi端末はリストから本アプリを探して自動起動を有効にしてください（他社製端末はこのボタンを無視してください）';

  @override
  String get settingsTitle => '再生設定';

  @override
  String starredCountLabel(int n) {
    return '$n件をマークしました';
  }

  @override
  String get speakOnManualNavigateLabel => '手動切り替え時に読み上げる';

  @override
  String get showTranslationLabel => '翻訳を表示';

  @override
  String intervalSecondsLabel(String seconds) {
    return '単語の間隔：$seconds秒';
  }

  @override
  String speechRateLabel(String rate) {
    return '読み上げ速度：${rate}x';
  }

  @override
  String get scopeModeLabel => '再生範囲 / モード';

  @override
  String get scopeAllRandom => '全リスト（ランダム再生）';

  @override
  String get scopeAllSequential => '全リスト（順番に再生）';

  @override
  String get scopeStarredRandom => '苦手な単語のみ（ランダム再生）';

  @override
  String get scopeStarredSequential => '苦手な単語のみ（順番に再生）';

  @override
  String get readModeLabel => '読み上げモード';

  @override
  String get readModeBilingual => 'バイリンガル読み上げ（英語＋翻訳）';

  @override
  String get readModeEnglishOnly => '英語のみ';

  @override
  String get repeatCountLabel => '英語の繰り返し回数';

  @override
  String get repeatOnce => '1回読む';

  @override
  String get repeatTwice => '2回読む（推奨）';

  @override
  String get repeatThrice => '3回読む';

  @override
  String get commonCancel => 'キャンセル';

  @override
  String get commonDelete => '削除';

  @override
  String get voicePreviewIntro =>
      'お使いの端末で利用できる英語音声の一覧です。再生アイコンをタップすると試聴できます。実際の読み上げでは、システムの既定音声（言語に応じて自動選択）を使用します。ここでは端末にどんな音声があるかを確認できます。';

  @override
  String get voicePreviewNoVoices =>
      '利用できる音声が見つかりません。端末に英語の音声データがインストールされているか確認してください。';

  @override
  String get voicePreviewUnknownVoice => '不明な音声';

  @override
  String get paywallPurchaseSuccess => '購読が完了しました！すべてのコンテンツが解放され、広告が非表示になりました。';

  @override
  String get paywallPurchaseFailed => '購入が完了しませんでした。しばらくしてからもう一度お試しください。';

  @override
  String get paywallRestoreSuccess => 'Premium の購読を復元しました！';

  @override
  String get paywallRestoreNotFound => '復元できる購入履歴が見つかりません。';

  @override
  String get paywallAlreadyPremium => 'すでに Premium 会員です 🎉';

  @override
  String get paywallHeadline => 'すべての学習コンテンツを解放';

  @override
  String get paywallBenefitAllContent => '4つの教材をすべて100%利用可能';

  @override
  String get paywallBenefitNoAds => '広告を完全に非表示';

  @override
  String get paywallBenefitBackground => 'バックグラウンド再生・ロック画面表示';

  @override
  String get paywallRestoreButton => '以前の購入を復元';

  @override
  String get paywallNoPackages => '現在利用できるプランがありません。しばらくしてからお試しください。';

  @override
  String get paywallPlanMonthly => '月額プラン';

  @override
  String get paywallPlanAnnual => '年額プラン';

  @override
  String get paywallTermsNote =>
      '購読は自動更新されます。Google Play の「お支払いと定期購入」からいつでも解約できます。解約後も現在の期間が終わるまで Premium をご利用いただけ、その後は自動的に無料版に戻ります。';

  @override
  String get paywallManageSubscription => '購読の管理・解約';

  @override
  String get unlockRewardSnackbar => '20項目を追加で解放しました！';

  @override
  String unlockFreeProgress(int unlocked, int total) {
    return '無料版：$unlocked / $total 項目を解放済み';
  }

  @override
  String get unlockAdLoading => '広告を準備中…';

  @override
  String get unlockWatchAd => '広告を見て +20';

  @override
  String get importIntro =>
      'ご自身で用意した単語・フレーズ・例文（手持ちの本の内容など）をインポートできます。インポート後は内蔵教材と同じように切り替えて読み上げられます。';

  @override
  String get importFormatTitle => 'インポート形式（CSV、ヘッダー行あり）';

  @override
  String get importSampleApple => 'りんご';

  @override
  String get importSampleGiveUp => '諦める';

  @override
  String get importSampleHowAreYou => '今日の調子はどう？';

  @override
  String get importFormatHint =>
      '1列目に英語（単語・フレーズ・例文のいずれも可）、2列目に対応する訳を入れ、CSV ファイルとして保存すればインポートできます。英語以外の言語もインポートできます。下で1列目の言語を選んでください。';

  @override
  String get importGetTemplate => 'テンプレートを取得';

  @override
  String importTemplateSaved(String path) {
    return 'テンプレートを一時フォルダに保存しました：$path';
  }

  @override
  String get importNameLabel => 'この教材の名前';

  @override
  String get importNameHint => '例：TOEIC頻出例文';

  @override
  String get importNameRequired => '先に教材の名前を入力してください';

  @override
  String get importTranslationLangLabel => '訳の列は何語ですか？';

  @override
  String get importLangZh => '中国語';

  @override
  String get importLangJa => '日本語';

  @override
  String get importLangKo => '韓国語';

  @override
  String get importLangVi => 'ベトナム語';

  @override
  String get importLangEn => '英語';

  @override
  String get importButton => 'CSVファイルを選んでインポート';

  @override
  String get importingInProgress => 'インポート中…';

  @override
  String importDone(int count) {
    return 'インポート完了！全$count件';
  }

  @override
  String importDoneWithSkipped(int count, int skipped) {
    return 'インポート完了！全$count件（空白行 $skipped 件をスキップ）';
  }

  @override
  String importFailedWithReason(String reason) {
    return 'インポート失敗：$reason';
  }

  @override
  String get importFailedGeneric => 'インポートに失敗しました。ファイル形式を確認してください';

  @override
  String get importErrorEncoding =>
      'ファイルの文字コードが UTF-8 ではないため読み込めません。Excel の「名前を付けて保存」で「CSV UTF-8（コンマ区切り）」を選ぶか、テキストエディタで UTF-8 として保存し直してください。';

  @override
  String get importErrorParse => 'CSV の解析に失敗しました。標準的なコンマ区切り形式か確認してください。';

  @override
  String get importErrorEmpty => 'ファイルが空です。内容を確認してください。';

  @override
  String get importErrorNoRows => '有効なデータ行が見つかりませんでした。形式を確認してください。';

  @override
  String get importDeleteTitle => 'カスタム教材を削除';

  @override
  String importDeleteConfirm(String name) {
    return '「$name」を削除しますか？この操作は元に戻せません。';
  }

  @override
  String get importedListHeader => 'インポート済みのカスタム教材';

  @override
  String importItemCount(int n) {
    return '$n 項目';
  }

  @override
  String get aboutFeedbackButton => 'ご意見・不具合の報告';

  @override
  String get aboutAttributionIntro =>
      '本アプリの単語・フレーズデータは、以下の公開学術研究の成果を利用しています。ここに感謝の意を表し、出典を明記します：';

  @override
  String get aboutNgslTitle => 'NGSL 2809（コア単語）';

  @override
  String get aboutSpokenTitle => 'NGSL-Spoken 720（話し言葉の頻出語）';

  @override
  String get aboutPhaveTitle => 'PhaVE List（句動詞）';

  @override
  String get aboutPhraseTitle => 'PHRASE List（高頻度フレーズ）';

  @override
  String get aboutLicenseCcBySa =>
      'クリエイティブ・コモンズ「表示-継承 4.0 国際」ライセンス（CC BY-SA 4.0）の下で提供されています。';

  @override
  String get aboutLicenseCcBy =>
      'クリエイティブ・コモンズ「表示 4.0 国際」ライセンス（CC BY 4.0）の下で提供されています。';

  @override
  String get aboutPhraseRights => '著作権は原著者に帰属します。本アプリは許諾の範囲内で教育目的に使用しています。';

  @override
  String aboutSourceLabel(String name) {
    return '原著作物：$name';
  }

  @override
  String aboutLicenseLabel(String name) {
    return 'ライセンス：$name';
  }

  @override
  String get aboutTtsNote => '読み上げ音声は端末に内蔵された音声合成（TTS）エンジンによるものです。';

  @override
  String get feedbackTitle => 'ご意見・ご要望';

  @override
  String get feedbackCategoryLabel => '種類';

  @override
  String get feedbackCategoryBug => '不具合の報告';

  @override
  String get feedbackCategorySuggestion => '機能の提案';

  @override
  String get feedbackCategoryOther => 'その他';

  @override
  String get feedbackMessageLabel => '内容';

  @override
  String get feedbackMessageHint => '困ったことや、追加してほしい機能を教えてください…';

  @override
  String get feedbackEmailLabel => '連絡先メール（任意）';

  @override
  String get feedbackEmailHint => '返信をご希望の場合はメールアドレスをご入力ください';

  @override
  String get feedbackSubmit => '送信する';

  @override
  String get feedbackEmpty => '内容を入力してから送信してください';

  @override
  String get feedbackThanks => 'ご意見ありがとうございます。できるだけ早く確認します！';

  @override
  String get feedbackFailed => '送信に失敗しました。ネットワーク接続を確認して再度お試しください';

  @override
  String get statsDescNgsl =>
      '公開された頻度研究に基づく英語のコア単語リストです。この 2,809 語をマスターすれば、一般的な日常英語テキストの約92%を理解できるとされています（出典：New General Service List Project）。';

  @override
  String get statsDescSpoken =>
      '日常会話から選ばれた 720 の高頻度語です。「聞く」「話す」場面での反応速度を高めるためのリストで、NGSL コア単語を補い、書き言葉では少ないものの話し言葉でよく使われる語をカバーします。';

  @override
  String get statsDescPhrase =>
      'ネイティブが実際によく使う 506 のコロケーション・定型表現（例：\"in order to\"、\"as well as\"）です。単語ではなく「ひとまとまりで覚える」フレーズで、より自然な英語を話す助けになります。';

  @override
  String get statsDescPhave =>
      '最もよく使われる 150 の句動詞（例：\"look after\"、\"give up\"）を収録しています。「動詞＋前置詞」の組み合わせは学習者が最も苦労する分野とされ、この 150 語を集中して復習すれば日常で出会う句動詞の大部分をカバーできます。';

  @override
  String get summaryReadBilingual => '英＋訳';

  @override
  String get summaryReadEnglishOnly => '英語のみ';

  @override
  String settingsSummaryLine(String mode, int count, String rate) {
    return '$mode・$count回・${rate}x';
  }

  @override
  String get notifChannelName => '復習リマインダー';

  @override
  String get notifChannelDesc => '毎日の英語復習リマインダー';

  @override
  String get notifDailyTitle => '英語の復習の時間です！';

  @override
  String get notifDailyBody => '単語をいくつか聞いて、今日の学習内容を定着させましょう';

  @override
  String get notifInactivityTitle => 'お久しぶりです 👋';

  @override
  String get notifInactivityBody => '数日間復習していません。単語を少し聞いて、記憶を呼び戻しましょう';

  @override
  String get audioChannelName => '英語学習の読み上げ';

  @override
  String get importLangId => 'インドネシア語';

  @override
  String get datasetNameNgsl => 'NGSL 2809 コア単語';

  @override
  String get datasetShortNgsl => 'NGSL 2809語';

  @override
  String get datasetNameSpoken => 'NGSL 話し言葉 720語';

  @override
  String get datasetShortSpoken => '話し言葉 720';

  @override
  String get datasetNamePhrase => 'PHRASE List 高頻度フレーズ (506)';

  @override
  String get datasetShortPhrase => 'フレーズ 506';

  @override
  String get datasetNamePhave => 'PhaVE List 句動詞 (150)';

  @override
  String get datasetShortPhave => '句動詞 150';

  @override
  String get updateDownloadedMessage => '新しいバージョンのダウンロードが完了しました';

  @override
  String get updateRestartButton => '再起動';

  @override
  String get importLangEs => 'スペイン語';

  @override
  String get importLangPt => 'ポルトガル語';

  @override
  String get menuIntro => '機能紹介';

  @override
  String get introSkip => 'スキップ';

  @override
  String get introNext => '次へ';

  @override
  String get introStart => '学習を始める';

  @override
  String get introTitle1 => '20/80の法則で英語を学ぶ';

  @override
  String get introBody1 =>
      'NGSLの核心単語2,809語を身につければ、日常的な英文の約92%が理解できます。めったに使わない単語は覚えず、本当に役立つ単語に時間を集中させます。';

  @override
  String get introTitle2 => 'こんな方のために';

  @override
  String get introBody2 =>
      '何度も英語を始めては挫折してきた方、年齢とともに記憶力の衰えを感じる方、身の回りに英語環境がない方のために作りました。英語を学ぶ自信をもう一度取り戻しましょう。';

  @override
  String get introTitle3 => '聞き流しで、すきま時間を学習時間に';

  @override
  String get introBody3 =>
      '通勤、散歩、家事、運動の最中でも聞けます。画面をロックしても、ほかのアプリに切り替えても読み上げは続くので、画面を見続ける必要はありません。';

  @override
  String get introTitle4 => '2か国語の読み上げ＋苦手な単語リスト';

  @override
  String get introBody4 =>
      '英語のあとに日本語の意味を読み上げるので、画面を見なくても意味がわかります。覚えていない単語は星マークを付けて、「苦手な単語のみ」モードで覚えるまで集中して繰り返し聞けます。';

  @override
  String get introTitle5 => '自分の教材をインポート：14言語に対応';

  @override
  String get introBody5 =>
      '教科書の単語、仕事の表現、試験範囲などをCSVファイルで取り込めば、同じように聞き流しや苦手登録ができます。英語だけでなく、韓国語・中国語・フランス語・ドイツ語・スペイン語・タイ語・アラビア語など14言語の読み上げに対応し、訳も使い慣れた言語を選べます。（一部の言語は端末で音声データのダウンロードが必要です）';

  @override
  String get introTitle6 => '4つの学術教材、無料で始められる';

  @override
  String get introBody6 =>
      '核心単語NGSL 2809、話し言葉の頻出語720、頻出フレーズ506、句動詞150。すべて公開された学術研究に基づいています。各教材に無料で使える内容があるので、まずは試してみてください。';

  @override
  String get importWordLangLabel => '1列目の言語は？（読み上げ音声に使います）';

  @override
  String importVoiceMissing(String language) {
    return 'この端末には「$language」の読み上げ音声がないため、読み上げできません。端末の「設定 → テキスト読み上げ」で音声データをインストールしてください。';
  }

  @override
  String get menuShare => '友だちに共有';

  @override
  String get shareMessage =>
      '英語学習アプリ「スマートリスニング・クルーズ」がおすすめです。20/80の法則で、日常英語の92%をカバーするコア単語だけを学習。通勤・散歩・家事の間にバックグラウンドで読み上げ、母語と一緒に聞けます。無料ダウンロード：';

  @override
  String get menuAdPrivacy => '広告のプライバシー設定';

  @override
  String get switchDatasetButton => '教材を切り替え';

  @override
  String get unlockMoreButton => 'もっと解放';

  @override
  String get playShortStart => '読み上げ開始';

  @override
  String get playShortPause => '一時停止';

  @override
  String cycleShort(int n) {
    return '$n周目';
  }

  @override
  String get wordSizeLabel => '単語の大きさ';

  @override
  String get wordSizeSmall => '小';

  @override
  String get wordSizeMedium => '中';

  @override
  String get wordSizeLarge => '大';

  @override
  String get lockScreenCoverLabel => 'ロック画面に大きな文字のカバーを表示';

  @override
  String get lockScreenCoverDesc => 'オフにすると、ロック画面は通常の小さな文字のカードになります';

  @override
  String get appearanceLabel => '表示モード';

  @override
  String get appearanceSystem => 'システムに合わせる';

  @override
  String get appearanceLight => 'ライト';

  @override
  String get appearanceDark => 'ダーク';

  @override
  String notifLastHeard(String word) {
    return '前回の単語：$word';
  }

  @override
  String notifStarredLeft(int count) {
    return '苦手な単語があと $count 個あります';
  }

  @override
  String get notifActionStart => '▶ 読み上げ開始';

  @override
  String get notifActionSnooze => 'あとで通知';
}
