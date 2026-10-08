import '../../data/v1_legacy_gateway.dart';
import '../../data/word_state_repository.dart';
import 'word_ref_index.dart';

/// V2 Weak → V1 ★ 的寫回（SPEC §9.2、§9.3）。
/// V1 ★ → V2 Weak 由 LegacyMigration 的 reconciliation 負責。
///
/// 規則：
/// - 標弱字：weak = true、mastered = false，並在 V1 加上 ★。
/// - 取消弱字：weak = false，並移除 V1 ★。
/// - 「我會了」：mastered = true、weak = false，並移除 V1 ★。
/// - 無法對應到目前教材的 WordRef（例如自訂教材已刪除）：只更新 V2 狀態。
class WeakWordSync {
  final V1LegacyGateway _gateway;
  final WordStateRepository _wordStates;
  final WordRefIndex _index;

  WeakWordSync({
    required V1LegacyGateway gateway,
    required WordStateRepository wordStates,
    required WordRefIndex index,
  })  : _gateway = gateway,
        _wordStates = wordStates,
        _index = index;

  Future<void> setWeak(String ref, bool weak) async {
    final current = _wordStates.get(ref);
    _wordStates.put(
        ref,
        weak
            ? current.copyWith(weak: true, mastered: false)
            : current.copyWith(weak: false));
    await _writeV1Star(ref, weak);
    await _wordStates.scheduleSave();
  }

  Future<void> setMastered(String ref, bool mastered) async {
    final current = _wordStates.get(ref);
    _wordStates.put(
        ref,
        mastered
            ? current.copyWith(mastered: true, weak: false)
            : current.copyWith(mastered: false));
    if (mastered) await _writeV1Star(ref, false);
    await _wordStates.scheduleSave();
  }

  Future<void> _writeV1Star(String ref, bool starred) async {
    final location = _index.resolve(ref);
    if (location == null) return;
    final datasetId = location.dataset.id;
    final indexes = Set<int>.from(_gateway.starredIndexes(datasetId));
    final changed = starred
        ? indexes.add(location.index)
        : indexes.remove(location.index);
    if (changed) await _gateway.setStarredIndexes(datasetId, indexes);
  }
}
