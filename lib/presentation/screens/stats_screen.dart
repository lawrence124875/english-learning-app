import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../../domain/models/word_item.dart';
import '../../data/sources/notification_service.dart';

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

  static const _descriptions = {
    'ngsl_2809':
        '英語核心單字表，取自公開頻率研究，完整學會這 2,809 個字，'
        '可達到一般日常英文文本約 92% 的理解涵蓋率'
        '（資料來源：New General Service List Project）。',
    'ngsl_spoken_720':
        '從日常口語對話中挑出的 720 個高頻詞彙，專門加強「聽」與「說」'
        '情境的反應速度，跟 NGSL 核心單字表互補，涵蓋口語裡常用、'
        '但書面文字裡較少出現的用詞。',
    'phrase_list_506':
        '506 個英語母語人士真正常用的固定搭配與語塊（例如 "in order to"、'
        '"as well as"），不是單字而是「一整組一起記」的片語，能幫助'
        '說出更自然道地的英文。',
    'phave_list_150':
        '收錄 150 個最常用的片語動詞（例如 "look after"、"give up"），'
        '這類「動詞+介詞」組合是英語學習者公認最難掌握的一塊，'
        '集中複習這 150 個能涵蓋大部分日常會遇到的片語動詞。',
  };

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final description = _descriptions[dataset.id];

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
            if (appState.reminderEnabled) ...[
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
                      if (!context.mounted) return;
                      // 排完之後實際去查一次系統裡有沒有真的排到，
                      // 讓使用者（跟我們）都能確認排程有沒有真的成功，
                      // 而不是猜測「應該有生效」。
                      final pending =
                          await NotificationService.getPendingReminders();
                      final scheduled = pending.any((n) => n.id == 1001);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(scheduled
                              ? '已排定 ${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')} 提醒'
                              : '排程失敗，請確認電池優化設定或重新開啟提醒開關'),
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
                    const SnackBar(
                      content: Text('請確認「省電策略」選擇「無限制」'),
                      duration: Duration(seconds: 4),
                    ),
                  );
                },
                icon: const Icon(Icons.battery_charging_full, size: 18),
                label: const Text('提醒沒準時跳出？點此排除電池優化限制'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  await NotificationService.openMiuiAutostartSettings();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('小米手機請在清單裡找到本App並開啟自啟動'
                          '（其他廠牌手機可忽略這個按鈕）'),
                      duration: Duration(seconds: 4),
                    ),
                  );
                },
                icon: const Icon(Icons.rocket_launch, size: 18),
                label: const Text('小米/Redmi 手機請另外開啟「自啟動」'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
