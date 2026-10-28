import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'background_l10n.dart';

/// Firebase Analytics 事件紀錄。
///
/// 目的：比較各語言/國家的留存與付費轉換，作為第三階段語言與
/// 定價調整的依據。只記錄「行為次數」與教材代號，不記錄任何
/// 可識別個人的內容（例如自訂教材的名稱或單字內容）。
///
/// 所有方法都包 try-catch：Firebase 沒初始化成功（例如 google-services
/// 設定缺失）時靜默略過，絕不影響 App 正常使用。
class AnalyticsService {
  static FirebaseAnalytics? get _fa {
    try {
      return FirebaseAnalytics.instance;
    } catch (_) {
      return null;
    }
  }

  static Future<void> _log(String name, [Map<String, Object>? params]) async {
    try {
      await _fa?.logEvent(name: name, parameters: params);
    } catch (e) {
      debugPrint('Analytics 事件略過（$name）：$e');
    }
  }

  /// 自訂教材的 id 含有時間戳記，統一記成 "custom"，避免產生大量不同值。
  static String _datasetKey(String datasetId) =>
      datasetId.startsWith('custom_') ? 'custom' : datasetId;

  /// App 啟動時呼叫：記錄介面語言（使用者屬性，可在後台依語言分群比較）。
  static Future<void> setUserProperties({required bool isPremium}) async {
    try {
      await _fa?.setUserProperty(
          name: 'ui_language', value: BackgroundL10n.translationKey());
      await _fa?.setUserProperty(
          name: 'is_premium', value: isPremium ? 'true' : 'false');
    } catch (e) {
      debugPrint('Analytics 使用者屬性略過：$e');
    }
  }

  static void playStart(String datasetId) =>
      _log('play_start', {'dataset_id': _datasetKey(datasetId)});

  static void roundComplete(String datasetId, int cycle) => _log(
      'round_complete', {'dataset_id': _datasetKey(datasetId), 'cycle': cycle});

  static void datasetSwitch(String datasetId) =>
      _log('dataset_switch', {'dataset_id': _datasetKey(datasetId)});

  static void starWord(String datasetId) =>
      _log('star_word', {'dataset_id': _datasetKey(datasetId)});

  // --- 免費版轉換漏斗（v24）---

  /// 第一次按播放（只記一次，見 AppState.markFirstPlay）。
  static void firstPlay() => _log('first_play');

  /// 碰到免費版限制：words（免費範圍聽完）／starred（★ 滿 30）／pe（V2 每日 5 句）。
  static void hitFreeLimit(String type) =>
      _log('hit_free_limit', {'type': type});

  static void rewardedAdShown() => _log('rewarded_ad_shown');

  /// 獎勵廣告沒播出（仍給解鎖）：reason = not_ready／show_failed。
  static void rewardedAdFailed(String reason) =>
      _log('rewarded_ad_failed', {'reason': reason});

  /// 付費牆曝光，source = 從哪裡打開（menu、unlock、starred、pe…）。
  static void paywallView(String source) =>
      _log('paywall_view', {'source': source});

  static void purchaseStart(String packageId) =>
      _log('purchase_start', {'package_id': packageId});

  /// 購買成功：保留舊的 purchase_success（既有漏斗延續），另記 purchase。
  static void purchaseSuccess(String packageId) {
    _log('purchase_success', {'package_id': packageId});
    _log('purchase', {'package_id': packageId});
  }

  /// 購買的方案帶免費試用時，購買成功即記 trial_start。
  static void trialStart(String packageId) =>
      _log('trial_start', {'package_id': packageId});

  static void importCsv(int itemCount) =>
      _log('import_csv', {'item_count': itemCount});

  static void shareApp() => _log('share_app');
}
