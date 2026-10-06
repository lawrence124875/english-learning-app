import 'dart:io';

/// 手機廠牌差異（0.3.1）。
/// 小米／紅米／POCO（MIUI、HyperOS）的鎖屏音樂卡片把封面當「右側小圖」，
/// 一般手機當卡片背景，所以封面圖依廠牌選（見 CoverArt.lockScreen）。
class DeviceQuirks {
  static bool xiaomiFamily = false;

  /// 用 getprop 讀廠牌，不需要原生程式碼；失敗就當一般手機。
  static Future<void> detect() async {
    if (!Platform.isAndroid) return;
    try {
      final r = await Process.run('getprop', ['ro.product.manufacturer'])
          .timeout(const Duration(seconds: 1));
      final maker = (r.stdout as String).trim().toLowerCase();
      xiaomiFamily = const {'xiaomi', 'redmi', 'poco'}.contains(maker);
    } catch (_) {}
  }
}
