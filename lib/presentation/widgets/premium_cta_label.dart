import 'package:flutter/material.dart';
import '../../data/sources/paywall_offer.dart';
import '../../l10n/app_localizations.dart';

/// 升級按鈕的文字：方案有免費試用時顯示「開始免費試用」，
/// 否則（或還讀不到）顯示「升級 Premium」。
class PremiumCtaLabel extends StatelessWidget {
  const PremiumCtaLabel({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return FutureBuilder<int?>(
      future: PaywallOffer.defaultTrialDays(),
      builder: (_, snap) =>
          Text(snap.data != null ? l.paywallStartTrial : l.menuPremium),
    );
  }
}
