import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../../data/sources/ads_service.dart';
import '../screens/paywall_screen.dart';
import '../../l10n/app_localizations.dart';

/// 免費版顯示：目前教材已解鎖數量 / 總數，
/// 提供「看廣告多解鎖20個」與「升級 Premium」兩個入口。
class UnlockBanner extends StatefulWidget {
  const UnlockBanner({super.key});

  @override
  State<UnlockBanner> createState() => _UnlockBannerState();
}

class _UnlockBannerState extends State<UnlockBanner> {
  bool _rewardedReady = false;
  bool _loadingRewarded = false;

  @override
  void initState() {
    super.initState();
    _preloadRewarded();
  }

  void _preloadRewarded() {
    setState(() => _loadingRewarded = true);
    AdsService.loadRewardedAd(
      onLoaded: () {
        if (mounted) setState(() {
          _rewardedReady = true;
          _loadingRewarded = false;
        });
      },
      onFailed: () {
        if (mounted) setState(() {
          _rewardedReady = false;
          _loadingRewarded = false;
        });
      },
    );
  }

  Future<void> _watchRewarded(AppState appState) async {
    final earned = await AdsService.showRewardedAd();
    if (earned) {
      await appState.unlockMoreViaRewardedAd();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.unlockRewardSnackbar)),
        );
      }
    }
    setState(() => _rewardedReady = false);
    _preloadRewarded();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final l = AppLocalizations.of(context)!;
    if (appState.isPremium || appState.currentDatasetFullyUnlocked) {
      return const SizedBox.shrink();
    }

    final unlocked = appState.unlockedCount(appState.currentDataset);
    final total = appState.currentDataset.items.length;

    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.unlockFreeProgress(unlocked, total),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _rewardedReady
                        ? () => _watchRewarded(appState)
                        : null,
                    icon: const Icon(Icons.play_circle_outline),
                    label: Text(_loadingRewarded ? l.unlockAdLoading : l.unlockWatchAd),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PaywallScreen()),
                    ),
                    icon: const Icon(Icons.workspace_premium),
                    label: Text(l.menuPremium),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
