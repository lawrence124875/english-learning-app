import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

/// Google Play「應用程式內更新」。
///
/// 開啟 App 時檢查 Play 商店是否有新版：
/// - 一般更新（彈性更新）：跳出 Google Play 的更新提示，使用者同意後
///   在背景下載，下載完成再由畫面提示「重新啟動」套用，不打斷正在聽的內容。
/// - 重大更新（強制更新）：版本的「更新優先順序」設為 4 以上時，
///   直接顯示全螢幕更新畫面，必須更新才能繼續使用。
///   更新優先順序要在上傳版本時透過 Google Play Developer API 設定
///   （inAppUpdatePriority，0~5），Play Console 網頁上沒有這個欄位；
///   沒設定就是 0，一律走一般更新。
///
/// 只有從 Google Play 安裝的 App 才有作用；手動安裝的 APK、
/// 模擬器或沒有 Play 商店的手機會直接略過，不會影響 App 使用。
class UpdateService {
  static const _forceUpdatePriority = 4;

  /// 檢查並處理更新。回傳 true 代表彈性更新已下載完成，
  /// 呼叫端應提示使用者重新啟動（呼叫 [completeFlexibleUpdate]）。
  static Future<bool> checkForUpdate() async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability != UpdateAvailability.updateAvailable) {
        return false;
      }
      if (info.updatePriority >= _forceUpdatePriority &&
          info.immediateUpdateAllowed) {
        await InAppUpdate.performImmediateUpdate();
        return false;
      }
      if (info.flexibleUpdateAllowed) {
        final result = await InAppUpdate.startFlexibleUpdate();
        return result == AppUpdateResult.success;
      }
    } catch (e) {
      debugPrint('檢查更新略過：$e');
    }
    return false;
  }

  /// 套用已下載的彈性更新（App 會重新啟動）。
  static Future<void> completeFlexibleUpdate() async {
    try {
      await InAppUpdate.completeFlexibleUpdate();
    } catch (e) {
      debugPrint('套用更新失敗：$e');
    }
  }
}
