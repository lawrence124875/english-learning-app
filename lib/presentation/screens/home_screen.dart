import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/settings_panel.dart';
import '../widgets/unlock_banner.dart';
import '../widgets/banner_ad_widget.dart';
import 'voice_test_screen.dart';
import 'about_screen.dart';
import 'paywall_screen.dart';
import 'stats_screen.dart';
import 'import_dataset_screen.dart';
import '../../l10n/app_localizations.dart';
import '../dataset_labels.dart';
import '../../data/sources/update_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AppState>().initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdate());
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

    if (appState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        // 標題在直屏時可能比可用寬度長（例如越南文、印尼文），
        // 用 FittedBox 自動縮小字級，確保整個 App 名稱都看得到；
        // 寬度足夠時（橫屏、中文）維持原本大小，不會被放大。
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(AppLocalizations.of(context)!.appTitle),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DatasetTabs(appState: appState),
                    const SizedBox(height: 16),
                    _PlaybackCard(appState: appState),
                    const SizedBox(height: 12),
                    const UnlockBanner(),
                    const SizedBox(height: 12),
                    _NavigationButtons(appState: appState),
                    const SizedBox(height: 16),
                    const SettingsPanel(),
                  ],
                ),
              ),
            ),
            if (!appState.isPremium)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: BannerAdWidget(),
              ),
          ],
        ),
      ),
    );
  }
}

class _DatasetTabs extends StatelessWidget {
  final AppState appState;
  const _DatasetTabs({required this.appState});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: List.generate(appState.datasets.length, (i) {
        final dataset = appState.datasets[i];
        final selected = i == appState.currentDatasetIndex;
        return ChoiceChip(
          label: Text(datasetShortName(dataset, AppLocalizations.of(context)!)),
          selected: selected,
          onSelected: (_) => appState.switchDataset(i),
        );
      }),
    );
  }
}

class _PlaybackCard extends StatelessWidget {
  final AppState appState;
  const _PlaybackCard({required this.appState});

  @override
  Widget build(BuildContext context) {
    final word = appState.currentWord;
    final settings = appState.settings;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(
                    appState.currentWordNumber != null
                        ? AppLocalizations.of(context)!.wordNumberLabel(
                            appState.currentWordNumber!,
                            appState.currentDataset.items.length)
                        : datasetShortName(appState.currentDataset, AppLocalizations.of(context)!),
                    style: const TextStyle(fontSize: 12),
                  ),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                Chip(
                  label: Text(
                      AppLocalizations.of(context)!
                          .cycleLabel(appState.currentCycleNumber),
                      style: const TextStyle(fontSize: 12)),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: appState.progressRatio),
            const SizedBox(height: 6),
            if (appState.roundTotalCount > 0)
              Text(
                AppLocalizations.of(context)!.roundProgressLabel(
                    appState.roundHeardCount,
                    appState.roundTotalCount,
                    (appState.progressRatio * 100).round()),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
              ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: appState.replay,
              child: Column(
                children: [
                  Text(
                    word?.word ?? '—',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (settings.showTranslation && word != null) ...[
                    const SizedBox(height: 8),
                    Text(appState.meaningOf(word),
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: appState.togglePlay,
              icon: Icon(appState.isPlaying ? Icons.pause : Icons.play_arrow),
              label: Text(appState.isPlaying
                  ? AppLocalizations.of(context)!.playButtonPause
                  : AppLocalizations.of(context)!.playButtonStart),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: appState.toggleStarCurrent,
              icon: Icon(
                appState.currentPlaybackState.playlist.isNotEmpty &&
                        appState.currentStarred.contains(
                            appState.currentPlaybackState.playlist[
                                appState.currentPlaybackState.currentStep %
                                    appState
                                        .currentPlaybackState.playlist.length])
                    ? Icons.star
                    : Icons.star_border,
                color: Colors.amber,
              ),
              label: Text(AppLocalizations.of(context)!.starButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationButtons extends StatelessWidget {
  final AppState appState;
  const _NavigationButtons({required this.appState});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => appState.previous(
                speak: appState.settings.speakOnManualNavigate),
            icon: const Icon(Icons.skip_previous),
            label: Text(AppLocalizations.of(context)!.navPrevious),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: appState.replay,
            icon: const Icon(Icons.replay),
            label: Text(AppLocalizations.of(context)!.navReplay),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => appState.next(
                speak: appState.settings.speakOnManualNavigate),
            icon: const Icon(Icons.skip_next),
            label: Text(AppLocalizations.of(context)!.navNext),
          ),
        ),
      ],
    );
  }
}
