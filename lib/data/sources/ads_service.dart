import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'analytics_service.dart';

/// AdMob 廣告服務。
/// - Rewarded Ad：使用者主動觀看以換取額外解鎖額度。
/// - Interstitial Ad：免費版每輪播完顯示一次，**只在 App 位於前景時顯示**。
///   使用者多半鎖屏/背景收聽，這時播完一輪只記下「待顯示」，等使用者
///   回到 App 才顯示（AdMob 政策禁止在背景或 App 外跳出廣告）。
/// - App Open Ad：從背景切回 App 時顯示（見 [_onResumed] 的條件）。
/// - Banner Ad：免費版主畫面底部常駐顯示。
///
/// 所有全螢幕廣告（插頁、開啟應用程式、獎勵）共用頻率控制：
/// 同一時間只會有一個全螢幕廣告，且兩次自動跳出的廣告至少間隔
/// [_minGapBetweenFullScreenAds]。
///
/// 正式廣告單元 ID 透過 --dart-define 在編譯時期注入（見 CI），
/// 沒有注入時會退回 Google 官方測試版位 ID，方便本機開發測試。
///
/// 第十七版：歐洲等地區的使用者同意（Google UMP，AdMob「LC Lab GDPR」訊息）。
/// 啟動時只掛生命週期監聽，**不初始化廣告 SDK**；AppState 確認不是 Premium 後
/// 呼叫 [startConsentAndAds]：先請求同意資訊、需要時顯示同意表單，
/// `canRequestAds()` 為 true 才初始化 MobileAds 並開始載入廣告。
class AdsService {
  static Future<void> initialize() async {
    WidgetsBinding.instance.addObserver(_AdLifecycleObserver());
  }

  /// 廣告 SDK 已初始化（已取得同意或該地區不需同意）。橫幅與獎勵廣告要等它。
  static final ValueNotifier<bool> sdkReady = ValueNotifier(false);

  /// 是否需要在選單提供「廣告隱私設定」（歐洲等需要同意的地區才為 true）。
  static bool privacyOptionsRequired = false;

  static bool _consentStarted = false;

  /// 免費版才呼叫（AppState 確認不是 Premium 後）；只會執行一次。
  /// 同意流程失敗或逾時不影響 App，只是這次不初始化廣告（除非 canRequestAds
  /// 已經是 true，例如上次已同意）。
  static Future<void> startConsentAndAds() async {
    if (_consentStarted) return;
    _consentStarted = true;
    try {
      await _gatherConsent().timeout(const Duration(seconds: 15));
    } catch (e) {
      debugPrint('廣告同意流程失敗：$e');
    }
    try {
      if (await ConsentInformation.instance.canRequestAds()) await _startSdk();
    } catch (e) {
      debugPrint('AdMob 初始化失敗，不顯示廣告：$e');
    }
  }

