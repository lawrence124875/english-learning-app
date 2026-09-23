import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../../domain/models/word_item.dart';
import '../../data/sources/notification_service.dart';
import '../../l10n/app_localizations.dart';

/// 學習統計畫面：今日學習數、總計學習數、每日複習提醒設定，
/// 以及四份教材各自的學習進度（NGSL 2809 額外附上官方公開的
/// 「完整涵蓋率」數據作為參考，不虛構精確百分比）。
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.statsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: AppLocalizations.of(context)!.todayLearnedLabel,
                  value: '${appState.stats.learnedToday}',
                  unit: AppLocalizations.of(context)!.unitCount,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: AppLocalizations.of(context)!.totalLearnedLabel,
                  value: '${appState.stats.totalLearned}',
                  unit: AppLocalizations.of(context)!.unitCount,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _ReminderSection(),
          const SizedBox(height: 20),
          Text(AppLocalizations.of(context)!.datasetProgressHeader,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          for (final dataset in appState.datasets) ...[
            _DatasetProgressCard(dataset: dataset),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  const _StatCard({required this.label, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 32, fontWeight: FontWeight.bold)),
            Text(unit, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 6),
            Text(label),
          ],
        ),
      ),
    );
  }
}

/// 單一教材的學習進度卡片：實際「已學習」數量（曾被朗讀過的項目），
/// 不是免費版解鎖數量——這兩個是不同的概念，分開呈現避免混淆。
class _DatasetProgressCard extends StatelessWidget {
  final WordDataset dataset;
  const _DatasetProgressCard({required this.dataset});

  static String? _description(String datasetId, AppLocalizations l) {
    switch (datasetId) {
      case 'ngsl_2809':
        return l.statsDescNgsl;
      case 'ngsl_spoken_720':
        return l.statsDescSpoken;
      case 'phrase_list_506':
        return l.statsDescPhrase;
      case 'phave_list_150':
        return l.statsDescPhave;
      default:
        return null; // 自訂匯入的教材沒有說明文字
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final description =
        _description(dataset.id, AppLocalizations.of(context)!);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<int>(
          future: appState.learnedCountForDataset(dataset.id),
          builder: (context, snapshot) {
            final learned = snapshot.data ?? 0;
            final total = dataset.items.length;
            final ratio = total == 0 ? 0.0 : learned / total;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dataset.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: ratio),
                const SizedBox(height: 8),
                Text(AppLocalizations.of(context)!.itemsCountLabel(learned, total)),
                if (description != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ReminderSection extends StatefulWidget {
  const _ReminderSection();

  @override
  State<_ReminderSection> createState() => _ReminderSectionState();
}

class _ReminderSectionState extends State<_ReminderSection> {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.dailyReminderHeader,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(AppLocalizations.of(context)!.enableDailyReminder),
              value: appState.reminderEnabled,
              onChanged: (v) => appState.setReminder(
                enabled: v,
                hour: appState.reminderHour,
                minute: appState.reminderMinute,
              ),
            ),
            if (appState.reminderEnabled) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(AppLocalizations.of(context)!.reminderTimeLabel),
                trailing: TextButton(
                  child: Text(
                      '${appState.reminderHour.toString().padLeft(2, '0')}:${appState.reminderMinute.toString().padLeft(2, '0')}'),
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                          hour: appState.reminderHour,
                          minute: appState.reminderMinute),
                    );
                    if (picked != null) {
                      await appState.setReminder(
                        enabled: true,
                        hour: picked.hour,
                        minute: picked.minute,
                      );
                      if (!context.mounted) return;
                      // 排完之後實際去查一次系統裡有沒有真的排到，
                      // 讓使用者（跟我們）都能確認排程有沒有真的成功，
                      // 而不是猜測「應該有生效」。
                      final pending =
                          await NotificationService.getPendingReminders();
                      final scheduled = pending.any((n) => n.id == 1001);
                      final timeStr =
                          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(scheduled
                              ? AppLocalizations.of(context)!
                                  .reminderScheduledMessage(timeStr)
                              : AppLocalizations.of(context)!
                                  .reminderFailedMessage),
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 4),
              OutlinedButton.icon(
                onPressed: () async {
                  await NotificationService.requestIgnoreBatteryOptimizations();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(AppLocalizations.of(context)!.batteryOptSnackbar),
                      duration: const Duration(seconds: 4),
                    ),
                  );
                },
                icon: const Icon(Icons.battery_charging_full, size: 18),
                label: Text(AppLocalizations.of(context)!.batteryOptButtonLabel),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  await NotificationService.openMiuiAutostartSettings();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          AppLocalizations.of(context)!.miuiAutostartSnackbar),
                      duration: const Duration(seconds: 4),
                    ),
                  );
                },
                icon: const Icon(Icons.rocket_launch, size: 18),
                label:
                    Text(AppLocalizations.of(context)!.miuiAutostartButtonLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
