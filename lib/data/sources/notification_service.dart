import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:permission_handler/permission_handler.dart';

/// 複習提醒的本地通知服務。
/// 使用者可以設定一個每天固定的提醒時間，App 會在那個時間跳出通知，
/// 提醒回來複習今天標記的不熟悉單字。
///
/// 時區處理刻意不依賴任何原生外掛（flutter_timezone 等）：
/// 這類套件一路上引發了好幾次跟其他套件版本衝突的編譯錯誤。改用
/// Dart 內建、跨平台原生支援的 DateTime.timeZoneOffset 直接算出裝置
/// 目前的 UTC 偏移量，再手動換算成 TZDateTime，完全不需要額外套件、
/// 也不會再有版本衝突的問題。
class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static const _reminderId = 1001;
  static const _channelId = 'tw.bcc.englishapp.reminder';
  static const _channelName = '複習提醒';

  static Future<void> initialize() async {
    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
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

  /// 把「裝置本地時間的某個時間點」換算成 TZDateTime，
  /// 不透過任何原生外掛查詢時區名稱，直接用 Dart 內建的
  /// DateTime.timeZoneOffset（跨平台原生支援，永遠準確反映裝置目前的
  /// UTC 偏移量，包含日光節約時間）手動計算。
  static tz.TZDateTime _nextInstanceOfLocalTime(int hour, int minute) {
    final nowLocal = DateTime.now();
    final offset = nowLocal.timeZoneOffset;

    var targetLocal =
        DateTime(nowLocal.year, nowLocal.month, nowLocal.day, hour, minute);
    if (targetLocal.isBefore(nowLocal)) {
      targetLocal = targetLocal.add(const Duration(days: 1));
    }

    // 把「裝置本地時間」轉成對應的 UTC 時間點，再包成 TZDateTime(UTC)——
    // 這樣得到的是正確的絕對時間點，不需要知道裝置的 IANA 時區名稱。
    final targetUtc = targetLocal.subtract(offset);
    return tz.TZDateTime.from(targetUtc, tz.UTC);
  }

  /// 排程每天固定時間的複習提醒（[hour]/[minute] 為 24 小時制，裝置本地時間）。
  static Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    final scheduled = _nextInstanceOfLocalTime(hour, minute);

    await _plugin.zonedSchedule(
      _reminderId,
      '該複習英文囉！',
      '回來聽幾個單字，鞏固今天學到的內容吧',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.defaultImportance,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      // 因為排的是 UTC 時間點，這裡比對的「時分」也是 UTC 時分——
      // 只要裝置的 UTC 偏移量不變（台灣沒有日光節約時間，固定 UTC+8），
      // 這樣比對出來的每日重複時間點依然正確對應裝置本地時間。
      matchDateTimeComponents: DateTimeComponents.time,
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
