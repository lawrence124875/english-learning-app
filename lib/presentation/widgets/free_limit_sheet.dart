import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../screens/paywall_screen.dart';

/// 碰到免費版限制時的提示（★ 滿 30、V2 今日 5 句用完…）：
/// 一段說明＋「升級 Premium」（開付費牆，帶來源）＋「以後再說」。
Future<void> showFreeLimitSheet(
  BuildContext context, {
  required String title,
  required String body,
  required String source,
}) {
  final l = AppLocalizations.of(context)!;
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            Text(body),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(sheetContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PaywallScreen(source: source)),
                );
              },
              icon: const Icon(Icons.workspace_premium),
              label: Text(l.menuPremium),
            ),
            TextButton(
              onPressed: () => Navigator.pop(sheetContext),
              child: Text(l.commonLater),
            ),
          ],
        ),
      ),
    ),
  );
}
