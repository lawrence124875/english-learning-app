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

  /// 年繳換算的每月價格字串（例如 NT$999/年 → 「NT$83」）。
  /// 以 priceString 的貨幣符號為準，整數幣別（TWD、JPY 等）不顯示小數。
  static String? monthlyOfAnnual(StoreProduct product) {
    if (product.price <= 0) return null;
    final perMonth = product.price / 12;
    final symbol = _currencyPrefix(product.priceString);
    final noDecimals = _zeroDecimalCurrencies.contains(product.currencyCode) ||
        !product.priceString.contains(RegExp(r'[.,]\d{2}\b'));
    final amount = noDecimals
        ? perMonth.round().toString()
        : ((perMonth * 100).floor() / 100).toStringAsFixed(2);
    return symbol == null ? '$amount ${product.currencyCode}' : '$symbol$amount';
  }

  /// priceString 數字前面的貨幣符號（例如「NT$」「$」「¥」）；在後面時回傳 null。
  static String? _currencyPrefix(String priceString) {
    final m = RegExp(r'^([^\d\s]+)\s?').firstMatch(priceString.trim());
    return m?.group(1);
  }

  static const _zeroDecimalCurrencies = {
    'TWD', 'JPY', 'KRW', 'VND', 'IDR', 'CLP', 'HUF', 'COP',
  };
}
