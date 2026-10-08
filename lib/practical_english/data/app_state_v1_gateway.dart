import '../../presentation/providers/app_state.dart';
import 'v1_legacy_gateway.dart';

/// 正式版的 V1 出入口：★ 讀寫 AppState 記憶體中的集合（並由 AppState 經
/// V1 ProgressRepository 存檔），已學習清單直接唯讀 SharedPreferences。
class AppStateV1Gateway implements V1LegacyGateway {
  final AppState _appState;

  AppStateV1Gateway(this._appState);

  @override
  Set<int> starredIndexes(String datasetId) =>
      _appState.starredIndexesFor(datasetId);

  @override
  Future<void> setStarredIndexes(String datasetId, Set<int> indexes) =>
      _appState.replaceStarredFromPracticalEnglish(datasetId, indexes);

  @override
  Future<List<String>> learnedKeys() => V1LearnedReader.read();
}
