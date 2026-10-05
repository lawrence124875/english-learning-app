import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../data/sources/ads_service.dart';

/// 免費版主畫面底部常駐的橫幅廣告。
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    // 第十七版：廣告 SDK 要等使用者同意（UMP）後才初始化，就緒時才載入。
    if (AdsService.sdkReady.value) {
      _loadBanner();
    } else {
      AdsService.sdkReady.addListener(_onSdkReady);
    }
  }

  void _onSdkReady() {
    if (!AdsService.sdkReady.value || !mounted) return;
    AdsService.sdkReady.removeListener(_onSdkReady);
    _loadBanner();
  }

  void _loadBanner() {
    if (_bannerAd != null) return;
    _bannerAd = BannerAd(
      adUnitId: AdsService.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    AdsService.sdkReady.removeListener(_onSdkReady);
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) return const SizedBox.shrink();
    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
