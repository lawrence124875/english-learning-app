import 'package:purchases_flutter/purchases_flutter.dart';

/// 訂閱付費狀態管理，包裝 RevenueCat SDK。
/// entitlement 識別碼統一用 "premium"，之後在 RevenueCat 後台
/// 設定訂閱方案時，記得把 Entitlement 也命名為 premium 以對應。
class SubscriptionService {
  static const _entitlementId = 'premium';

  /// 用編譯時期傳入的 API Key 初始化（見 CI 的 --dart-define），
  /// 避免把金鑰寫死在原始碼裡。
  static Future<void> initialize(String apiKey) async {
    if (apiKey.isEmpty) return;
    await Purchases.setLogLevel(LogLevel.info);
    await Purchases.configure(PurchasesConfiguration(apiKey));
  }

  /// 目前使用者是否為 Premium 訂閱戶。
  static Future<bool> isPremium() async {
    try {
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.active.containsKey(_entitlementId);
    } catch (_) {
      return false;
    }
  }

  static Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (_) {
      return null;
    }
  }

  static Future<bool> purchase(Package package) async {
    try {
      final result = await Purchases.purchasePackage(package);
      return result.entitlements.active.containsKey(_entitlementId);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> restorePurchases() async {
    try {
      final info = await Purchases.restorePurchases();
      return info.entitlements.active.containsKey(_entitlementId);
    } catch (_) {
      return false;
    }
  }
}
