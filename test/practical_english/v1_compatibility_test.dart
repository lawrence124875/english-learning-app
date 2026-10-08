import 'dart:convert';
import 'dart:io';

import 'package:english_learning_app/data/repositories/progress_repository.dart';
import 'package:english_learning_app/data/repositories/word_repository.dart';
import 'package:english_learning_app/data/sources/tts_service.dart';
import 'package:english_learning_app/domain/models/playback_settings.dart';
import 'package:english_learning_app/domain/models/word_item.dart';
import 'package:english_learning_app/practical_english/data/app_state_v1_gateway.dart';
import 'package:english_learning_app/practical_english/data/v1_legacy_gateway.dart';
import 'package:english_learning_app/practical_english/data/word_state_repository.dart';
import 'package:english_learning_app/practical_english/domain/services/legacy_migration.dart';
import 'package:english_learning_app/practical_english/domain/services/weak_word_sync.dart';
import 'package:english_learning_app/practical_english/domain/services/word_ref_index.dart';
import 'package:english_learning_app/presentation/providers/app_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

WordItem _w(String id) => WordItem(id: id, word: id, translations: const {});

WordDataset _builtIn(String id, int n, {List<String>? ids}) => WordDataset(
      id: id,
      name: id,
      shortName: id,
      builtIn: true,
      items: [
        for (final i in ids ?? List.generate(n, (i) => '${id}_${'$i'.padLeft(4, '0')}'))
          _w(i)
      ],
    );

WordDataset _custom(String id, List<String> itemIds) => WordDataset(
    id: id, name: id, shortName: id, items: [for (final i in itemIds) _w(i)]);

/// 以 V1 實際 SharedPreferences 格式運作的 gateway（透過 V1 ProgressRepository），
/// 用來驗證 V2 讀寫 V1 key 時格式完全不變。
class PrefsGateway implements V1LegacyGateway {
  final ProgressRepository repo = ProgressRepository();
  final Map<String, Set<int>> _cache = {};
  int writes = 0;

  Future<void> preload(Iterable<WordDataset> datasets) async {
    for (final d in datasets) {
      _cache[d.id] = await repo.loadStarred(d.id);
    }
  }

  @override
  Set<int> starredIndexes(String datasetId) => _cache[datasetId] ?? {};

  @override
  Future<void> setStarredIndexes(String datasetId, Set<int> indexes) async {
    writes++;
    _cache[datasetId] = Set.of(indexes);
    await repo.saveStarred(datasetId, indexes);
  }

  @override
  Future<List<String>> learnedKeys() => V1LearnedReader.read();
}

class _FakeTts implements TtsService {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _NoWords implements WordRepository {
  @override
  Future<List<WordDataset>> loadAllDatasets() async => [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('pe_compat');
  });
  tearDown(() async => dir.delete(recursive: true));

  Future<Directory> base() async => dir;

  /// 每次模擬「重新進入 Practical English」：新的 repository 從磁碟載入。
  Future<(MigrationReport, WordStateRepository)> enterPe(
      V1LegacyGateway gateway, List<WordDataset> datasets) async {
    final states = WordStateRepository(baseDir: base);
    final report = await LegacyMigration(
            gateway: gateway, wordStates: states, baseDir: base)
        .run(datasets);
    return (report, states);
  }

  Future<int?> migrationVersion() async =>
      (await SharedPreferences.getInstance())
          .getInt(LegacyMigration.migrationVersionKey);

  test('A. fresh install: empty V2 state, version set, no V1 writes', () async {
    SharedPreferences.setMockInitialValues({});
    final ds = [_builtIn('ngsl_2809', 5)];
    final gw = PrefsGateway();
    await gw.preload(ds);
    final (report, states) = await enterPe(gw, ds);
    expect(report.failed, isFalse);
    expect(report.initialMigrationDone, isTrue);
    expect(states.all, isEmpty);
    expect(gw.writes, 0);
    expect(await migrationVersion(), 1);
  });

