import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent_plus/android_intent.dart';

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

  /// 取得目前實際已排程的通知清單，用來確認「排程有沒有真的成功」。
  static Future<List<PendingNotificationRequest>> getPendingReminders() {
    return _plugin.pendingNotificationRequests();
  }

  // --- 久未使用提醒（不提供使用者關閉選項）---
  // 每次 App 啟動時都會呼叫，把這個一次性通知重新排到「3 天後」，
  // 同時取消前一次排的舊排程。只要使用者持續正常使用（3天內都有
  // 打開過），這個通知就永遠不會真的被觸發；只有真的超過3天沒打開，
  // 上一次排的通知才會準時跳出來。
  static const _inactivityReminderId = 1002;

  static Future<void> rescheduleInactivityReminder() async {
    await _plugin.cancel(_inactivityReminderId);

    final now = DateTime.now();
    final target = now.add(const Duration(days: 3));
    final scheduled = tz.TZDateTime.from(
      target.subtract(now.timeZoneOffset),
      tz.UTC,
    );

    await _plugin.zonedSchedule(
      _inactivityReminderId,
      '好久不見 👋',
      '已經好幾天沒複習了，回來聽幾個單字，別讓記憶生疏了',
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
    );
  }

  /// 跳出系統對話框，請使用者把這個 App 排除在電池優化限制之外。
  /// 很多廠牌（小米/OPPO/Vivo等）的省電機制會讓排程好的通知延遲或完全
  /// 不觸發，這是解決「提醒時間到卻沒跳出來」最有效的做法。
  /// 依 Google Play 政策，這個權限只能透過使用者主動點擊觸發，
  /// 不能在 App 啟動時自動跳出來要求。
  ///
  /// 小米 MIUI 系統在標準 Android 電池優化之外，另外疊加了一層自己
  /// 專屬的「省電策略」與「自啟動管理」，標準 Android API 打不開，
  /// 這裡優先嘗試跳轉到 MIUI 專屬設定頁；如果失敗（例如不是小米手機、
  /// 或該頁面在這個 MIUI 版本上不存在），才退回標準 Android 設定頁。
  static Future<void> requestIgnoreBatteryOptimizations() async {
    final openedMiui = await _tryOpenMiuiPowerSettings();
    if (openedMiui) return;

    final status = await Permission.ignoreBatteryOptimizations.status;
    if (status.isGranted) return;

    final result = await Permission.ignoreBatteryOptimizations.request();
    if (!result.isGranted) {
      await openAppSettings();
    }
  }

  static Future<bool> _tryOpenMiuiPowerSettings() async {
    try {
      final intent = AndroidIntent(
        action: 'action_view',
        package: 'com.miui.powerkeeper',
        componentName: 'com.miui.powerkeeper.ui.HiddenAppsConfigActivity',
        arguments: <String, dynamic>{
          'package_name': 'tw.bcc.englishapp',
          'package_label': '智慧聽覺巡航',
        },
      );
      await intent.launch();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 跳轉到小米 MIUI 的「自啟動管理」列表頁（沒辦法直接跳到單一 App，
  /// 需要使用者自己在列表裡找到本 App 開啟）。同樣只在小米裝置上
  /// 有作用，其他廠牌會靜默失敗。
  static Future<void> openMiuiAutostartSettings() async {
    try {
      final intent = AndroidIntent(
        action: 'action_view',
        package: 'com.miui.securitycenter',
        componentName:
            'com.miui.permcenter.autostart.AutoStartManagementActivity',
      );
      await intent.launch();
    } catch (_) {
      // 非小米裝置或找不到這個頁面，靜默略過即可。
    }
  }
}
