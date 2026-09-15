import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 學習統計資料模型：今日學了幾個、總共學了幾個。
class LearningStats {
  final int learnedToday;
  final int totalLearned;

  const LearningStats({this.learnedToday = 0, this.totalLearned = 0});
}

/// 追蹤「已學習」的單字（定義：曾經被朗讀播放過的項目）。
/// 用本機 SharedPreferences 儲存：
/// - 一組全域的「已學過項目」集合（key 格式：datasetId:index），用來算總數與去重
/// - 今天日期 + 今天新學了幾個，過了午夜會自動歸零重算
class StatsRepository {
  static const _allLearnedKey = 'stats_all_learned_v1';
  static const _todayDateKey = 'stats_today_date_v1';
  static const _todayCountKey = 'stats_today_count_v1';

  Future<LearningStats> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final all = prefs.getStringList(_allLearnedKey) ?? [];
    final todayDate = prefs.getString(_todayDateKey);
    final todayKey = _todayKey();
    final todayCount = (todayDate == todayKey)
        ? (prefs.getInt(_todayCountKey) ?? 0)
        : 0;
    return LearningStats(learnedToday: todayCount, totalLearned: all.length);
  }

  /// 取得單一教材已學習（曾被朗讀過）的項目數，用於各教材各自的進度顯示。
  Future<int> learnedCountForDataset(String datasetId) async {
    final prefs = await SharedPreferences.getInstance();
    final all = prefs.getStringList(_allLearnedKey) ?? [];
    final prefix = '$datasetId:';
    return all.where((k) => k.startsWith(prefix)).length;
  }

  /// 標記某個單字被學習過（曾經被朗讀）。回傳更新後的統計。
  /// 如果這個字之前就學過了，總數不會重複累加，但如果是「今天第一次遇到」，
  /// 今日計數還是會加一（鼓勵當天複習到之前學過的字也算進度）。
  Future<LearningStats> markLearned(String datasetId, int index) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$datasetId:$index';
    final all = (prefs.getStringList(_allLearnedKey) ?? []).toSet();
    final isNew = all.add(key);
    if (isNew) {
      await prefs.setStringList(_allLearnedKey, all.toList());
    }

    final todayKey = _todayKey();
    final storedDate = prefs.getString(_todayDateKey);
    var todayCount = (storedDate == todayKey)
        ? (prefs.getInt(_todayCountKey) ?? 0)
        : 0;

    // 用「今天遇到過的字」的子集合判斷是否要加到今日計數，避免同一天內
    // 反覆聽同一個字被重複計算。
    final todaySeenKey = 'stats_today_seen_v1';
    final todaySeen = (storedDate == todayKey)
        ? (prefs.getStringList(todaySeenKey) ?? []).toSet()
        : <String>{};
    if (todaySeen.add(key)) {
      todayCount += 1;
      await prefs.setStringList(todaySeenKey, todaySeen.toList());
    }
    await prefs.setString(_todayDateKey, todayKey);
    await prefs.setInt(_todayCountKey, todayCount);

    return LearningStats(learnedToday: todayCount, totalLearned: all.length);
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }
}
