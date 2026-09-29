import 'dart:io' show Platform;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'ads_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'background_l10n.dart';

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
  /// 第 10 版起改用高重要性頻道（會跳出橫幅）。Android 建立頻道後就不能
  /// 再調整重要性，所以換新 id，並刪掉舊頻道。
  static const _channelId = 'tw.bcc.englishapp.reminder_high';
  static const _oldChannelId = 'tw.bcc.englishapp.reminder';

  /// 通知內容依「排程當下」的手機語言產生。每日提醒與久未使用提醒
  /// 在每次開啟 App 時都會重新排程，所以使用者切換手機語言後，
  /// 只要再開一次 App，之後跳出的提醒就會是新語言。
  static NotificationDetails _details() {
    final l = BackgroundL10n.current();
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        l.notifChannelName,
        channelDescription: l.notifChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBanner: true,
        presentList: true,
        presentSound: true,
      ),
    );
  }

  /// 初始化若失敗，記錄錯誤給「通知診斷」畫面顯示（main.dart 會吞掉例外）。
  static String? initError;

  static Future<void> initialize() async {
    try {
      await _initializeInner();
      initError = null;
    } catch (e) {
      initError = e.toString();
      rethrow;
    }
  }

  static Future<void> _initializeInner() async {
    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    // iOS：啟動時不主動要通知權限，和 Android 一樣等使用者開啟提醒時才要。
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
        android: androidSettings, iOS: darwinSettings);
    await _plugin.initialize(settings);

    final l = BackgroundL10n.current();
    final channel = AndroidNotificationChannel(
      _channelId,
      l.notifChannelName,
      description: l.notifChannelDesc,
      importance: Importance.high,
    );
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(channel);
    try {
      await android?.deleteNotificationChannel(_oldChannelId);
    } catch (_) {}
  }

  /// 能用「精準鬧鐘」就用（時間到準時跳），不行才退回「非精準」
  /// （小米等省電機制下，非精準排程可能延遲很久甚至不觸發）。
  static Future<AndroidScheduleMode> _scheduleMode() async {
    try {
      final can = await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.canScheduleExactNotifications();
      if (can == true) return AndroidScheduleMode.exactAllowWhileIdle;
    } catch (_) {}
    return AndroidScheduleMode.inexactAllowWhileIdle;
  }

  /// 使用者主動設定提醒時呼叫：Android 12+ 若尚未允許「鬧鐘與提醒」
  /// （精準鬧鐘），開系統設定頁請使用者允許。只在使用者操作時觸發，
  /// 不在 App 啟動時自動跳出。
  static Future<void> requestExactAlarmIfNeeded() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android == null) return;
      final can = await android.canScheduleExactNotifications();
      if (can == true) return;
      AdsService.skipNextAppOpenAd();
      await android.requestExactAlarmsPermission();
    } catch (_) {}
  }

  /// 請求通知權限。**一律不拋例外**：
  /// Crashlytics 回報（第 9～10 版，2026-09）這裡會拋
  /// `PlatformException(error, Attempt to invoke virtual method ... on a null object reference)`
  /// ——外掛在沒有前景 Activity 時（例如 App 被關閉但背景播放行程還活著、
  /// 再次開啟的瞬間）呼叫系統權限對話框會失敗。以前沒接住，導致
  /// AppState.initialize() 中斷、畫面卡在載入中。現在改成失敗就回傳 false，
  /// 並記一筆「非當機」錯誤供觀察。
  static Future<bool> requestPermission() async {
    try {
      if (Platform.isIOS) {
        final ok = await _plugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true);
        return ok ?? false;
      }
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      return granted ?? false;
    } catch (e, st) {
      _recordNonFatal(e, st, 'requestPermission');
      return false;
    }
  }

  /// 通知相關錯誤只記為「非當機」，不影響 App 運作。
  static void _recordNonFatal(Object e, StackTrace st, String where) {
    try {
      FirebaseCrashlytics.instance
          .recordError(e, st, fatal: false, reason: 'NotificationService.$where');
    } catch (_) {}
  }

  /// 把「裝置本地時間的某個時間點」換算成 TZDateTime，
  /// 不透過任何原生外掛查詢時區名稱，直接用 Dart 內建的
  /// DateTime.timeZoneOffset（跨平台原生支援，永遠準確反映裝置目前的
  /// UTC 偏移量，包含日光節約時間）手動計算。
  static tz.TZDateTime _nextInstanceOfLocalTime(int hour, int minute) {
    final nowLocal = DateTime.now();

    var targetLocal =
        DateTime(nowLocal.year, nowLocal.month, nowLocal.day, hour, minute);
    if (targetLocal.isBefore(nowLocal)) {
      targetLocal = targetLocal.add(const Duration(days: 1));
    }

    // 注意：TZDateTime.from 取的是 DateTime 的「絕對時間點」（epoch），
    // 不是牆上時鐘數字，所以直接傳本地 DateTime 即可，不能再減時區偏移——
    // 第 10 版前多減了 8 小時，導致每日提醒提早 8 小時觸發（設 19:00 會在 11:00 跳）。
    return tz.TZDateTime.from(targetLocal, tz.UTC);
  }

  /// 排程每天固定時間的複習提醒（[hour]/[minute] 為 24 小時制，裝置本地時間）。
  static Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    final scheduled = _nextInstanceOfLocalTime(hour, minute);
    final l = BackgroundL10n.current();

    await _plugin.zonedSchedule(
      _reminderId,
      l.notifDailyTitle,
      l.notifDailyBody,
      scheduled,
      _details(),
      androidScheduleMode: await _scheduleMode(),
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
    final scheduled = tz.TZDateTime.from(target, tz.UTC);

    final l = BackgroundL10n.current();
    await _plugin.zonedSchedule(
      _inactivityReminderId,
      l.notifInactivityTitle,
      l.notifInactivityBody,
      scheduled,
      _details(),
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
    if (!Platform.isAndroid) return;
    final openedMiui = await _tryOpenMiuiPowerSettings();
    if (openedMiui) return;

    final status = await Permission.ignoreBatteryOptimizations.status;
    if (status.isGranted) return;

    final result = await Permission.ignoreBatteryOptimizations.request();
    if (!result.isGranted) {
      AdsService.skipNextAppOpenAd();
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
      AdsService.skipNextAppOpenAd();
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
    if (!Platform.isAndroid) return;
    try {
      final intent = AndroidIntent(
        action: 'action_view',
        package: 'com.miui.securitycenter',
        componentName:
            'com.miui.permcenter.autostart.AutoStartManagementActivity',
      );
      AdsService.skipNextAppOpenAd();
      await intent.launch();
    } catch (_) {
      // 非小米裝置或找不到這個頁面，靜默略過即可。
    }
  }

  // --- 通知診斷（隱藏工具：學習統計頁長按「每日提醒」標題開啟）---
  static const _testNowId = 1003;
  static const _testLaterId = 1004;

  /// 收集目前通知相關狀態，每行一項。
  static Future<List<String>> diagnostics() async {
    final lines = <String>[];
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    lines.add('初始化：${initError == null ? "成功" : "失敗 → $initError"}');
    try {
      lines.add('通知權限（App 通知開關）：${await android?.areNotificationsEnabled()}');
    } catch (e) {
      lines.add('通知權限：查詢失敗 $e');
    }
    try {
      lines.add('精準鬧鐘權限：${await android?.canScheduleExactNotifications()}');
    } catch (e) {
      lines.add('精準鬧鐘權限：查詢失敗 $e');
    }
    try {
      final chans = await android?.getNotificationChannels() ?? [];
      final mine = chans.where((c) => c.id == _channelId).toList();
      lines.add(mine.isEmpty
          ? '提醒頻道：不存在！'
          : '提醒頻道重要性：${mine.first.importance.value}（0＝被使用者關閉）');
    } catch (e) {
      lines.add('提醒頻道：查詢失敗 $e');
    }
    try {
      final pending = await _plugin.pendingNotificationRequests();
      lines.add('已排程：${pending.isEmpty ? "無" : pending.map((p) => p.id).join(", ")}'
          '（1001＝每日提醒、1002＝久未使用、1004＝1 分鐘測試）');
    } catch (e) {
      lines.add('已排程：查詢失敗 $e');
    }
    final now = DateTime.now();
    lines.add('手機時間：${now.toString().substring(0, 19)}（UTC 偏移 ${now.timeZoneOffset.inHours}）');
    return lines;
  }

  /// 立刻發一則通知。回傳 null 代表呼叫成功，否則是錯誤訊息。
  static Future<String?> showTestNow() async {
    try {
      final l = BackgroundL10n.current();
      await _plugin.show(_testNowId, l.notifDailyTitle, '測試通知（立即）', _details());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// 1 分鐘後發一則通知（排程方式與每日提醒相同）。
  static Future<String?> scheduleTestInOneMinute() async {
    try {
      final now = DateTime.now();
      final scheduled =
          tz.TZDateTime.from(now.add(const Duration(minutes: 1)), tz.UTC);
      final l = BackgroundL10n.current();
      await _plugin.zonedSchedule(
        _testLaterId,
        l.notifDailyTitle,
        '測試通知（1 分鐘後）',
        scheduled,
        _details(),
        androidScheduleMode: await _scheduleMode(),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
