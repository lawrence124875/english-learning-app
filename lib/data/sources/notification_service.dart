import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// 複習提醒的本地通知服務。
/// 使用者可以設定一個每天固定的提醒時間，App 會在那個時間跳出通知，
/// 提醒回來複習今天標記的不熟悉單字。
class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static const _reminderId = 1001;

  static Future<void> initialize() async {
    tz_data.initializeTimeZones();
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
      matchDateTimeComponents: DateTimeComponents.time, // 每天同一時間重複。
    );
  }

  static Future<void> cancelReminder() async {
    await _plugin.cancel(_reminderId);
  }
}
