import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/playback_settings.dart';

/// 對應原網頁版三組 localStorage key：
/// SETTINGS_KEY / PROGRESS_KEY / STARRED_KEY
/// 這裡先用 SharedPreferences 存本機；第二階段若要加雲端同步/帳號系統，
/// 只需要在這個介面之上再包一層同步邏輯，不影響上層呼叫方式。
class ProgressRepository {
  static const _settingsKey = 'settings_v1';
  static const _progressPrefix = 'progress_v1_';
  static const _starredPrefix = 'starred_v1_';

  Future<PlaybackSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_settingsKey);
    if (raw == null) return const PlaybackSettings();
    return PlaybackSettings.fromJson(
        jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveSettings(PlaybackSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  Future<DatasetPlaybackState> loadProgress(String datasetId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_progressPrefix$datasetId');
    if (raw == null) return const DatasetPlaybackState();
    return DatasetPlaybackState.fromJson(
        jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveProgress(
      String datasetId, DatasetPlaybackState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        '$_progressPrefix$datasetId', jsonEncode(state.toJson()));
  }

  Future<Set<int>> loadStarred(String datasetId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('$_starredPrefix$datasetId');
    if (raw == null) return <int>{};
    return raw.map(int.parse).toSet();
  }

  Future<void> saveStarred(String datasetId, Set<int> starred) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      '$_starredPrefix$datasetId',
      starred.map((e) => e.toString()).toList(),
    );
  }

  // --- 複習提醒設定 ---
  static const _reminderEnabledKey = 'reminder_enabled_v1';
  static const _reminderHourKey = 'reminder_hour_v1';
  static const _reminderMinuteKey = 'reminder_minute_v1';

  Future<bool> loadReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_reminderEnabledKey) ?? false;
  }

  Future<(int, int)> loadReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_reminderHourKey) ?? 20;
    final minute = prefs.getInt(_reminderMinuteKey) ?? 0;
    return (hour, minute);
  }

  Future<void> saveReminderSettings({
    required bool enabled,
    required int hour,
    required int minute,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminderEnabledKey, enabled);
    await prefs.setInt(_reminderHourKey, hour);
    await prefs.setInt(_reminderMinuteKey, minute);
  }
}
