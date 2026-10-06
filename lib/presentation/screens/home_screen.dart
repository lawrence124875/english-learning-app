import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/app_state.dart';
import '../widgets/settings_panel.dart';
import '../widgets/unlock_banner.dart';
import '../widgets/banner_ad_widget.dart';
import '../app_theme.dart';
import 'voice_test_screen.dart';
import 'about_screen.dart';
import 'paywall_screen.dart';
import 'stats_screen.dart';
import 'import_dataset_screen.dart';
import 'onboarding_screen.dart';
import '../../l10n/app_localizations.dart';
import '../dataset_labels.dart';
import '../../data/sources/update_service.dart';
import '../../data/sources/analytics_service.dart';
import '../../data/sources/ads_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  /// 只給介面截圖測試用：不初始化外掛、不跳新手導覽與更新檢查。
  @visibleForTesting
  static bool previewMode = false;

  @override
  void initState() {
    super.initState();
    if (previewMode) return;
    context.read<AppState>().initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 第一次開啟 App 時顯示特色介紹（看過就不再自動出現）。
      OnboardingScreen.showIfFirstTime(context);
      _checkForUpdate();
    });
  }

  /// 開啟 App 時檢查 Google Play 是否有新版本；一般更新下載完成後，
  /// 跳出提示讓使用者選擇何時重新啟動套用。
  Future<void> _checkForUpdate() async {
    final downloaded = await UpdateService.checkForUpdate();
    if (!downloaded || !mounted) return;
    final l = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l.updateDownloadedMessage),
        duration: const Duration(days: 1),
        action: SnackBarAction(
          label: l.updateRestartButton,
          onPressed: UpdateService.completeFlexibleUpdate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final palette = AppPalette.of(context);

    if (appState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 0.3.0 版面 D（柔光卡片／夜讀深綠）：上方淡綠光暈背景、教材下拉按鈕、
    // 單字當主角的大卡片（按鈕縮小）、一行解鎖列、播放設定、免費版橫幅廣告。
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.bgTop, palette.bgBottom, palette.bgBottom],
          stops: const [0, 0.5, 1],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          titleSpacing: 16,
          // 標題在直屏時可能比可用寬度長（例如越南文、印尼文），
          // 用 FittedBox 自動縮小字級，確保整個 App 名稱都看得到；
          // 寬度足夠時（橫屏、中文）維持原本大小，不會被放大。
          title: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              AppLocalizations.of(context)!.appTitle,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 19),
            ),
          ),
        actions: [
          IconButton(
            tooltip: AppLocalizations.of(context)!.statsTooltip,
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StatsScreen()),
            ),
          ),
          PopupMenuButton<String>(
            tooltip: AppLocalizations.of(context)!.moreTooltip,
            onSelected: (value) {
              if (value == 'premium') {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PaywallScreen()));
              } else if (value == 'voice') {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const VoiceTestScreen()));
              } else if (value == 'about') {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AboutScreen()));
              } else if (value == 'intro') {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (_) => const OnboardingScreen()));
              } else if (value == 'share') {
                _shareApp(context);
              } else if (value == 'adPrivacy') {
                AdsService.showPrivacyOptions();
              } else if (value == 'import') {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ImportDatasetScreen()));
              }
            },
            itemBuilder: (context) => [
              if (!appState.isPremium)
                PopupMenuItem(
                  value: 'premium',
                  child: ListTile(
                    leading: const Icon(Icons.workspace_premium),
                    title: Text(AppLocalizations.of(context)!.menuPremium),
                  ),
                ),
              PopupMenuItem(
                value: 'intro',
                child: ListTile(
                  leading: const Icon(Icons.lightbulb_outline),
                  title: Text(AppLocalizations.of(context)!.menuIntro),
                ),
              ),
              PopupMenuItem(
                value: 'voice',
                child: ListTile(
                  leading: const Icon(Icons.record_voice_over),
                  title: Text(AppLocalizations.of(context)!.menuVoicePreview),
                ),
              ),
              PopupMenuItem(
                value: 'import',
                child: ListTile(
                  leading: const Icon(Icons.upload_file),
                  title: Text(AppLocalizations.of(context)!.menuImport),
                ),
              ),
              PopupMenuItem(
                value: 'share',
                child: ListTile(
                  leading: const Icon(Icons.share),
                  title: Text(AppLocalizations.of(context)!.menuShare),
                ),
              ),
              // 第十七版：歐洲等需要同意的地區（UMP）才顯示，讓使用者修改廣告同意。
              if (!appState.isPremium && AdsService.privacyOptionsRequired)
                PopupMenuItem(
                  value: 'adPrivacy',
                  child: ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: Text(AppLocalizations.of(context)!.menuAdPrivacy),
                  ),
                ),
              PopupMenuItem(
                value: 'about',
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(AppLocalizations.of(context)!.menuAbout),
                ),
              ),
            ],
          ),
        ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                // 單字卡撐滿剩下的高度（Premium 沒有解鎖列和廣告，卡片自動變高）；
                // 螢幕太矮或播放設定展開時整頁可捲動。
                child: LayoutBuilder(builder: (context, constraints) {
                  final showUnlock = !appState.isPremium &&
                      !appState.currentDatasetFullyUnlocked;
                  final others = 4 + 16 + 50 + 14 + 12 + 72 + (showUnlock ? 62 : 0);
                  final cardHeight =
                      (constraints.maxHeight - others).clamp(360.0, 900.0);
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _DatasetPicker(appState: appState),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: cardHeight,
                          child: _WordCard(appState: appState),
                        ),
                        const SizedBox(height: 12),
                        const UnlockBanner(),
                        const SettingsPanel(),
                      ],
                    ),
                  );
                }),
              ),
              if (!appState.isPremium)
                ColoredBox(
                  color: palette.adArea,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: BannerAdWidget(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 第十五版（依 TestersCommunity 回饋新增）：叫出系統分享面板，
/// 分享文字依介面語言，後面接 Play 商店連結。
const String _playStoreUrl =
    'https://play.google.com/store/apps/details?id=tw.bcc.englishapp';

Future<void> _shareApp(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  AnalyticsService.shareApp();
  try {
    await Share.share(
      '${l10n.shareMessage}\n$_playStoreUrl',
      subject: l10n.appTitle,
    );
  } catch (e) {
    debugPrint('分享失敗：$e');
  }
}

/// 教材切換：一個下拉按鈕（取代 0.2 以前會換行的 chip），點開列出全部
/// 教材（含自訂教材）。長語言、自訂教材多時都放得下。
class _DatasetPicker extends StatelessWidget {
  final AppState appState;
  const _DatasetPicker({required this.appState});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final palette = AppPalette.of(context);
    return Material(
      color: palette.softRow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showPicker(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  datasetShortName(appState.currentDataset, l),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 170),
                child: Text(
                  l.switchDatasetButton,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: scheme.primary, fontWeight: FontWeight.w600),
                ),
              ),
              Icon(Icons.arrow_drop_down, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * 0.7),
          child: ListView(
            shrinkWrap: true,
            children: [
              for (var i = 0; i < appState.datasets.length; i++)
                ListTile(
                  title: Text(datasetName(appState.datasets[i], l)),
                  subtitle:
                      Text(datasetShortName(appState.datasets[i], l)),
                  trailing: i == appState.currentDatasetIndex
                      ? Icon(Icons.check,
                          color: Theme.of(sheetContext).colorScheme.primary)
                      : null,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    if (i != appState.currentDatasetIndex) {
                      appState.switchDataset(i);
                    }
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

/// 單字卡：單字是主角，按鈕刻意縮小（Lawrence 2026-10-06：以單字學習
/// 視覺為主、要能專注）。單字大小依「播放設定 → 單字大小」。
class _WordCard extends StatelessWidget {
  final AppState appState;
  const _WordCard({required this.appState});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final palette = AppPalette.of(context);
    final word = appState.currentWord;
    final settings = appState.settings;
    final wordSize = AppTheme.wordFontSize(settings.wordSize.index);
    final percent = (appState.progressRatio * 100).round();
    final muted = TextStyle(
        color: palette.muted,
        fontSize: 13,
        fontFeatures: const [FontFeature.tabularFigures()]);

    return SizedBox.expand(
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
                color: palette.cardShadow,
                blurRadius: 32,
                offset: const Offset(0, 12)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    appState.currentWordNumber != null
                        ? l.wordNumberLabel(appState.currentWordNumber!,
                            appState.currentDataset.items.length)
                        : datasetShortName(appState.currentDataset, l),
                    style: muted,
                  ),
                ),
                Text('${l.cycleShort(appState.currentCycleNumber)} · $percent%',
                    style: muted),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: appState.progressRatio,
                minHeight: 6,
                color: AppTheme.brand,
                backgroundColor: palette.track,
              ),
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: appState.replay,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _FitWord(
                        text: word?.word ?? '—',
                        maxSize: wordSize,
                        textDirection: appState.wordIsRtl
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        style: TextStyle(
                          fontFamily: AppTheme.wordFontFamily,
                          fontWeight: FontWeight.w800,
                          color: palette.word,
                          height: 1.1,
                        ),
                      ),
                      if (settings.showTranslation && word != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          appState.meaningOf(word),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          textDirection: appState.meaningIsRtl(word)
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          style: TextStyle(
                            color: palette.translation,
                            fontSize: 16 + settings.wordSize.index * 2.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            _Controls(appState: appState),
            const SizedBox(height: 4),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              children: [
                TextButton.icon(
                  onPressed: appState.toggleStarCurrent,
                  style: TextButton.styleFrom(
                      foregroundColor: palette.star,
                      visualDensity: VisualDensity.compact),
                  icon: Icon(
                      appState.isCurrentStarred
                          ? Icons.star
                          : Icons.star_border,
                      size: 18),
                  label: Text(l.starButton,
                      style: const TextStyle(fontSize: 13)),
                ),
                TextButton.icon(
                  onPressed: appState.replay,
                  style: TextButton.styleFrom(
                      foregroundColor: palette.muted,
                      visualDensity: VisualDensity.compact),
                  icon: const Icon(Icons.replay, size: 18),
                  label: Text(l.navReplay,
                      style: const TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 上一個／播放／下一個：上一個與下一個是小膠囊文字鍵，
/// 播放是中型實心膠囊。阿拉伯文（右到左）時 Row 自動鏡像，
/// 圖示也換方向，箭頭才會指向外側。
class _Controls extends StatelessWidget {
  final AppState appState;
  const _Controls({required this.appState});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final palette = AppPalette.of(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final pillStyle = TextButton.styleFrom(
      backgroundColor: palette.pill,
      foregroundColor: palette.onPill,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      minimumSize: const Size(0, 40),
      shape: const StadiumBorder(),
    );
    Widget label(String text) => FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(text,
              maxLines: 1,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        );
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: TextButton.icon(
            style: pillStyle,
            onPressed: () => appState.previous(
                speak: appState.settings.speakOnManualNavigate),
            icon: Icon(rtl ? Icons.skip_next : Icons.skip_previous, size: 18),
            label: label(l.navPrevious),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 6,
          child: Center(
            child: FilledButton.icon(
              onPressed: appState.togglePlay,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 46),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: const StadiumBorder(),
                elevation: 2,
              ),
              icon: Icon(appState.isPlaying ? Icons.pause : Icons.play_arrow),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  appState.isPlaying ? l.playShortPause : l.playShortStart,
                  maxLines: 1,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 5,
          child: Directionality(
            // 「下一個」圖示放在文字後面（外側）。
            textDirection: rtl ? TextDirection.ltr : TextDirection.rtl,
            child: TextButton.icon(
              style: pillStyle,
              onPressed: () => appState.next(
                  speak: appState.settings.speakOnManualNavigate),
              icon: Icon(rtl ? Icons.skip_previous : Icons.skip_next, size: 18),
              label: label(l.navNext),
            ),
          ),
        ),
      ],
    );
  }
}

/// 單字自動縮小：從設定的大小開始，放不下（超過兩行或單一長字超寬）
/// 就逐步縮小，最小到 55%，確保長片語也完整顯示、不截斷。
class _FitWord extends StatelessWidget {
  final String text;
  final double maxSize;
  final TextStyle style;
  final TextDirection textDirection;
  const _FitWord({
    required this.text,
    required this.maxSize,
    required this.style,
    required this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final scaler = MediaQuery.textScalerOf(context);
      var size = maxSize;
      final minSize = maxSize * 0.55;
      while (size > minSize) {
        final tp = TextPainter(
          text: TextSpan(text: text, style: style.copyWith(fontSize: size)),
          textDirection: textDirection,
          textAlign: TextAlign.center,
          maxLines: 2,
          textScaler: scaler,
        )..layout(maxWidth: constraints.maxWidth);
        final longest = text
            .split(RegExp(r'\s+'))
            .fold<String>('', (a, b) => b.length > a.length ? b : a);
        final wp = TextPainter(
          text: TextSpan(text: longest, style: style.copyWith(fontSize: size)),
          textDirection: textDirection,
          textScaler: scaler,
        )..layout();
        final fits = !tp.didExceedMaxLines && wp.width <= constraints.maxWidth;
        tp.dispose();
        wp.dispose();
        if (fits) break;
        size -= 2;
      }
      return Text(
        text,
        textAlign: TextAlign.center,
        textDirection: textDirection,
        maxLines: 2,
        style: style.copyWith(fontSize: size),
      );
    });
  }
}