  test('B. upgrade from V1 data: ★ → weak, learned → exposedInV1, V1 keys untouched',
      () async {
    final v1Prefs = <String, Object>{
      'starred_v1_ngsl_2809': ['1', '3'],
      'starred_v1_custom_100': ['0'],
      'stats_all_learned_v1': ['ngsl_2809:0', 'ngsl_2809:1', 'custom_100:1'],
      'settings_v1': '{"repeatCount":2}',
      'progress_v1_ngsl_2809': '{"playlist":[0,1,2],"currentStep":1}',
    };
    SharedPreferences.setMockInitialValues(Map.of(v1Prefs));
    final ds = [
      _builtIn('ngsl_2809', 5),
      _custom('custom_100', ['custom_0_1', 'custom_1_2']),
    ];
    final gw = PrefsGateway();
    await gw.preload(ds);
    final (report, states) = await enterPe(gw, ds);

    expect(report.initialMigrationDone, isTrue);
    expect(report.unresolved, isEmpty);
    expect(states.get('ngsl_2809_0001').weak, isTrue);
    expect(states.get('ngsl_2809_0003').weak, isTrue);
    expect(states.get('ngsl_2809_0000').weak, isFalse);
    expect(states.get('ngsl_2809_0000').exposedInV1, isTrue);
    expect(states.get('ngsl_2809_0001').exposedInV1, isTrue);
    expect(states.get('ngsl_2809_0001').mastered, isFalse);
    // 自訂教材使用 datasetId/wordId
    expect(states.get('custom_100/custom_0_1').weak, isTrue);
    expect(states.get('custom_100/custom_1_2').exposedInV1, isTrue);
    // 初次 migration 不寫 V1，所有 V1 key 原封不動
    expect(gw.writes, 0);
    final prefs = await SharedPreferences.getInstance();
    for (final e in v1Prefs.entries) {
      final actual = prefs.get(e.key);
      expect(actual is List ? List<String>.from(actual) : actual, e.value,
          reason: e.key);
    }
    // V2 狀態寫在自己的檔案
    expect(await File('${dir.path}/word_state.json').exists(), isTrue);
  });

  test('C. V1 ★ added/removed after migration reaches V2 on next entry',
      () async {
    SharedPreferences.setMockInitialValues({
      'starred_v1_ngsl_2809': ['1'],
    });
    final ds = [_builtIn('ngsl_2809', 5)];
    await enterPe(PrefsGateway()..preload(ds), ds);

    // 使用者在 V1 改了 ★（V1 自己的 ProgressRepository 寫入）
    await ProgressRepository().saveStarred('ngsl_2809', {2, 4});
    final gw = PrefsGateway();
    await gw.preload(ds);
    final (report, states) = await enterPe(gw, ds);
    expect(report.initialMigrationDone, isFalse);
    expect(report.compatibleDatasets, ['ngsl_2809']);
    expect(states.get('ngsl_2809_0001').weak, isFalse);
    expect(states.get('ngsl_2809_0002').weak, isTrue);
    expect(states.get('ngsl_2809_0004').weak, isTrue);
    expect(gw.writes, 0);
  });

  test('C2. V1 re-star of a mastered word clears mastered', () async {
    SharedPreferences.setMockInitialValues({});
    final ds = [_builtIn('ngsl_2809', 3)];
    final gw = PrefsGateway();
    await gw.preload(ds);
    final (_, states) = await enterPe(gw, ds);
    final sync = WeakWordSync(
        gateway: gw, wordStates: states, index: WordRefIndex.build(ds));
    await sync.setMastered('ngsl_2809_0002', true);
    await states.flush();

    await ProgressRepository().saveStarred('ngsl_2809', {2});
    final gw2 = PrefsGateway();
    await gw2.preload(ds);
    final (_, states2) = await enterPe(gw2, ds);
    expect(states2.get('ngsl_2809_0002').weak, isTrue);
    expect(states2.get('ngsl_2809_0002').mastered, isFalse);
  });

