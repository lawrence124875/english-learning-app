import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob 廣告服務。目前先提供 SDK 初始化與「獎勵廣告」載入邏輯，
/// 實際要在哪些畫面/情境顯示廣告（免費版額度用完後的加速器機制），
/// 待商業模式細節定案後再串進 UI。
class AdsService {
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  /// 目前先用 Google 官方測試版位 ID，等正式要上線廣告時，
  /// 記得去 AdMob 後台為「獎勵廣告」建立正式的廣告單元 ID 換掉這裡。
  static const _testRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  static RewardedAd? _rewardedAd;

  static Future<void> loadRewardedAd({
    required void Function() onLoaded,
    required void Function() onFailed,
  }) async {
    await RewardedAd.load(
      adUnitId: _testRewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          onLoaded();
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          onFailed();
        },
      ),
    );
  }

  static Future<bool> showRewardedAd() async {
    final ad = _rewardedAd;
    if (ad == null) return false;
    var earnedReward = false;
    await ad.show(
      onUserEarnedReward: (ad, reward) {
        earnedReward = true;
      },
    );
    _rewardedAd = null;
    return earnedReward;
  }
}
