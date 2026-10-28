import 'package:purchases_flutter/purchases_flutter.dart';

/// 付費牆顯示用的方案資訊（免費試用天數、年繳換算每月價）。
/// 只讀 RevenueCat 回傳的商品資料，不另外設定價格。
class PaywallOffer {
  /// 預設選取年繳；沒有年繳就選第一個。
  static Package? defaultPackage(List<Package> packages) {
    if (packages.isEmpty) return null;
    for (final p in packages) {
      if (p.packageType == PackageType.annual) return p;
    }
    return packages.first;
  }

  /// 方案的免費試用天數；沒有試用優惠時回傳 null。
  /// Android 讀預設方案的 freePhase；iOS 讀 introductoryPrice（價格 0）。
  static int? trialDays(StoreProduct product) {
    final free = product.defaultOption?.freePhase?.billingPeriod;
    if (free != null) return _days(free.unit, free.value);
    final intro = product.introductoryPrice;
    if (intro != null && intro.price == 0) {
      return _days(intro.periodUnit, intro.periodNumberOfUnits * intro.cycles);
    }
    return null;
  }

  static int? _days(PeriodUnit unit, int value) {
    if (value <= 0) return null;
    switch (unit) {
      case PeriodUnit.day:
        return value;
      case PeriodUnit.week:
        return value * 7;
      case PeriodUnit.month:
        return value * 30;
      case PeriodUnit.year:
        return value * 365;
      default:
        return null;
    }
  }

  /// 年繳換算的每月價格：直接用 RevenueCat 回傳的當地字串
  /// （pricePerMonthString），不自行換算、不寫死幣別；沒有就不顯示。
  static String? monthlyOfAnnual(StoreProduct product) {
    final s = product.pricePerMonthString;
    return (s == null || s.isEmpty) ? null : s;
  }
}