  test('D. V2 weak / mastered write back to V1 ★ in V1 format', () async {
    SharedPreferences.setMockInitialValues({
      'starred_v1_ngsl_2809': ['1'],
    });
    final ds = [
      _builtIn('ngsl_2809', 5),
      _custom('custom_100', ['custom_0_1']),
    ];
    final gw = PrefsGateway();
    await gw.preload(ds);
    final (_, states) = await enterPe(gw, ds);
    final sync = WeakWordSync(
        gateway: gw, wordStates: states, index: WordRefIndex.build(ds));

    await sync.setWeak('ngsl_2809_0003', true);
    await sync.setWeak('custom_100/custom_0_1', true);
    await sync.setMastered('ngsl_2809_0001', true);
    await states.flush();

    final repo = ProgressRepository();
    expect(await repo.loadStarred('ngsl_2809'), {3});
    expect(await repo.loadStarred('custom_100'), {0});
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('starred_v1_ngsl_2809'), ['3']);
    expect(states.get('ngsl_2809_0001').mastered, isTrue);
    expect(states.get('ngsl_2809_0001').weak, isFalse);

    // 重新進入：V1 ★ 與 V2 一致，不互相覆蓋
    final gw2 = PrefsGateway();
    await gw2.preload(ds);
    final (_, again) = await enterPe(gw2, ds);
    expect(again.get('ngsl_2809_0003').weak, isTrue);
    expect(again.get('ngsl_2809_0001').mastered, isTrue);
    expect(gw2.writes, 0);
  });

  test('E. fingerprint is deterministic and order-sensitive', () {
    final a = _builtIn('d', 3).items;
    final reordered = [a[1], a[0], a[2]];
    expect(LegacyMigration.fingerprint(a), LegacyMigration.fingerprint(a));
    expect(LegacyMigration.fingerprint(a),
        isNot(LegacyMigration.fingerprint(reordered)));
    expect(LegacyMigration.fingerprint(a, 2),
        LegacyMigration.fingerprint(a.take(2).toList()));
  });

  test('F. unchanged dataset: repeated entries never rewrite V1 or lose data',
      () async {
    SharedPreferences.setMockInitialValues({
      'starred_v1_ngsl_2809': ['0', '2'],
      'stats_all_learned_v1': ['ngsl_2809:1'],
    });
    final ds = [_builtIn('ngsl_2809', 4)];
    String? firstStateFile;
    for (var i = 0; i < 3; i++) {
      final gw = PrefsGateway();
      await gw.preload(ds);
      final (report, _) = await enterPe(gw, ds);
      expect(report.repairedDatasets, isEmpty);
      expect(gw.writes, 0);
      final content =
          await File('${dir.path}/word_state.json').readAsString();
      firstStateFile ??= content;
      expect(content, firstStateFile);
    }
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('starred_v1_ngsl_2809'), ['0', '2']);
  });

  test('G1. append-only change stays compatible (V1 ★ still authoritative)',
      () async {
    SharedPreferences.setMockInitialValues({
      'starred_v1_ngsl_2809': ['1'],
    });
    await enterPe(PrefsGateway()..preload([_builtIn('ngsl_2809', 3)]),
        [_builtIn('ngsl_2809', 3)]);

    final grown = [_builtIn('ngsl_2809', 5)];
    await ProgressRepository().saveStarred('ngsl_2809', {1, 4});
    final gw = PrefsGateway();
    await gw.preload(grown);
    final (report, states) = await enterPe(gw, grown);
    expect(report.compatibleDatasets, ['ngsl_2809']);
    expect(states.get('ngsl_2809_0004').weak, isTrue);
    expect(gw.writes, 0);
  });

  test('G2. reorder detected: V2 weak kept, V1 ★ repaired to new indexes',
      () async {
    SharedPreferences.setMockInitialValues({
      'starred_v1_ngsl_2809': ['1'], // ngsl_2809_0001
    });
    final original = [
      _builtIn('ngsl_2809', 0,
          ids: ['ngsl_2809_0000', 'ngsl_2809_0001', 'ngsl_2809_0002'])
    ];
    await enterPe(PrefsGateway()..preload(original), original);

    // 內容被重新排序：ngsl_2809_0001 現在在 index 2；V1 ★ 仍是舊 index 1
    final reordered = [
      _builtIn('ngsl_2809', 0,
          ids: ['ngsl_2809_0000', 'ngsl_2809_0002', 'ngsl_2809_0001'])
    ];
    final gw = PrefsGateway();
    await gw.preload(reordered);
    final (report, states) = await enterPe(gw, reordered);
    expect(report.repairedDatasets, ['ngsl_2809']);
    expect(states.get('ngsl_2809_0001').weak, isTrue);
    expect(states.get('ngsl_2809_0002').weak, isFalse);
    expect(await ProgressRepository().loadStarred('ngsl_2809'), {2});

    // 修復後再進入：已相容，不再寫 V1
    final gw2 = PrefsGateway();
    await gw2.preload(reordered);
    final (report2, _) = await enterPe(gw2, reordered);
    expect(report2.compatibleDatasets, ['ngsl_2809']);
    expect(gw2.writes, 0);
  });

  test('H. unresolved mappings are recorded, never crash or delete V1 data',
      () async {
    SharedPreferences.setMockInitialValues({
      'starred_v1_ngsl_2809': ['1', '99'],
      'stats_all_learned_v1': [
        'ngsl_2809:0',
        'ngsl_2809:42',
        'custom_deleted:3',
        'garbage',
      ],
    });
    final ds = [_builtIn('ngsl_2809', 3)];
    final gw = PrefsGateway();
    await gw.preload(ds);
    final (report, states) = await enterPe(gw, ds);
    expect(report.failed, isFalse);
    expect(report.unresolved.map((u) => u.toString()).toSet(), {
      'starred:ngsl_2809:99',
      'learned:ngsl_2809:42',
      'learned:custom_deleted:custom_deleted:3',
      'learned::garbage',
    });
    expect(states.get('ngsl_2809_0001').weak, isTrue);
    final saved = jsonDecode(
        await File('${dir.path}/migration_state.json').readAsString()) as Map;
    expect((saved['unresolved'] as List).length, 4);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('starred_v1_ngsl_2809'), ['1', '99']);
    expect(prefs.getStringList('stats_all_learned_v1')!.length, 4);
  });

  test('I. re-running migration gives identical results', () async {
    SharedPreferences.setMockInitialValues({
      'starred_v1_ngsl_2809': ['0', '2'],
      'stats_all_learned_v1': ['ngsl_2809:1'],
    });
    final ds = [_builtIn('ngsl_2809', 3)];
    final gw = PrefsGateway();
    await gw.preload(ds);
    await enterPe(gw, ds);
    final first = await File('${dir.path}/word_state.json').readAsString();
    // 模擬版本號沒寫成功（例如上次中途失敗）→ 再跑一次初次 migration
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(LegacyMigration.migrationVersionKey);
    final (report, _) = await enterPe(gw, ds);
    expect(report.initialMigrationDone, isTrue);
    expect(await File('${dir.path}/word_state.json').readAsString(), first);
    expect(await migrationVersion(), 1);
  });

  test('failure leaves version unset and returns failed report', () async {
    SharedPreferences.setMockInitialValues({});
    final ds = [_builtIn('ngsl_2809', 3)];
    final blocker = File('${dir.path}/not_a_dir')..writeAsStringSync('x');
    final states = WordStateRepository(baseDir: () async => Directory(blocker.path));
    var errors = 0;
    final report = await LegacyMigration(
      gateway: PrefsGateway(),
      wordStates: states,
      baseDir: () async => Directory(blocker.path),
      onError: (_, __) => errors++,
    ).run(ds);
    expect(report.failed, isTrue);
    expect(errors, greaterThan(0));
    expect(await migrationVersion(), isNull);
  });

  test('AppState gateway updates V1 memory, prefs and starred playlist',
      () async {
    SharedPreferences.setMockInitialValues({});
    final ds = [_builtIn('ngsl_2809', 5)];
    final app = AppState(
      wordRepository: _NoWords(),
      progressRepository: ProgressRepository(),
      ttsService: _FakeTts(),
    );
    app.debugPreview(
      data: ds,
      premium: true,
      newSettings:
          const PlaybackSettings(scopeMode: ScopeMode.starredSequential),
    );
    final gw = AppStateV1Gateway(app);
    final (_, states) = await enterPe(gw, ds);
    final sync = WeakWordSync(
        gateway: gw, wordStates: states, index: WordRefIndex.build(ds));
    await sync.setWeak('ngsl_2809_0002', true);
    await sync.setWeak('ngsl_2809_0004', true);

    expect(app.currentStarred, {2, 4});
    expect(app.starredIndexesFor('ngsl_2809'), {2, 4});
    expect(app.currentPlaybackState.playlist, [2, 4]);
    expect(await ProgressRepository().loadStarred('ngsl_2809'), {2, 4});

    // V1 自己切換 ★ 之後，V2 下次進入看得到
    await app.toggleStarCurrent(); // 目前播放的是 index 2 → 取消 ★
    final (_, again) = await enterPe(gw, ds);
    expect(again.get('ngsl_2809_0002').weak, isFalse);
    expect(again.get('ngsl_2809_0004').weak, isTrue);
  });
}
