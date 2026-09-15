import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'feedback_screen.dart';

/// 版權/關於頁面。列出四份教材的正式來源引用，
/// 滿足 CC BY / CC BY-SA 授權要求的「姓名標示」義務——
/// 包含姓名、著作權/授權聲明，以及指向授權條款與原作品的連結。
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

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
          _AttributionCard(
            title: 'NGSL 2809（核心單字）',
            body:
                'The New General Service List, Browne, C., Culligan, B., & '
                'Phillips, J. (2013). 採用創用CC「姓名標示-相同方式分享 4.0 '
                '國際授權條款」（CC BY-SA 4.0）。',
            sourceLabel: '原作品：newgeneralservicelist.com',
            sourceUrl: 'https://www.newgeneralservicelist.com',
            licenseLabel: '授權條款：CC BY-SA 4.0',
            licenseUrl: 'https://creativecommons.org/licenses/by-sa/4.0/',
            onOpen: _open,
          ),
          _AttributionCard(
            title: 'NGSL-Spoken 720（口語常用字）',
            body:
                'The NGSL Spoken List, Browne, C., Culligan, B., & Phillips, '
                'J. 採用創用CC「姓名標示-相同方式分享 4.0 國際授權條款」'
                '（CC BY-SA 4.0）。',
            sourceLabel: '原作品：newgeneralservicelist.com',
            sourceUrl: 'https://www.newgeneralservicelist.com',
            licenseLabel: '授權條款：CC BY-SA 4.0',
            licenseUrl: 'https://creativecommons.org/licenses/by-sa/4.0/',
            onOpen: _open,
          ),
          _AttributionCard(
            title: 'PhaVE List（片語動詞）',
            body:
                'The PHaVE List, Garnier, M., & Schmitt, N. (2015). 採用'
                '創用CC「姓名標示 4.0 國際授權條款」（CC BY 4.0）。',
            sourceLabel: '原作品：Nottingham Repository',
            sourceUrl:
                'https://nottingham-repository.worktribe.com/output/762398',
            licenseLabel: '授權條款：CC BY 4.0',
            licenseUrl: 'https://creativecommons.org/licenses/by/4.0/',
            onOpen: _open,
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
  final String? sourceLabel;
  final String? sourceUrl;
  final String? licenseLabel;
  final String? licenseUrl;
  final Future<void> Function(String url)? onOpen;

  const _AttributionCard({
    required this.title,
    required this.body,
    this.sourceLabel,
    this.sourceUrl,
    this.licenseLabel,
    this.licenseUrl,
    this.onOpen,
  });

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
            if (sourceUrl != null || licenseUrl != null) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  if (sourceUrl != null)
                    _LinkText(label: sourceLabel!, onTap: () => onOpen!(sourceUrl!)),
                  if (licenseUrl != null)
                    _LinkText(label: licenseLabel!, onTap: () => onOpen!(licenseUrl!)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LinkText extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _LinkText({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          decoration: TextDecoration.underline,
          fontSize: 13,
        ),
      ),
    );
  }
}
