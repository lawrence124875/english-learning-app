import 'package:shared_preferences/shared_preferences.dart';

/// V2 讀寫 V1 舊資料的唯一出入口（SPEC §5.1、§9.2）。
///
/// V1 資料格式完全不變：
/// - ★：`starred_v1_<datasetId>`，index 字串清單（由 V1 ProgressRepository 讀寫）。
/// - 已朗讀：`stats_all_learned_v1`，`<datasetId>:<index>` 字串清單（V2 只讀）。
///
/// 正式版由 AppState 實作（讀寫它記憶體中的★集合，並經 ProgressRepository
/// 存檔），確保 V1 畫面與存檔同時更新，不會被 V1 之後的存檔蓋掉。
abstract class V1LegacyGateway {
  /// 某份教材目前的 ★ index 集合。
  Set<int> starredIndexes(String datasetId);

  /// 以新的 ★ index 集合取代（同 key、同格式）。
  Future<void> setStarredIndexes(String datasetId, Set<int> indexes);

  /// V1「已學習（曾朗讀）」的原始 key 清單（`<datasetId>:<index>`），唯讀。
  Future<List<String>> learnedKeys();
}

/// 讀取 V1「已學習」清單（與 V1 StatsRepository 同一個 key，只讀不寫）。
class V1LearnedReader {
  static const learnedKey = 'stats_all_learned_v1';

  V1LearnedReader._();

  static Future<List<String>> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(learnedKey) ?? const [];
  }
}
