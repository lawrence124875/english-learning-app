import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';

/// 複習提醒的本地通知服務。
/// 使用者可以設定一個每天固定的提醒時間，App 會在那個時間跳出通知，
/// 提醒回來複習今天標記的不熟悉單字。
class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static const _reminderId = 1001;

  static Future<void> initialize() async {
    tz_data.initializeTimeZones();

    // 關鍵：tz.local 預設是 UTC，一定要明確設成裝置實際時區，
    // 否則排程時間會整個對不起來（例如設定晚上8點，實際排到隔天凌晨）。
    try {
      final deviceTimezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(deviceTimezone));
    } catch (_) {
      // 抓不到裝置時區時的保底，至少不要整個初始化失敗。
      tz.setLocalLocation(tz.getLocation('Asia/Taipei'));
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);

    const channel = AndroidNotificationChannel(
      'tw.bcc.englishapp.reminder',
      '複習提醒',
      description: '每日英文複習提醒通知',
      importance: Importance.defaultImportance,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<bool> requestPermission() async {
    final granted = await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    return granted ?? false;
  }

  /// 排程每天固定時間的複習提醒（[hour]/[minute] 為 24 小時制）。
  static Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      _reminderId,
      '該複習英文囉！',
      '回來聽幾個單字，鞏固今天學到的內容吧',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'tw.bcc.englishapp.reminder',
          '複習提醒',
          importance: Importance.defaultImportance,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // 每天同一時間重複。
    );
  }

  static Future<void> cancelReminder() async {
    await _plugin.cancel(_reminderId);
  }

  /// 跳出系統對話框，請使用者把這個 App 排除在電池優化限制之外。
  /// 很多廠牌（小米/OPPO/Vivo等）的省電機制會讓排程好的通知延遲或完全
  /// 不觸發，這是解決「提醒時間到卻沒跳出來」最有效的做法。
  /// 依 Google Play 政策，這個權限只能透過使用者主動點擊觸發，
  /// 不能在 App 啟動時自動跳出來要求。
  static Future<void> requestIgnoreBatteryOptimizations() async {
    final status = await Permission.ignoreBatteryOptimizations.status;
    if (!status.isGranted) {
      await Permission.ignoreBatteryOptimizations.request();
    }
  }
}
