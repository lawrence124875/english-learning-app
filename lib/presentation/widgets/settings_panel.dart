import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/playback_settings.dart';
import '../providers/app_state.dart';
import '../../l10n/app_localizations.dart';

/// 可收合的播放設定面板。
/// 預設收合、記住上次展開狀態、收合時顯示目前設定摘要。
class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final settings = appState.settings;
    final l = AppLocalizations.of(context)!;

    return Card(
      child: ExpansionTile(
        title: Text('⚙️ ${l.settingsTitle}'),
        subtitle: Text(settings.summaryLine),
        initiallyExpanded: settings.settingsPanelExpanded,
        onExpansionChanged: (expanded) {
          appState.updateSettings(
              settings.copyWith(settingsPanelExpanded: expanded));
        },
        children: [
          _ScopeModeDropdown(settings: settings),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(l.starredCountLabel(appState.currentStarred.length),
                  style: const TextStyle(color: Colors.redAccent)),
            ),
          ),
          const SizedBox(height: 8),
          _ReadModeDropdown(settings: settings),
          _RepeatCountDropdown(settings: settings),
          SwitchListTile(
            title: Text(l.speakOnManualNavigateLabel),
            value: settings.speakOnManualNavigate,
            onChanged: (v) => appState.updateSettings(
                settings.copyWith(speakOnManualNavigate: v)),
          ),
          SwitchListTile(
            title: Text(l.showTranslationLabel),
            value: settings.showTranslation,
            onChanged: (v) => appState
                .updateSettings(settings.copyWith(showTranslation: v)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.intervalSecondsLabel(
                    settings.intervalSeconds.toStringAsFixed(1))),
                Slider(
                  value: settings.intervalSeconds,
                  min: 0.5,
                  max: 5.0,
                  divisions: 45,
                  onChanged: (v) => appState
                      .updateSettings(settings.copyWith(intervalSeconds: v)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.speechRateLabel(settings.speechRate.toStringAsFixed(1))),
                Slider(
                  value: settings.speechRate,
                  min: 0.3,
                  max: 1.5,
                  divisions: 24,
                  onChanged: (v) =>
                      appState.updateSettings(settings.copyWith(speechRate: v)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// 直排版設定列：標題在上，控制項在下並佔滿寬度，
/// 避免直屏時標題文字跟下拉選單擠在同一行造成重疊。
class _StackedSettingRow extends StatelessWidget {
  final String title;
  final Widget control;
  const _StackedSettingRow({required this.title, required this.control});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 6),
          SizedBox(width: double.infinity, child: control),
        ],
      ),
    );
  }
}

class _ScopeModeDropdown extends StatelessWidget {
  final PlaybackSettings settings;
  const _ScopeModeDropdown({required this.settings});

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final l = AppLocalizations.of(context)!;
    final labels = {
      ScopeMode.allRandom: l.scopeAllRandom,
      ScopeMode.allSequential: l.scopeAllSequential,
      ScopeMode.starredRandom: l.scopeStarredRandom,
      ScopeMode.starredSequential: l.scopeStarredSequential,
    };
    return _StackedSettingRow(
      title: l.scopeModeLabel,
      control: DropdownButtonFormField<ScopeMode>(
        initialValue: settings.scopeMode,
        isExpanded: true,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(),
        ),
        items: labels.entries
            .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
            .toList(),
        onChanged: (v) {
          if (v != null) {
            appState.updateSettings(settings.copyWith(scopeMode: v));
          }
        },
      ),
    );
  }
}

class _ReadModeDropdown extends StatelessWidget {
  final PlaybackSettings settings;
  const _ReadModeDropdown({required this.settings});

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final l = AppLocalizations.of(context)!;
    return _StackedSettingRow(
      title: l.readModeLabel,
      control: DropdownButtonFormField<ReadMode>(
        initialValue: settings.readMode,
        isExpanded: true,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(),
        ),
        items: [
          DropdownMenuItem(
              value: ReadMode.bilingual, child: Text(l.readModeBilingual)),
          DropdownMenuItem(
              value: ReadMode.englishOnly, child: Text(l.readModeEnglishOnly)),
        ],
        onChanged: (v) {
          if (v != null) {
            appState.updateSettings(settings.copyWith(readMode: v));
          }
        },
      ),
    );
  }
}

class _RepeatCountDropdown extends StatelessWidget {
  final PlaybackSettings settings;
  const _RepeatCountDropdown({required this.settings});

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final l = AppLocalizations.of(context)!;
    return _StackedSettingRow(
      title: l.repeatCountLabel,
      control: DropdownButtonFormField<int>(
        initialValue: settings.repeatCount,
        isExpanded: true,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(),
        ),
        items: [
          DropdownMenuItem(value: 1, child: Text(l.repeatOnce)),
          DropdownMenuItem(value: 2, child: Text(l.repeatTwice)),
          DropdownMenuItem(value: 3, child: Text(l.repeatThrice)),
        ],
        onChanged: (v) {
          if (v != null) {
            appState.updateSettings(settings.copyWith(repeatCount: v));
          }
        },
      ),
    );
  }
}
