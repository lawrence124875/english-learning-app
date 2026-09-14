import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob 廣告服務。
/// - Rewarded Ad：使用者主動觀看以換取額外解鎖額度。
/// - Interstitial Ad：免費版每輪播完自動顯示一次。
/// - Banner Ad：免費版主畫面底部常駐顯示。
///
/// 正式廣告單元 ID 透過 --dart-define 在編譯時期注入（見 CI），
/// 沒有注入時會退回 Google 官方測試版位 ID，方便本機開發測試。
class AdsService {
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
    _preloadInterstitial();
  }

  static const _rewardedAdUnitId = String.fromEnvironment(
    'ADMOB_REWARDED_AD_UNIT_ID',
    defaultValue: 'ca-app-pub-3940256099942544/5224354917',
  );
  static const _interstitialAdUnitId = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_AD_UNIT_ID',
    defaultValue: 'ca-app-pub-3940256099942544/1033173712',
  );
  static const bannerAdUnitId = String.fromEnvironment(
    'ADMOB_BANNER_AD_UNIT_ID',
    defaultValue: 'ca-app-pub-3940256099942544/6300978111',
  );

  static RewardedAd? _rewardedAd;
  static InterstitialAd? _interstitialAd;

  static Future<void> loadRewardedAd({
    required void Function() onLoaded,
    required void Function() onFailed,
  }) async {
    await RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
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

  static void _preloadInterstitial() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _preloadInterstitial(); // 提前準備好下一次要顯示的插頁廣告。
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              _preloadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  /// 顯示插頁廣告；如果還沒載入完成就靜默略過（不強迫等待，避免打斷使用體驗）。
  static void showInterstitialAd() {
    final ad = _interstitialAd;
    if (ad == null) return;
    ad.show();
  }
}

