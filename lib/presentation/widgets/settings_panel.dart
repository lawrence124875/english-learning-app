import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/playback_settings.dart';
import '../providers/app_state.dart';

/// 可收合的播放設定面板。
/// 預設收合、記住上次展開狀態、收合時顯示目前設定摘要。
class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final settings = appState.settings;

    return Card(
      child: ExpansionTile(
        title: const Text('⚙️ 播放設定'),
        subtitle: Text(settings.summaryLine),
        initiallyExpanded: settings.settingsPanelExpanded,
        onExpansionChanged: (expanded) {
          appState.updateSettings(
              settings.copyWith(settingsPanelExpanded: expanded));
        },
        children: [
          _ScopeModeDropdown(settings: settings),
          Text('已標記 ${appState.currentStarred.length} 個項目',
              style: const TextStyle(color: Colors.redAccent)),
          _ReadModeDropdown(settings: settings),
          _RepeatCountDropdown(settings: settings),
          SwitchListTile(
            title: const Text('手動切換單字時發音'),
            value: settings.speakOnManualNavigate,
            onChanged: (v) => appState.updateSettings(
                settings.copyWith(speakOnManualNavigate: v)),
          ),
          SwitchListTile(
            title: const Text('顯示中文翻譯'),
            value: settings.showTranslation,
            onChanged: (v) => appState
                .updateSettings(settings.copyWith(showTranslation: v)),
          ),
          ListTile(
            title: Text('單字間隔停頓：${settings.intervalSeconds.toStringAsFixed(1)} 秒'),
            subtitle: Slider(
              value: settings.intervalSeconds,
              min: 0.5,
              max: 5.0,
              divisions: 45,
              onChanged: (v) => appState
                  .updateSettings(settings.copyWith(intervalSeconds: v)),
            ),
          ),
          ListTile(
            title: Text('朗讀語速：${settings.speechRate.toStringAsFixed(1)}x'),
            subtitle: Slider(
              value: settings.speechRate,
              min: 0.3,
              max: 1.5,
              divisions: 24,
              onChanged: (v) =>
                  appState.updateSettings(settings.copyWith(speechRate: v)),
            ),
          ),
          const _JumpToRow(),
        ],
      ),
    );
  }
}

class _ScopeModeDropdown extends StatelessWidget {
  final PlaybackSettings settings;
  const _ScopeModeDropdown({required this.settings});

  static const _labels = {
    ScopeMode.allRandom: '全部清單（隨機播放）',
    ScopeMode.allSequential: '全部清單（依序播放）',
    ScopeMode.starredRandom: '僅不熟悉（隨機播放）',
    ScopeMode.starredSequential: '僅不熟悉（依序播放）',
  };

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    return ListTile(
      title: const Text('播放範圍 / 模式'),
      trailing: DropdownButton<ScopeMode>(
        value: settings.scopeMode,
        items: _labels.entries
            .map((e) =>
                DropdownMenuItem(value: e.key, child: Text(e.value)))
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
    return ListTile(
      title: const Text('朗讀內容模式'),
      trailing: DropdownButton<ReadMode>(
        value: settings.readMode,
        items: const [
          DropdownMenuItem(
              value: ReadMode.bilingual, child: Text('英雙讀（先英文，再中文）')),
          DropdownMenuItem(
              value: ReadMode.englishOnly, child: Text('純英文')),
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
    return ListTile(
      title: const Text('英文重複朗讀次數'),
      trailing: DropdownButton<int>(
        value: settings.repeatCount,
        items: const [
          DropdownMenuItem(value: 1, child: Text('讀 1 次')),
          DropdownMenuItem(value: 2, child: Text('讀 2 次（推薦）')),
          DropdownMenuItem(value: 3, child: Text('讀 3 次')),
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

class _JumpToRow extends StatefulWidget {
  const _JumpToRow();

  @override
  State<_JumpToRow> createState() => _JumpToRowState();
}

class _JumpToRowState extends State<_JumpToRow> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    return ListTile(
      title: const Text('跳轉至指定編號（並朗讀）'),
      trailing: SizedBox(
        width: 160,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
              ),
            ),
            TextButton(
              onPressed: () {
                final n = int.tryParse(_controller.text);
                if (n != null) appState.jumpTo(n);
              },
              child: const Text('跳轉'),
            ),
          ],
        ),
      ),
    );
  }
}
