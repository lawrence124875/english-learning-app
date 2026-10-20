import 'dart:async';
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

  /// 個人專屬編譯開關：只有透過另外那支「個人版建置」workflow 手動
  /// 觸發、明確傳入 FORCE_PREMIUM=true 時才會生效，一般正式上架用的
  /// 編譯流程完全不會用到這個旗標，預設是 false。
  static const _forcePremium =
      bool.fromEnvironment('FORCE_PREMIUM', defaultValue: false);

  /// 目前使用者是否為 Premium 訂閱戶。
  static Future<bool> isPremium() async {
    if (_forcePremium) return true;
    try {
      // 開機時 AppState.initialize() 會等這一步；Play 帳單服務或網路沒回應時
      // getCustomerInfo() 可能一直不回，畫面就會卡在轉圈圈。逾時先當免費版。
      final info = await Purchases.getCustomerInfo()
          .timeout(const Duration(seconds: 5));
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
      return result.customerInfo.entitlements.active.containsKey(_entitlementId);
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
