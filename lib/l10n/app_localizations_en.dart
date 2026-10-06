// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'English Words Audio Cruise';

  @override
  String get statsTooltip => 'Learning stats';

  @override
  String get moreTooltip => 'More';

  @override
  String get menuPremium => 'Upgrade to Premium';

  @override
  String get menuVoicePreview => 'Voice preview';

  @override
  String get menuImport => 'Import your own list';

  @override
  String get menuAbout => 'About / Credits';

  @override
  String wordNumberLabel(int current, int total) {
    return 'No. $current / $total';
  }

  @override
  String cycleLabel(int n) {
    return 'Round $n';
  }

  @override
  String roundProgressLabel(int heard, int total, int percent) {
    return 'Heard this round: $heard / $total ($percent%)';
  }

  @override
  String get playButtonStart => 'Start audio cruise';

  @override
  String get playButtonPause => 'Pause audio cruise';

  @override
  String get starButton => 'Add to unfamiliar words';

  @override
  String get navPrevious => 'Previous';

  @override
  String get navReplay => 'Replay';

  @override
  String get navNext => 'Next';

  @override
  String get statsTitle => 'Learning stats';

  @override
  String get todayLearnedLabel => 'Learned today';

  @override
  String get totalLearnedLabel => 'Learned in total';

  @override
  String get unitCount => 'words';

  @override
  String get datasetProgressHeader => 'Progress by list';

  @override
  String itemsCountLabel(int learned, int total) {
    return '$learned / $total items';
  }

  @override
  String get dailyReminderHeader => 'Daily review reminder';

  @override
  String get enableDailyReminder => 'Turn on daily reminder';

  @override
  String get reminderTimeLabel => 'Reminder time';

  @override
  String reminderScheduledMessage(String time) {
    return 'Reminder set for $time';
  }

  @override
  String get reminderFailedMessage =>
      'Couldn\'t schedule the reminder. Check battery optimization or toggle the reminder again.';

  @override
  String get batteryOptButtonLabel =>
      'Reminder not on time? Tap to remove battery restrictions';

  @override
  String get batteryOptSnackbar =>
      'Please set the battery saver option to \"No restrictions\"';

  @override
  String get miuiAutostartButtonLabel =>
      'Xiaomi/Redmi phones: also turn on \"Autostart\"';

  @override
  String get miuiAutostartSnackbar =>
      'On Xiaomi phones, find this app in the list and turn on Autostart (other brands can ignore this button)';

  @override
  String get settingsTitle => 'Playback settings';

  @override
  String starredCountLabel(int n) {
    return '$n items marked';
  }

  @override
  String get speakOnManualNavigateLabel =>
      'Speak when switching words manually';

  @override
  String get showTranslationLabel => 'Show translation';

  @override
  String intervalSecondsLabel(String seconds) {
    return 'Pause between words: $seconds s';
  }

  @override
  String speechRateLabel(String rate) {
    return 'Speech rate: ${rate}x';
  }

  @override
  String get scopeModeLabel => 'Playback range / mode';

  @override
  String get scopeAllRandom => 'Full list (shuffle)';

  @override
  String get scopeAllSequential => 'Full list (in order)';

  @override
  String get scopeStarredRandom => 'Unfamiliar only (shuffle)';

  @override
  String get scopeStarredSequential => 'Unfamiliar only (in order)';

  @override
  String get readModeLabel => 'What to read aloud';

  @override
  String get readModeBilingual => 'Bilingual (word + translation)';

  @override
  String get readModeEnglishOnly => 'Word only';

  @override
  String get repeatCountLabel => 'Times to repeat each word';

  @override
  String get repeatOnce => 'Once';

  @override
  String get repeatTwice => 'Twice (recommended)';

  @override
  String get repeatThrice => '3 times';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get voicePreviewIntro =>
      'These are the English voices available on your phone. Tap the play icon to listen. During playback the app uses the system default voice for each language; this page just lets you hear what\'s installed.';

  @override
  String get voicePreviewNoVoices =>
      'No voices found. Please make sure an English voice pack is installed.';

  @override
  String get voicePreviewUnknownVoice => 'Unknown voice';

  @override
  String get paywallPurchaseSuccess =>
      'Subscribed! All content is unlocked and ads are removed.';

  @override
  String get paywallPurchaseFailed =>
      'The purchase didn\'t go through. Please try again later.';

  @override
  String get paywallRestoreSuccess => 'Premium subscription restored!';

  @override
  String get paywallRestoreNotFound => 'No purchases found to restore.';

  @override
  String get paywallAlreadyPremium => 'You\'re already a Premium subscriber 🎉';

  @override
  String get paywallHeadline => 'Unlock all learning content';

  @override
  String get paywallBenefitAllContent => 'All four word lists, 100% unlocked';

  @override
  String get paywallBenefitNoAds => 'No ads at all';

  @override
  String get paywallBenefitBackground =>
      'Background playback and lock-screen display';

  @override
  String get paywallRestoreButton => 'Restore purchases';

  @override
  String get paywallNoPackages =>
      'No subscription plans are available right now. Please try again later.';

  @override
  String get paywallPlanMonthly => 'Monthly plan';

  @override
  String get paywallPlanAnnual => 'Annual plan';

  @override
  String get paywallTermsNote =>
      'Subscriptions renew automatically. Cancel anytime in Google Play under \"Payments & subscriptions\". After canceling, Premium stays active until the end of the current period, then switches back to the free version.';

  @override
  String get paywallManageSubscription => 'Manage / cancel subscription';

  @override
  String get unlockRewardSnackbar => '20 more items unlocked!';

  @override
  String unlockFreeProgress(int unlocked, int total) {
    return 'Free version: $unlocked / $total items unlocked';
  }

  @override
  String get unlockAdLoading => 'Loading ad…';

  @override
  String get unlockWatchAd => 'Watch ad +20';

  @override
  String get importIntro =>
      'Import your own words, phrases or example sentences (for example from your textbook). Once imported, they work just like the built-in lists.';

  @override
  String get importFormatTitle => 'Import format (CSV with a header row)';

  @override
  String get importSampleApple => 'apple (fruit)';

  @override
  String get importSampleGiveUp => 'to stop trying';

  @override
  String get importSampleHowAreYou => 'a friendly greeting';

  @override
  String get importFormatHint =>
      'Put the text to learn in the first column (words, phrases or whole sentences) and its translation in the second, then save as a CSV file. Other languages work too: just choose the first-column language below.';

  @override
  String get importGetTemplate => 'Get a template file';

  @override
  String importTemplateSaved(String path) {
    return 'Template saved to the temporary folder: $path';
  }

  @override
  String get importNameLabel => 'Name of this list';

  @override
  String get importNameHint => 'e.g. TOEIC key sentences';

  @override
  String get importNameRequired => 'Please give this list a name first';

  @override
  String get importTranslationLangLabel =>
      'What language is the translation column?';

  @override
  String get importLangZh => 'Chinese';

  @override
  String get importLangJa => 'Japanese';

  @override
  String get importLangKo => 'Korean';

  @override
  String get importLangVi => 'Vietnamese';

  @override
  String get importLangEn => 'English';

  @override
  String get importButton => 'Choose a CSV file and import';

  @override
  String get importingInProgress => 'Importing…';

  @override
  String importDone(int count) {
    return 'Imported $count items!';
  }

  @override
  String importDoneWithSkipped(int count, int skipped) {
    return 'Imported $count items! ($skipped empty rows skipped)';
  }

  @override
  String importFailedWithReason(String reason) {
    return 'Import failed: $reason';
  }

  @override
  String get importFailedGeneric =>
      'Import failed. Please check the file format.';

  @override
  String get importErrorEncoding =>
      'The file isn\'t UTF-8 encoded and can\'t be read. In Excel, use \"Save As\" and choose \"CSV UTF-8 (Comma delimited)\", or save it as UTF-8 in a text editor.';

  @override
  String get importErrorParse =>
      'Couldn\'t parse the CSV. Please make sure it\'s a standard comma-separated file.';

  @override
  String get importErrorEmpty =>
      'The file is empty. Please check its contents.';

  @override
  String get importErrorNoRows =>
      'No valid rows were found. Please check the format.';

  @override
  String get importDeleteTitle => 'Delete imported list';

  @override
  String importDeleteConfirm(String name) {
    return 'Delete \"$name\"? This can\'t be undone.';
  }

  @override
  String get importedListHeader => 'Imported lists';

  @override
  String importItemCount(int n) {
    return '$n items';
  }

  @override
  String get aboutFeedbackButton => 'Feedback / report a problem';

  @override
  String get aboutAttributionIntro =>
      'The word and phrase data in this app comes from the following published academic research, with thanks and attribution:';

  @override
  String get aboutNgslTitle => 'NGSL 2809 (core vocabulary)';

  @override
  String get aboutSpokenTitle => 'NGSL-Spoken 720 (spoken vocabulary)';

  @override
  String get aboutPhaveTitle => 'PhaVE List (phrasal verbs)';

  @override
  String get aboutPhraseTitle => 'PHRASE List (high-frequency phrases)';

  @override
  String get aboutLicenseCcBySa =>
      'Licensed under Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0).';

  @override
  String get aboutLicenseCcBy =>
      'Licensed under Creative Commons Attribution 4.0 International (CC BY 4.0).';

  @override
  String get aboutPhraseRights =>
      'Copyright belongs to the original authors; used in this app for educational purposes within the scope of the license.';

  @override
  String aboutSourceLabel(String name) {
    return 'Original work: $name';
  }

  @override
  String aboutLicenseLabel(String name) {
    return 'License: $name';
  }

  @override
  String get aboutTtsNote =>
      'Speech is provided by your device\'s built-in text-to-speech engine.';

  @override
  String get feedbackTitle => 'Feedback';

  @override
  String get feedbackCategoryLabel => 'Type';

  @override
  String get feedbackCategoryBug => 'Report a problem';

  @override
  String get feedbackCategorySuggestion => 'Feature suggestion';

  @override
  String get feedbackCategoryOther => 'Other';

  @override
  String get feedbackMessageLabel => 'Message';

  @override
  String get feedbackMessageHint =>
      'Tell us about a problem you ran into, or a feature you\'d like…';

  @override
  String get feedbackEmailLabel => 'Contact email (optional)';

  @override
  String get feedbackEmailHint => 'Leave your email if you\'d like a reply';

  @override
  String get feedbackSubmit => 'Send feedback';

  @override
  String get feedbackEmpty => 'Please write something before sending';

  @override
  String get feedbackThanks =>
      'Thanks for your feedback! We\'ll look at it soon.';

  @override
  String get feedbackFailed =>
      'Couldn\'t send. Please check your connection and try again.';

  @override
  String get statsDescNgsl =>
      'A core English word list based on published frequency research. Learning all 2,809 words covers about 92% of everyday English text (source: New General Service List Project).';

  @override
  String get statsDescSpoken =>
      '720 high-frequency words picked from everyday spoken conversation, to speed up your listening and speaking. It complements the NGSL core list with words common in speech but rarer in writing.';

  @override
  String get statsDescPhrase =>
      '506 fixed expressions native speakers really use (such as \"in order to\" and \"as well as\"). Learned as whole chunks, they help you sound more natural.';

  @override
  String get statsDescPhave =>
      'The 150 most common phrasal verbs (such as \"look after\" and \"give up\"). These verb + particle combinations are famously hard for learners; these 150 cover most of the ones you\'ll meet day to day.';

  @override
  String get summaryReadBilingual => 'Bilingual';

  @override
  String get summaryReadEnglishOnly => 'Word only';

  @override
  String settingsSummaryLine(String mode, int count, String rate) {
    return '$mode · ×$count · ${rate}x';
  }

  @override
  String get notifChannelName => 'Review reminders';

  @override
  String get notifChannelDesc => 'Daily English review reminders';

  @override
  String get notifDailyTitle => 'Time to review your English!';

  @override
  String get notifDailyBody =>
      'Come back and listen to a few words to lock in what you learned today';

  @override
  String get notifInactivityTitle => 'Long time no see 👋';

  @override
  String get notifInactivityBody =>
      'It\'s been a few days since your last review. Listen to a few words so they don\'t slip away';

  @override
  String get audioChannelName => 'English audio playback';

  @override
  String get importLangId => 'Indonesian';

  @override
  String get datasetNameNgsl => 'NGSL 2809 Core Words';

  @override
  String get datasetShortNgsl => 'NGSL 2809';

  @override
  String get datasetNameSpoken => 'NGSL Spoken 720';

  @override
  String get datasetShortSpoken => 'Spoken 720';

  @override
  String get datasetNamePhrase => 'PHRASE List (506)';

  @override
  String get datasetShortPhrase => 'Phrases 506';

  @override
  String get datasetNamePhave => 'PhaVE List Phrasal Verbs (150)';

  @override
  String get datasetShortPhave => 'Phrasal verbs 150';

  @override
  String get updateDownloadedMessage => 'A new version has been downloaded';

  @override
  String get updateRestartButton => 'Restart';

  @override
  String get importLangEs => 'Spanish';

  @override
  String get importLangPt => 'Portuguese';

  @override
  String get menuIntro => 'Feature tour';

  @override
  String get introSkip => 'Skip';

  @override
  String get introNext => 'Next';

  @override
  String get introStart => 'Start learning';

  @override
  String get introTitle1 => 'Learn English with the 80/20 rule';

  @override
  String get introBody1 =>
      'Master the 2,809 NGSL core words and you can understand about 92% of everyday English. No obscure vocabulary: your time goes to words you\'ll actually use.';

  @override
  String get introTitle2 => 'Made for people like you';

  @override
  String get introBody2 =>
      'Studied English many times but never stuck with it? Memory not what it used to be? No English around you day to day? This method is designed for you, to help you get your confidence back.';

  @override
  String get introTitle3 =>
      'Background playback turns spare moments into study time';

  @override
  String get introBody3 =>
      'Listen while commuting, walking, doing chores or exercising. Lock the screen or switch apps and playback keeps going, so you don\'t have to stare at your phone.';

  @override
  String get introTitle4 => 'Bilingual audio + unfamiliar-word list';

  @override
  String get introBody4 =>
      'Hear the English word, then its meaning, without looking at the screen. Star the words you don\'t know and replay them in \"Unfamiliar only\" mode until they stick.';

  @override
  String get introTitle5 => 'Import your own material: 14 languages';

  @override
  String get introBody5 =>
      'Textbook vocabulary, work phrases, exam lists: import them as a CSV file, listen in the background, and mark the hard ones. Not just English: Japanese, Korean, Chinese, French, German, Spanish, Arabic and more—14 languages in total, with translations in the language you know best. (Some languages require downloading the voice on your phone first.)';

  @override
  String get introTitle6 => 'Four academic word lists, free to start';

  @override
  String get introBody6 =>
      'NGSL 2809 core words, Spoken 720, PHRASE List 506 and PhaVE List 150, all from published academic research. Every list has free content so you can try before deciding.';

  @override
  String get importWordLangLabel =>
      'What language is the first column? (sets the reading voice)';

  @override
  String importVoiceMissing(String language) {
    return 'Your phone has no text-to-speech voice for \"$language\", so it can\'t be read aloud. Install one in Settings → Text-to-speech.';
  }

  @override
  String get menuShare => 'Share with friends';

  @override
  String get shareMessage =>
      'Try English Words Audio Cruise: learn the core English words that cover 92% of everyday English with the 80/20 rule. It reads them aloud in the background while you commute, walk, or do chores. Free download:';

  @override
  String get menuAdPrivacy => 'Ad privacy settings';

  @override
  String get switchDatasetButton => 'Change list';

  @override
  String get unlockMoreButton => 'Unlock more';

  @override
  String get playShortStart => 'Play';

  @override
  String get playShortPause => 'Pause';

  @override
  String cycleShort(int n) {
    return 'Round $n';
  }

  @override
  String get wordSizeLabel => 'Word size';

  @override
  String get wordSizeSmall => 'Small';

  @override
  String get wordSizeMedium => 'Medium';

  @override
  String get wordSizeLarge => 'Large';

  @override
  String get lockScreenCoverLabel => 'Big-word cover on lock screen';

  @override
  String get lockScreenCoverDesc =>
      'When off, the lock screen shows only the regular small-text card';

  @override
  String get appearanceLabel => 'Appearance';

  @override
  String get appearanceSystem => 'Follow system';

  @override
  String get appearanceLight => 'Light';

  @override
  String get appearanceDark => 'Dark';

  @override
  String notifLastHeard(String word) {
    return 'Last word: $word';
  }

  @override
  String notifStarredLeft(int count) {
    return '$count unfamiliar words left';
  }

  @override
  String get notifActionStart => '▶ Start listening';

  @override
  String get notifActionSnooze => 'Remind me later';
}
