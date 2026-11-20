import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/sources/ads_service.dart';
import '../../l10n/app_localizations.dart';

/// 設定面板最下方「LC Lab 其他 App」：三列，點擊以外部應用程式開啟 Play 商店。
/// 圖示內嵌於 assets，不連網抓取；不加任何追蹤。
class LcLabAppsSection extends StatelessWidget {
  /// false：不顯示分隔線與標題（獨立頁面用，標題在 AppBar）。
  final bool showHeader;
  const LcLabAppsSection({super.key, this.showHeader = true});

  static const qianguaUrl =
      'https://play.google.com/store/apps/details?id=com.lclab.qiangua';
  static const tarotUrl =
      'https://play.google.com/store/apps/details?id=com.lclab.tarot';
  static const qimenUrl =
      'https://play.google.com/store/apps/details?id=com.lclab.qimen';
  static const qianguaIcon = 'assets/lclab/qiangua.png';
  static const tarotIcon = 'assets/lclab/tarot.png';
  static const qimenIcon = 'assets/lclab/qimen.png';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          const Divider(height: 24),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(l.lcLabAppsTitle,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
        _AppRow(
          icon: qianguaIcon,
          name: l.lcLabQianguaName,
          desc: l.lcLabQianguaDesc,
          onTap: () => _open(qianguaUrl),
        ),
        _AppRow(
          icon: tarotIcon,
          name: l.lcLabTarotName,
          desc: l.lcLabTarotDesc,
          onTap: () => _open(tarotUrl),
        ),
        _AppRow(
          icon: qimenIcon,
          name: l.lcLabQimenName,
          desc: l.lcLabQimenDesc,
          onTap: () => _open(qimenUrl),
        ),
      ],
    );
  }
}

class _AppRow extends StatelessWidget {
  final String icon;
  final String name;
  final String desc;
  final VoidCallback onTap;
  const _AppRow(
      {required this.icon,
      required this.name,
      required this.desc,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(icon,
            width: 44,
            height: 44,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const SizedBox(width: 44, height: 44, child: Icon(Icons.apps))),
      ),
      title: Text(name),
      subtitle: Text(desc),
      trailing: const Icon(Icons.open_in_new, size: 18),
      onTap: onTap,
    );
  }
}

/// 右上角選單「LC Lab 其他 App」開啟的頁面（內容與設定面板那區相同）。
class LcLabAppsScreen extends StatelessWidget {
  const LcLabAppsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.lcLabAppsTitle)),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: LcLabAppsSection(showHeader: false),
        ),
      ),
    );
  }
}
