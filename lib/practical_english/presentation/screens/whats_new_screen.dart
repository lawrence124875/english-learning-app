import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../data/whats_new_service.dart';
import 'practical_english_screen.dart';
import '../../practical_english_release.dart';

/// V2 What's New（SPEC §11）：升級的 V1 使用者自動看到一次，
/// 之後可從首頁選單「新功能」再打開。
class WhatsNewScreen extends StatelessWidget {
  const WhatsNewScreen({super.key});

  /// 啟動流程：先判斷是否為 V1 升級（必須在功能介紹寫入
  /// onboarding_seen_v1 之前），再顯示 V1 功能介紹，最後視需要顯示 What's New。
  static Future<void> showOnLaunch(BuildContext context,
      {required Future<void> Function() showOnboarding}) async {
    if (!PracticalEnglishRelease.enabled) return showOnboarding();
    final showWhatsNew = await WhatsNewService.prepareOnLaunch();
    if (!context.mounted) return;
    await showOnboarding();
    if (showWhatsNew && context.mounted) await showOnce(context);
  }

  /// 啟動時用：先標記已看過再顯示。
  static Future<void> showOnce(BuildContext context) async {
    await WhatsNewService.markSeen();
    if (!context.mounted) return;
    await open(context);
  }

  static Future<void> open(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => const WhatsNewScreen(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final text = Theme.of(context).textTheme;
    final items = [
      (
        Icons.chat_bubble_outline,
        l.peWhatsNewPracticalTitle,
        l.peWhatsNewPracticalBody
      ),
      (
        Icons.record_voice_over,
        l.peWhatsNewSentenceTitle,
        l.peWhatsNewSentenceBody
      ),
      (Icons.star_outline, l.peWhatsNewWeakTitle, l.peWhatsNewWeakBody),
      (Icons.more_vert, l.peWhatsNewWhereTitle, l.peWhatsNewWhereBody),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l.menuWhatsNew)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l.peWhatsNewTitle, style: text.headlineSmall),
            const SizedBox(height: 16),
            for (final (icon, title, body) in items)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(icon),
                title: Text(title, style: text.titleMedium),
                subtitle: Text(body),
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  key: const Key('whats_new_done'),
                  onPressed: () => Navigator.pop(context),
                  child: Text(l.peWhatsNewDone),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  key: const Key('whats_new_try'),
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PracticalEnglishScreen()),
                  ),
                  child: Text(l.peWhatsNewTry),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
