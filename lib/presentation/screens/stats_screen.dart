import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../../domain/models/word_item.dart';

/// 學習統計畫面：今日學習數、總計學習數、每日複習提醒設定，
/// 以及四份教材各自的學習進度（NGSL 2809 額外附上官方公開的
/// 「完整涵蓋率」數據作為參考，不虛構精確百分比）。
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('學習統計')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: '今日已學習',
                  value: '${appState.stats.learnedToday}',
                  unit: '個',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: '累計已學習',
                  value: '${appState.stats.totalLearned}',
                  unit: '個',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _ReminderSection(),
          const SizedBox(height: 20),
          const Text('各教材學習進度',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final isNgsl = dataset.id == 'ngsl_2809';

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
                Text('$learned / $total 個項目'),
                if (isNgsl) ...[
                  const SizedBox(height: 12),
                  const Text(
                    '根據 NGSL 官方研究，完整學會這 2,809 個核心單字，'
                    '可達到一般日常英文文本約 92% 的理解涵蓋率'
                    '（資料來源：New General Service List Project）。',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
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
            const Text('每日複習提醒', style: TextStyle(fontWeight: FontWeight.bold)),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('開啟每日提醒'),
              value: appState.reminderEnabled,
              onChanged: (v) => appState.setReminder(
                enabled: v,
                hour: appState.reminderHour,
                minute: appState.reminderMinute,
              ),
            ),
            if (appState.reminderEnabled)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('提醒時間'),
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
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
