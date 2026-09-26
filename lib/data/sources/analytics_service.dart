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

  static void paywallView() => _log('paywall_view');

  static void purchaseStart(String packageId) =>
      _log('purchase_start', {'package_id': packageId});

  static void purchaseSuccess(String packageId) =>
      _log('purchase_success', {'package_id': packageId});

  static void rewardedAdWatch() => _log('rewarded_ad_watch');

  static void importCsv(int itemCount) =>
      _log('import_csv', {'item_count': itemCount});
}