  static Future<void> _gatherConsent() {
    final done = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () => ConsentForm.loadAndShowConsentFormIfRequired((FormError? e) async {
        await _refreshPrivacyRequirement();
        if (!done.isCompleted) done.complete();
      }),
      (FormError e) {
        if (!done.isCompleted) done.complete();
      },
    );
    return done.future;
  }

  static Future<void> _refreshPrivacyRequirement() async {
    try {
      privacyOptionsRequired = await ConsentInformation.instance
              .getPrivacyOptionsRequirementStatus() ==
          PrivacyOptionsRequirementStatus.required;
    } catch (_) {}
  }

  static Future<void> _startSdk() async {
    if (sdkReady.value) return;
    await MobileAds.instance.initialize();
    sdkReady.value = true;
    _preloadInterstitial();
    _preloadAppOpen();
  }

  /// 選單「廣告隱私設定」：重新顯示 UMP 隱私選項表單，讓使用者修改或撤回同意。
  static Future<void> showPrivacyOptions() async {
    final done = Completer<void>();
    ConsentForm.showPrivacyOptionsForm((FormError? e) async {
      try {
        if (await ConsentInformation.instance.canRequestAds()) {
          await _startSdk();
        }
      } catch (_) {}
      await _refreshPrivacyRequirement();
      if (!done.isCompleted) done.complete();
    });
    return done.future;
  }

  static const _rewardedAdUnitId = String.fromEnvironment(
    'ADMOB_REWARDED_AD_UNIT_ID',
    defaultValue: 'ca-app-pub-3940256099942544/5224354917',
  );
  static const _interstitialAdUnitId = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_AD_UNIT_ID',
    defaultValue: 'ca-app-pub-3940256099942544/1033173712',
  );
  /// 開啟應用程式廣告單元。GitHub Secrets 還沒設定 ADMOB_APP_OPEN_AD_UNIT_ID
  /// 時，CI 會傳入空字串，這時退回 Google 官方測試 ID。
  static const _appOpenAdUnitIdFromEnv =
      String.fromEnvironment('ADMOB_APP_OPEN_AD_UNIT_ID');
  static const _appOpenAdUnitId = _appOpenAdUnitIdFromEnv == ''
      ? 'ca-app-pub-3940256099942544/9257395921'
      : _appOpenAdUnitIdFromEnv;
  static const bannerAdUnitId = String.fromEnvironment(
    'ADMOB_BANNER_AD_UNIT_ID',
    defaultValue: 'ca-app-pub-3940256099942544/6300978111',
  );

  // --- 頻率控制參數 ---
  /// 任兩次「自動跳出」的全螢幕廣告之間的最短間隔。
  static const _minGapBetweenFullScreenAds = Duration(minutes: 3);

  /// 開啟應用程式廣告：每 1 小時最多一次。
  static const _appOpenMinInterval = Duration(hours: 1);

  /// 開啟應用程式廣告：離開 App 超過這個時間才顯示
  /// （避免只是切出去回個訊息就跳廣告）。
  static const _appOpenMinAway = Duration(seconds: 30);

  /// App Open 廣告載入後 4 小時會過期（Google 規定），過期要重新載入。
  static const _appOpenAdExpiry = Duration(hours: 4);

  /// 是否允許顯示自動跳出的廣告。預設關閉，等 AppState 向 RevenueCat
  /// 確認「不是 Premium」之後才開啟，避免訂閱戶在啟動初期看到廣告。
  static bool adsEnabled = false;

  static RewardedAd? _rewardedAd;
  static InterstitialAd? _interstitialAd;
  static AppOpenAd? _appOpenAd;
  static DateTime? _appOpenLoadedAt;
  static bool _appOpenLoading = false;

  static bool _fullScreenAdShowing = false;
  static DateTime? _lastFullScreenAdAt;
  static DateTime? _lastAppOpenAdAt;
  static DateTime? _wentBackgroundAt;
  static bool _pendingInterstitial = false;
  static bool _skipNextAppOpen = false;

  static bool get _inForeground =>
      WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;

  static bool get _gapSatisfied {
    final last = _lastFullScreenAdAt;
    return last == null ||
        DateTime.now().difference(last) >= _minGapBetweenFullScreenAds;
  }

  static void _markShowing() {
    _fullScreenAdShowing = true;
  }

  static void _markDismissed() {
    _fullScreenAdShowing = false;
    _lastFullScreenAdAt = DateTime.now();
  }

  /// 使用者接下來要主動離開 App 去做別的事（Google Play 付款、選檔案、
  /// 開瀏覽器、系統設定頁、App 更新）時呼叫：回來時不要跳開啟應用程式廣告。
  static void skipNextAppOpenAd() {
    _skipNextAppOpen = true;
  }

  // ---------------- 獎勵廣告 ----------------

  static Future<void> loadRewardedAd({
    required void Function() onLoaded,
    required void Function() onFailed,
  }) async {
    if (!sdkReady.value) {
      onFailed();
      return;
    }
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
    if (ad == null || _fullScreenAdShowing) return false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) => _markShowing(),
      onAdDismissedFullScreenContent: (ad) {
        _markDismissed();
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _fullScreenAdShowing = false;
        ad.dispose();
      },
    );
    // 在 show() 之前就標記，避免廣告畫面蓋上來造成的生命週期變化
    // 被誤判成「使用者離開 App」。
    _markShowing();
    var earnedReward = false;
    await ad.show(
      onUserEarnedReward: (ad, reward) {
        earnedReward = true;
      },
    );
    _rewardedAd = null;
    if (earnedReward) AnalyticsService.rewardedAdWatch();
    return earnedReward;
  }

  // ---------------- 插頁廣告 ----------------

  static void _preloadInterstitial() {
    if (!sdkReady.value) return;
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) => _markShowing(),
            onAdDismissedFullScreenContent: (ad) {
              _markDismissed();
              ad.dispose();
              _interstitialAd = null;
              _preloadInterstitial(); // 提前準備好下一次要顯示的插頁廣告。
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              _fullScreenAdShowing = false;
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

  /// 立即嘗試顯示插頁廣告（必須在前景、符合間隔、沒有其他全螢幕廣告）。
  /// 回傳是否真的顯示了。還沒載入完成就靜默略過，不強迫等待。
  static bool _tryShowInterstitial() {
    if (!adsEnabled || !_inForeground || _fullScreenAdShowing) return false;
    if (!_gapSatisfied) return false;
    final ad = _interstitialAd;
    if (ad == null) return false;
    _markShowing();
    ad.show();
    return true;
  }

  /// 一輪播完時呼叫。在前景就直接顯示；在背景（鎖屏收聽）就記下來，
  /// 等使用者回到 App 再顯示。待顯示最多只累積一則。
  static void onRoundComplete() {
    if (!adsEnabled) return;
    if (_inForeground) {
      _tryShowInterstitial();
    } else {
      _pendingInterstitial = true;
    }
  }

  // ---------------- 開啟應用程式廣告 ----------------

  static bool get _appOpenAvailable {
    final loadedAt = _appOpenLoadedAt;
    return _appOpenAd != null &&
        loadedAt != null &&
        DateTime.now().difference(loadedAt) < _appOpenAdExpiry;
  }

  static void _preloadAppOpen() {
    if (!sdkReady.value || _appOpenLoading || _appOpenAvailable) return;
    _appOpenLoading = true;
    AppOpenAd.load(
      adUnitId: _appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenLoading = false;
          _appOpenAd = ad;
          _appOpenLoadedAt = DateTime.now();
        },
        onAdFailedToLoad: (error) {
          _appOpenLoading = false;
          _appOpenAd = null;
        },
      ),
    );
  }

  static bool _tryShowAppOpen() {
    if (!adsEnabled || _fullScreenAdShowing || !_gapSatisfied) return false;
    final lastAppOpen = _lastAppOpenAdAt;
    if (lastAppOpen != null &&
        DateTime.now().difference(lastAppOpen) < _appOpenMinInterval) {
      return false;
    }
    if (!_appOpenAvailable) {
      // 過期或還沒載入：丟掉舊的、重新載入，這次就不顯示。
      _appOpenAd?.dispose();
      _appOpenAd = null;
      _preloadAppOpen();
      return false;
    }
    final ad = _appOpenAd!;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) => _markShowing(),
      onAdDismissedFullScreenContent: (ad) {
        _markDismissed();
        ad.dispose();
        _appOpenAd = null;
        _preloadAppOpen();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _fullScreenAdShowing = false;
        ad.dispose();
        _appOpenAd = null;
        _preloadAppOpen();
      },
    );
    _markShowing();
    _lastAppOpenAdAt = DateTime.now();
    ad.show();
    return true;
  }

  // ---------------- 生命週期 ----------------

  static void _onPaused() {
    // 全螢幕廣告本身會蓋住 App 造成 paused，那不算使用者離開。
    if (_fullScreenAdShowing) return;
    _wentBackgroundAt ??= DateTime.now();
  }

  /// 回到前景時，最多只顯示一則全螢幕廣告：
  /// 1. 有待顯示的插頁廣告（背景時播完一輪）→ 顯示插頁廣告
  /// 2. 否則，符合條件就顯示開啟應用程式廣告：離開超過 30 秒、
  ///    距上次開啟應用程式廣告超過 1 小時、距上次全螢幕廣告超過 3 分鐘。
  /// 冷啟動不會觸發（沒有「離開」紀錄），所以一打開 App 不會有廣告。
  static void _onResumed() {
    final wentAt = _wentBackgroundAt;
    _wentBackgroundAt = null;
    if (_fullScreenAdShowing) return;
    final skip = _skipNextAppOpen;
    _skipNextAppOpen = false;
    if (!adsEnabled) {
      _pendingInterstitial = false;
      return;
    }

    if (_pendingInterstitial) {
      _pendingInterstitial = false;
      if (_tryShowInterstitial()) return;
    }

    if (skip || wentAt == null) return;
    if (DateTime.now().difference(wentAt) < _appOpenMinAway) return;
    _tryShowAppOpen();
  }
}

class _AdLifecycleObserver with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      AdsService._onPaused();
    } else if (state == AppLifecycleState.resumed) {
      AdsService._onResumed();
    }
  }
}
