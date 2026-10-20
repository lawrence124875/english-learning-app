import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/models/word_item.dart';
import '../../data/json_file_store.dart';
import '../../data/sentence_repository.dart';
import '../../data/v1_legacy_gateway.dart';
import '../../data/word_state_repository.dart';
import '../models/word_ref.dart';
import 'sentence_id_factory.dart';

/// 無法對應的 V1 舊資料（index 超出範圍、教材已不存在、格式錯誤）。
/// 只記錄、不刪除 V1 資料，下次 reconciliation 重新計算。
class UnresolvedLegacyItem {
  /// `starred` 或 `learned`。
  final String source;
  final String datasetId;

  /// 原始值（index 或原始 key）。
  final String raw;

  const UnresolvedLegacyItem(this.source, this.datasetId, this.raw);

  Map<String, dynamic> toJson() =>
      {'source': source, 'datasetId': datasetId, 'raw': raw};

  @override
  String toString() => '$source:$datasetId:$raw';
}

/// 一次 migration／reconciliation 的結果。
class MigrationReport {
  /// 這次是否完成了初次 migration（`pe_migration_version` 由 0 變 1）。
  final bool initialMigrationDone;

  /// 以 V1 ★ 為準同步的教材（未變更或只在尾端新增）。
  final List<String> compatibleDatasets;

  /// 偵測到順序變動、改以 V2 canonical 狀態修復 V1 ★ 的教材。
  final List<String> repairedDatasets;

  /// 已變更的教材，但 V2 狀態檔損毀重建、沒有可信的 weak 資料，
  /// 所以不修復 V1 ★，改以 V1 ★ 為準（SPEC §5.5）。
  final List<String> repairSkippedDatasets;
  final List<UnresolvedLegacyItem> unresolved;

  /// 失敗時為 true；不會設定 migration version，下次進入會重試。
  final bool failed;
  final Object? error;

  const MigrationReport({
    this.initialMigrationDone = false,
    this.compatibleDatasets = const [],
    this.repairedDatasets = const [],
    this.repairSkippedDatasets = const [],
    this.unresolved = const [],
    this.failed = false,
    this.error,
  });
}

/// V1 index 狀態 → V2 canonical WordRef 狀態的 Migration Layer（SPEC §5）。
///
/// 每次進入 Practical English 呼叫 [run]：
/// - `pe_migration_version < 1`：初次 migration。所有教材都以 V1 為準，
///   **不寫任何 V1 資料**；成功寫入 V2 狀態後才把版本設為 1。
/// - 之後每次都做 reconciliation：
///   - 教材「相容」（前 count 筆的 fingerprint 與上次相同：未變更或只在尾端新增）
///     → V1 ★ 為準，取代該教材的 V2 weak；同時更新 exposedInV1。
///   - 教材「已變更」（重排／插入／刪除）→ 不信任 index，保留 V2 weak，
///     用目前的 index 改寫 V1 ★（修復）。
///     例外：V2 狀態檔損毀重建時不修復，改以 V1 ★ 為準，避免清掉 V1 ★。
/// - 所有步驟都是集合運算，同樣輸入重跑結果相同（idempotent）。
class LegacyMigration {
  static const migrationVersionKey = 'pe_migration_version';
  static const currentVersion = 1;
  static const stateFileName = 'migration_state.json';

  final V1LegacyGateway _gateway;
  final WordStateRepository _wordStates;
  final Future<Directory> Function() _baseDir;
  final JsonStoreErrorReporter? _onError;

  LegacyMigration({
    required V1LegacyGateway gateway,
    required WordStateRepository wordStates,
    Future<Directory> Function()? baseDir,
    JsonStoreErrorReporter? onError,
  })  : _gateway = gateway,
        _wordStates = wordStates,
        _baseDir = baseDir ?? SentenceRepository.practicalEnglishDir,
        _onError = onError;

  /// 教材的 fingerprint：前 [count] 個 WordItem.id 以換行串接後做 FNV-1a 64。
  static String fingerprint(List<WordItem> items, [int? count]) {
    final n = count ?? items.length;
    return Fnv1a64.hex(items.take(n).map((e) => e.id).join('\n'));
  }

  Future<MigrationReport> run(List<WordDataset> datasets) async {
    try {
      return await _run(datasets);
    } catch (e, st) {
      _onError?.call(e, st);
      return MigrationReport(failed: true, error: e);
    }
  }

