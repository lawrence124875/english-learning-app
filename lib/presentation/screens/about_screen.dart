import 'package:flutter/material.dart';
import 'feedback_screen.dart';

/// 版權/關於頁面。列出四份教材的正式來源引用，
/// 滿足 CC BY / CC BY-SA 授權要求的「姓名標示」義務。
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('關於本 App / 版權聲明')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '智慧聽覺巡航',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FeedbackScreen()),
            ),
            icon: const Icon(Icons.feedback_outlined),
            label: const Text('意見回饋 / 回報問題'),
          ),
          const SizedBox(height: 24),
          const Text('本 App 之單字/語塊資料取自以下公開學術研究成果，特此致謝並標明出處：'),
          const SizedBox(height: 16),
          const _AttributionCard(
            title: 'NGSL 2809（核心單字）',
            body:
                'The New General Service List, Browne, C., Culligan, B., & '
                'Phillips, J. (2013). 採用創用CC「姓名標示-相同方式分享 4.0 '
                '國際授權條款」（CC BY-SA 4.0）。',
          ),
          const _AttributionCard(
            title: 'NGSL-Spoken 720（口語常用字）',
            body:
                'The NGSL Spoken List, Browne, C., Culligan, B., & Phillips, '
                'J. 採用創用CC「姓名標示-相同方式分享 4.0 國際授權條款」'
                '（CC BY-SA 4.0）。',
          ),
          const _AttributionCard(
            title: 'PhaVE List（片語動詞）',
            body:
                'The PHaVE List, Garnier, M., & Schmitt, N. (2015). 採用'
                '創用CC「姓名標示 4.0 國際授權條款」（CC BY 4.0）。',
          ),
          const _AttributionCard(
            title: 'PHRASE List（高頻語塊）',
            body:
                'The PHRASE List, Martinez, R., & Schmitt, N. (2012). '
                '版權歸原作者所有，本 App 依授權範圍使用於教學用途。',
          ),
          const SizedBox(height: 24),
          const Text(
            '朗讀語音由裝置系統內建文字轉語音引擎提供。',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _AttributionCard extends StatelessWidget {
  final String title;
  final String body;
  const _AttributionCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(body),
          ],
        ),
      ),
    );
  }
}
