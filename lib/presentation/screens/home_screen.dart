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
        title: const Text('智慧聽覺巡航'),
        actions: [
          IconButton(
            tooltip: '學習統計',
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StatsScreen()),
            ),
          ),
          PopupMenuButton<String>(
            tooltip: '更多',
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
              }
            },
            itemBuilder: (context) => [
              if (!appState.isPremium)
                const PopupMenuItem(
                  value: 'premium',
                  child: ListTile(
                    leading: Icon(Icons.workspace_premium),
                    title: Text('升級 Premium'),
                  ),
                ),
              const PopupMenuItem(
                value: 'voice',
                child: ListTile(
                  leading: Icon(Icons.record_voice_over),
                  title: Text('語音預覽'),
                ),
              ),
              const PopupMenuItem(
                value: 'about',
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('關於本 App / 版權聲明'),
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
          label: Text(dataset.shortName),
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
                        ? 'No. ${appState.currentWordNumber} / ${appState.currentDataset.items.length}'
                        : appState.currentDataset.shortName,
                    style: const TextStyle(fontSize: 12),
                  ),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                Chip(
                  label: Text('第 ${appState.currentCycleNumber} 輪學習',
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
                '本輪已聽過進度：${appState.roundHeardCount} / ${appState.roundTotalCount}'
                ' (${(appState.progressRatio * 100).round()}%)',
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
                    Text(word.meaningFor('zh-TW'),
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: appState.togglePlay,
              icon: Icon(appState.isPlaying ? Icons.pause : Icons.play_arrow),
              label: Text(appState.isPlaying ? '暫停巡航朗讀' : '開始巡航朗讀'),
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
              label: const Text('加入不熟悉單字庫'),
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
            label: const Text('上一個'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: appState.replay,
            icon: const Icon(Icons.replay),
            label: const Text('再讀一次'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => appState.next(
                speak: appState.settings.speakOnManualNavigate),
            icon: const Icon(Icons.skip_next),
            label: const Text('下一個'),
          ),
        ),
      ],
    );
  }
}