  Future<MigrationReport> _run(List<WordDataset> datasets) async {
    final prefs = await SharedPreferences.getInstance();
    final version = prefs.getInt(migrationVersionKey) ?? 0;
    final initial = version < currentVersion;

    await _wordStates.load();
    final dir = await _baseDir();
    final stateStore =
        JsonFileStore(File('${dir.path}/$stateFileName'), onError: _onError);
    final stored = initial
        ? const <String, _StoredFingerprint>{}
        : _readFingerprints(await stateStore.read());

    final unresolved = <UnresolvedLegacyItem>[];
    final learnedByDataset = _parseLearned(await _gateway.learnedKeys(),
        datasets.map((d) => d.id).toSet(), unresolved);

    final compatible = <String>[];
    final repaired = <String>[];
    final repairSkipped = <String>[];
    // V2 狀態是從損毀檔重建的空狀態時，不能拿它改寫 V1 ★。
    final v2StateTrusted = !_wordStates.rebuiltFromCorruption;
    final newFingerprints = <String, _StoredFingerprint>{};

    for (final dataset in datasets) {
      final items = dataset.items;
      final refs = [for (final item in items) WordRef.of(dataset, item)];
      final previous = stored[dataset.id];
      final isCompatible = previous == null ||
          (previous.count <= items.length &&
              fingerprint(items, previous.count) == previous.fingerprint);

      if (isCompatible) {
        compatible.add(dataset.id);
        _syncFromV1(dataset, refs, learnedByDataset[dataset.id] ?? const {},
            unresolved);
      } else if (v2StateTrusted) {
        repaired.add(dataset.id);
        await _repairV1(dataset, refs);
      } else {
        repairSkipped.add(dataset.id);
        _syncFromV1(dataset, refs, learnedByDataset[dataset.id] ?? const {},
            unresolved);
      }
      newFingerprints[dataset.id] =
          _StoredFingerprint(fingerprint(items), items.length);
    }

    // 寫入順序：V2 狀態 → migration 狀態 → 版本號。中途失敗時版本不會被設定，
    // 下次重跑（idempotent）。
    await _wordStates.saveNow();
    await stateStore.write({
      'schema': 1,
      'datasets': newFingerprints.map((k, v) => MapEntry(k, v.toJson())),
      'unresolved': unresolved.map((u) => u.toJson()).toList(),
    });
    if (initial) await prefs.setInt(migrationVersionKey, currentVersion);

    return MigrationReport(
      initialMigrationDone: initial,
      compatibleDatasets: compatible,
      repairedDatasets: repaired,
      repairSkippedDatasets: repairSkipped,
      unresolved: unresolved,
    );
  }

  /// 相容教材：V1 ★ 為準取代 V2 weak；V1 已朗讀 → exposedInV1。
  void _syncFromV1(WordDataset dataset, List<String> refs,
      Set<int> learnedIndexes, List<UnresolvedLegacyItem> unresolved) {
    final weakRefs = <String>{};
    for (final index in _gateway.starredIndexes(dataset.id)) {
      if (index >= 0 && index < refs.length) {
        weakRefs.add(refs[index]);
      } else {
        unresolved.add(UnresolvedLegacyItem('starred', dataset.id, '$index'));
      }
    }
    final exposed = <String>{};
    for (final index in learnedIndexes) {
      if (index < refs.length) {
        exposed.add(refs[index]);
      } else {
        unresolved.add(UnresolvedLegacyItem('learned', dataset.id, '$index'));
      }
    }

    for (final ref in refs) {
      final current = _wordStates.get(ref);
      final weak = weakRefs.contains(ref);
      var next = current.copyWith(weak: weak);
      // 已精熟的字在 V1 被重新標★ → 視為重新變弱（SPEC §9.3）。
      if (weak && current.mastered) next = next.copyWith(mastered: false);
      if (exposed.contains(ref) && !current.exposedInV1) {
        next = next.copyWith(exposedInV1: true);
      }
      if (next != current) _wordStates.put(ref, next);
    }
  }

  /// 已變更教材：保留 V2 weak，依目前 index 改寫 V1 ★（只在內容不同時才寫）。
  Future<void> _repairV1(WordDataset dataset, List<String> refs) async {
    final indexes = <int>{};
    for (var i = 0; i < refs.length; i++) {
      if (_wordStates.get(refs[i]).weak) indexes.add(i);
    }
    final current = _gateway.starredIndexes(dataset.id);
    if (current.length != indexes.length || !current.containsAll(indexes)) {
      await _gateway.setStarredIndexes(dataset.id, indexes);
    }
  }

  /// 解析 V1 已朗讀 key（`<datasetId>:<index>`）；格式錯誤或教材不存在 → unresolved。
  Map<String, Set<int>> _parseLearned(List<String> keys,
      Set<String> datasetIds, List<UnresolvedLegacyItem> unresolved) {
    final result = <String, Set<int>>{};
    for (final key in keys) {
      final sep = key.lastIndexOf(':');
      final datasetId = sep > 0 ? key.substring(0, sep) : '';
      final index = sep > 0 ? int.tryParse(key.substring(sep + 1)) : null;
      if (index == null || index < 0 || !datasetIds.contains(datasetId)) {
        unresolved.add(UnresolvedLegacyItem('learned', datasetId, key));
        continue;
      }
      (result[datasetId] ??= <int>{}).add(index);
    }
    return result;
  }

  Map<String, _StoredFingerprint> _readFingerprints(Object? json) {
    final result = <String, _StoredFingerprint>{};
    if (json is Map && json['datasets'] is Map) {
      (json['datasets'] as Map).forEach((key, value) {
        if (value is Map &&
            value['fingerprint'] is String &&
            value['count'] is int) {
          result[key.toString()] = _StoredFingerprint(
              value['fingerprint'] as String, value['count'] as int);
        }
      });
    }
    return result;
  }
}

class _StoredFingerprint {
  final String fingerprint;
  final int count;
  const _StoredFingerprint(this.fingerprint, this.count);
  Map<String, dynamic> toJson() => {'fingerprint': fingerprint, 'count': count};
}
