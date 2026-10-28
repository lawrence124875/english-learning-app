import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../../data/sources/ads_service.dart';
import '../../data/sources/analytics_service.dart';
import '../screens/paywall_screen.dart';
import '../../l10n/app_localizations.dart';
import '../app_theme.dart';

/// 免費版顯示：目前教材已解鎖數量 / 總數。
/// 0.3.0 起縮成一行＋「解鎖更多」按鈕，點開再選「看廣告 +20」或
/// 「升級 Premium」，讓首頁視覺集中在單字上。
/// v24：看廣告每日 3 次、當天有效；廣告載入失敗或無填充時仍給該次解鎖。
class UnlockBanner extends StatefulWidget {
  const UnlockBanner({super.key});

  @override
  State<UnlockBanner> createState() => _UnlockBannerState();
}

class _UnlockBannerState extends State<UnlockBanner> {
  bool _loadingRewarded = false;

  /// 無填充時 AdMob 有時很久才回失敗；超過這個時間就不再等，按了直接給解鎖。
  Timer? _loadTimeout;

  /// 底部選單打開時也要即時反映廣告是否載入完成。
  final _sheetRefresh = ValueNotifier<int>(0);

  @override
  void dispose() {
    _loadTimeout?.cancel();
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
    if (AdsService.rewardedReady) return;
    setState(() => _loadingRewarded = true);
    void done() {
      _loadTimeout?.cancel();
      if (mounted) setState(() => _loadingRewarded = false);
    }

    _loadTimeout?.cancel();
    _loadTimeout = Timer(const Duration(seconds: 8), done);
    AdsService.loadRewardedAd(onLoaded: done, onFailed: done);
  }

  Future<void> _watchRewarded(AppState appState) async {
    final result = await AdsService.showRewardedAd();
    // 看完 → 解鎖；廣告沒載到（無填充／失敗）或播放失敗 → 仍給該次解鎖；
    // 只有使用者自己中途關掉才不給。
    if (result == RewardedAdResult.notReady) {
      AnalyticsService.rewardedAdFailed('not_ready');
    } else if (result == RewardedAdResult.failed) {
      AnalyticsService.rewardedAdFailed('show_failed');
    }
    if (result != RewardedAdResult.dismissed &&
        await appState.unlockMoreViaRewardedAd() &&
        mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.unlockRewardSnackbar)),
      );
    }
    if (!mounted) return;
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
                if (appState.rewardedUsesLeft > 0) ...[
                  OutlinedButton.icon(
                    onPressed: _loadingRewarded
                        ? null
                        : () {
                            Navigator.pop(sheetContext);
                            _watchRewarded(appState);
                          },
                    icon: const Icon(Icons.play_circle_outline),
                    label: Text(_loadingRewarded
                        ? l.unlockAdLoading
                        : l.unlockWatchAdLeft(appState.rewardedUsesLeft)),
                  ),
                  const SizedBox(height: 6),
                  Text(l.unlockTodayOnly,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ] else
                  Text(l.unlockDailyLimitReached),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const PaywallScreen(source: 'unlock')),
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
