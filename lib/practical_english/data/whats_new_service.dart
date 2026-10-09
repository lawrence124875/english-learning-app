import 'package:shared_preferences/shared_preferences.dart';

/// What's New 判斷（SPEC §11）。與 App 版本號無關：
/// - `app_schema_version`（int）：這台裝置的資料模型版本。
/// - `last_seen_whats_new_version`（String）：已看過哪一份介紹。
///
/// V1 資料只拿來判斷「是不是 V1 舊使用者」，從不修改。
class WhatsNewService {
  WhatsNewService._();

  static const schemaVersionKey = 'app_schema_version';
  static const lastSeenKey = 'last_seen_whats_new_version';
  static const currentSchemaVersion = 2;
  static const currentWhatsNew = 'pe_2_0';

  /// V1 曾經寫過的 key：任一存在就代表是 V1 使用者升級。
  static const v1EvidenceKeys = ['onboarding_seen_v1', 'settings_v1'];

  /// 每次啟動呼叫一次，回傳這次是否要自動顯示 What's New。
  ///
  /// 必須在 V1 功能介紹（會寫入 `onboarding_seen_v1`）之前呼叫，
  /// 否則全新安裝會被誤判成 V1 使用者。讀寫失敗時不顯示、不丟錯。
  static Future<bool> prepareOnLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey(schemaVersionKey)) {
        final upgradingFromV1 = v1EvidenceKeys.any(prefs.containsKey);
        await prefs.setInt(schemaVersionKey, currentSchemaVersion);
        if (!upgradingFromV1) {
          // 全新安裝：看一般的功能介紹就好。
          await prefs.setString(lastSeenKey, currentWhatsNew);
        }
      }
      return prefs.getString(lastSeenKey) != currentWhatsNew;
    } catch (_) {
      return false;
    }
  }

  /// 顯示前呼叫：先記成已看過，App 中途被關也不會每次都跳出來。
  static Future<void> markSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(lastSeenKey, currentWhatsNew);
    } catch (_) {}
  }
}
