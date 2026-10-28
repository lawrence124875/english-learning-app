import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_state.dart';
import '../../data/sources/ads_service.dart';
import '../../data/sources/analytics_service.dart';
import '../../data/sources/paywall_offer.dart';
import '../../l10n/app_localizations.dart';

/// 訂閱付費頁面：顯示方案、目前訂閱狀態、恢復購買按鈕。
/// v24：方案改成可選卡片＋一顆購買按鈕，年繳預設選取並標示每月約多少；
/// RevenueCat 方案有免費試用時顯示「免費試用 N 天，之後 …」與取消說明。
class PaywallScreen extends StatefulWidget {
  /// 從哪裡打開（記在 paywall_view 的 source）：menu、unlock、starred、pe…
  final String source;

  const PaywallScreen({super.key, this.source = 'other'});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  Offerings? _offerings;
  bool _loading = true;
  bool _purchasing = false;
  Package? _selected;

  /// Google Play 的「付款和訂閱」管理頁。使用者要取消訂閱時，
  /// 一定得在這裡操作（App 本身無法替使用者取消），
  /// Google Play 政策也要求 App 內提供明確的取消入口。
  static const _manageSubscriptionUrl =
      'https://play.google.com/store/account/subscriptions?package=tw.bcc.englishapp';

  @override
  void initState() {
    super.initState();
    AnalyticsService.paywallView(widget.source);
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    Offerings? offerings;
    try {
      offerings = await Purchases.getOfferings();
    } catch (_) {
      // 網路異常或 RevenueCat 尚未設定好時，顯示「目前沒有可用方案」即可。
    }
    if (!mounted) return;
    final packages = offerings?.current?.availablePackages ?? const <Package>[];
    setState(() {
      _offerings = offerings;
      _selected = PaywallOffer.defaultPackage(packages);
      _loading = false;
    });
  }

  Future<void> _purchase(Package package) async {
    final l = AppLocalizations.of(context)!;
    setState(() => _purchasing = true);
    final appState = context.read<AppState>();
    final success = await appState.purchasePremiumPackage(package);
    if (!mounted) return;
    setState(() => _purchasing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              success ? l.paywallPurchaseSuccess : l.paywallPurchaseFailed)),
    );
    if (success) Navigator.pop(context);
  }

  Future<void> _restore() async {
    final l = AppLocalizations.of(context)!;
    final appState = context.read<AppState>();
    final restored = await appState.restorePremium();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              restored ? l.paywallRestoreSuccess : l.paywallRestoreNotFound)),
    );
    if (restored) Navigator.pop(context);
  }

  Future<void> _openManageSubscription() async {
    final uri = Uri.parse(_manageSubscriptionUrl);
    AdsService.skipNextAppOpenAd();
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l.menuPremium)),
      body: appState.isPremium
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l.paywallAlreadyPremium,
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: _openManageSubscription,
                      icon: const Icon(Icons.manage_accounts_outlined),
                      label: Text(l.paywallManageSubscription),
                    ),
                  ],
                ),
              ),
            )
          : _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      l.paywallHeadline,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _BenefitRow(text: l.paywallBenefitAllContent),
                    _BenefitRow(text: l.paywallBenefitNoAds),
                    _BenefitRow(text: l.paywallBenefitBackground),
                    const SizedBox(height: 24),
                    ..._buildPackages(l),
                    const SizedBox(height: 8),
                    Text(
                      l.paywallTermsNote,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _restore,
                      child: Text(l.paywallRestoreButton),
                    ),
                    TextButton(
                      onPressed: _openManageSubscription,
                      child: Text(l.paywallManageSubscription),
                    ),
                  ],
                ),
    );
  }

  /// 方案名稱改用 App 自己的多語言文字，而不是直接顯示
  /// storeProduct.title——Google Play 回傳的標題會固定帶上
  /// 「(App 名稱)」後綴，而且語言是後台設定的，不會跟著手機語言走。
  String _planLabel(Package p, AppLocalizations l) {
    switch (p.packageType) {
      case PackageType.monthly:
        return l.paywallPlanMonthly;
      case PackageType.annual:
        return l.paywallPlanAnnual;
      default:
        return p.storeProduct.title;
    }
  }

  List<Widget> _buildPackages(AppLocalizations l) {
    final packages = _offerings?.current?.availablePackages ?? [];
    if (packages.isEmpty) {
      return [Text(l.paywallNoPackages)];
    }
    final selected = _selected ?? packages.first;
    final trialDays = PaywallOffer.trialDays(selected.storeProduct);
    return [
      for (final p in packages) _planTile(p, l, p == selected),
      const SizedBox(height: 4),
      if (trialDays != null) ...[
        Text(
          l.paywallTrialOffer(trialDays, _priceWithPeriod(selected, l)),
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(l.paywallTrialNote,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12.5)),
        const SizedBox(height: 8),
      ],
      FilledButton(
        onPressed: _purchasing ? null : () => _purchase(selected),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(trialDays != null ? l.paywallStartTrial : l.paywallContinue),
        ),
      ),
    ];
  }

  String _priceWithPeriod(Package p, AppLocalizations l) =>
      '${p.storeProduct.priceString} (${_planLabel(p, l)})';

  Widget _planTile(Package p, AppLocalizations l, bool isSelected) {
    final scheme = Theme.of(context).colorScheme;
    final perMonth = p.packageType == PackageType.annual
        ? PaywallOffer.monthlyOfAnnual(p.storeProduct)
        : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
              color: isSelected ? scheme.primary : scheme.outlineVariant,
              width: isSelected ? 2 : 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _purchasing ? null : () => setState(() => _selected = p),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isSelected ? scheme.primary : null),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_planLabel(p, l),
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      if (perMonth != null)
                        Text(l.paywallAnnualPerMonth(perMonth),
                            style: TextStyle(
                                fontSize: 12.5, color: scheme.primary)),
                    ],
                  ),
                ),
                Text(p.storeProduct.priceString,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final String text;
  const _BenefitRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
