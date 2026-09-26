import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'feedback_screen.dart';
import '../../data/sources/ads_service.dart';
import '../../l10n/app_localizations.dart';

/// 版權/關於頁面。列出四份教材的正式來源引用，
/// 滿足 CC BY / CC BY-SA 授權要求的「姓名標示」義務——
/// 包含姓名、著作權/授權聲明，以及指向授權條款與原作品的連結。
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      AdsService.skipNextAppOpenAd();
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.menuAbout)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l.appTitle,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FeedbackScreen()),
            ),
            icon: const Icon(Icons.feedback_outlined),
            label: Text(l.aboutFeedbackButton),
          ),
          const SizedBox(height: 24),
          Text(l.aboutAttributionIntro),
          const SizedBox(height: 16),
          // 作者、年份、作品名稱屬於學術引用格式，各語言一律保留英文原文；
          // 只有授權說明、連結標籤依介面語言翻譯。
          _AttributionCard(
            title: l.aboutNgslTitle,
            body: 'The New General Service List, Browne, C., Culligan, B., & '
                'Phillips, J. (2013). ${l.aboutLicenseCcBySa}',
            sourceLabel: l.aboutSourceLabel('newgeneralservicelist.com'),
            sourceUrl: 'https://www.newgeneralservicelist.com',
            licenseLabel: l.aboutLicenseLabel('CC BY-SA 4.0'),
            licenseUrl: 'https://creativecommons.org/licenses/by-sa/4.0/',
            onOpen: _open,
          ),
          _AttributionCard(
            title: l.aboutSpokenTitle,
            body: 'The NGSL Spoken List, Browne, C., Culligan, B., & Phillips, '
                'J. ${l.aboutLicenseCcBySa}',
            sourceLabel: l.aboutSourceLabel('newgeneralservicelist.com'),
            sourceUrl: 'https://www.newgeneralservicelist.com',
            licenseLabel: l.aboutLicenseLabel('CC BY-SA 4.0'),
            licenseUrl: 'https://creativecommons.org/licenses/by-sa/4.0/',
            onOpen: _open,
          ),
          _AttributionCard(
            title: l.aboutPhaveTitle,
            body: 'The PHaVE List, Garnier, M., & Schmitt, N. (2015). '
                '${l.aboutLicenseCcBy}',
            sourceLabel: l.aboutSourceLabel('Nottingham Repository'),
            sourceUrl:
                'https://nottingham-repository.worktribe.com/output/762398',
            licenseLabel: l.aboutLicenseLabel('CC BY 4.0'),
            licenseUrl: 'https://creativecommons.org/licenses/by/4.0/',
            onOpen: _open,
          ),
          _AttributionCard(
            title: l.aboutPhraseTitle,
            body: 'The PHRASE List, Martinez, R., & Schmitt, N. (2012). '
                '${l.aboutPhraseRights}',
          ),
          const SizedBox(height: 24),
          Text(
            l.aboutTtsNote,
            style: const TextStyle(color: Colors.grey),
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
