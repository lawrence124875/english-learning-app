import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../../data/sources/ads_service.dart';
import '../screens/paywall_screen.dart';
import '../../l10n/app_localizations.dart';
import '../app_theme.dart';

/// 免費版顯示：目前教材已解鎖數量 / 總數。
/// 0.3.0 起縮成一行＋「解鎖更多」按鈕，點開再選「看廣告 +20」或
/// 「升級 Premium」，讓首頁視覺集中在單字上。
class UnlockBanner extends StatefulWidget {
  const UnlockBanner({super.key});

  @override
  State<UnlockBanner> createState() => _UnlockBannerState();
}

class _UnlockBannerState extends State<UnlockBanner> {
  bool _rewardedReady = false;
  bool _loadingRewarded = false;

  /// 底部選單打開時也要即時反映廣告是否載入完成。
  final _sheetRefresh = ValueNotifier<int>(0);

  @override
  void dispose() {
    _sheetRefresh.dispose();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    _sheetRefresh.value++;
  }

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
    if (!mounted) return;
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
    final palette = AppPalette.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: palette.softRow,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 10, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(l.unlockFreeProgress(unlocked, total),
                    style: const TextStyle(fontSize: 13.5)),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => _showOptions(appState, unlocked, total),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: const StadiumBorder(),
                ),
                child: Text(l.unlockMoreButton,
                    style: const TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptions(AppState appState, int unlocked, int total) {
    final l = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: ValueListenableBuilder<int>(
            valueListenable: _sheetRefresh,
            builder: (_, __, ___) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.unlockFreeProgress(unlocked, total),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _rewardedReady
                      ? () {
                          Navigator.pop(sheetContext);
                          _watchRewarded(appState);
                        }
                      : null,
                  icon: const Icon(Icons.play_circle_outline),
                  label: Text(
                      _loadingRewarded ? l.unlockAdLoading : l.unlockWatchAd),
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PaywallScreen()),
                    );
                  },
                  icon: const Icon(Icons.workspace_premium),
                  label: Text(l.menuPremium),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
