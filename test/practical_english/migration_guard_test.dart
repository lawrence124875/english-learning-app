import 'dart:io';

import 'package:english_learning_app/domain/models/word_item.dart';
import 'package:english_learning_app/practical_english/data/json_file_store.dart';
import 'package:english_learning_app/practical_english/data/v1_legacy_gateway.dart';
import 'package:english_learning_app/practical_english/data/word_state_repository.dart';
import 'package:english_learning_app/practical_english/domain/services/legacy_migration.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

WordDataset _ds(List<String> ids) => WordDataset(
      id: 'ngsl_2809',
      name: 'ngsl_2809',
      shortName: 'ngsl_2809',
      builtIn: true,
      items: [
        for (final id in ids) WordItem(id: id, word: id, translations: const {})
      ],
    );

class _MemGateway implements V1LegacyGateway {
  final Map<String, Set<int>> starred;
  int writes = 0;
  _MemGateway(this.starred);

  @override
  Set<int> starredIndexes(String datasetId) => starred[datasetId] ?? {};

  @override
  Future<void> setStarredIndexes(String datasetId, Set<int> indexes) async {
    writes++;
    starred[datasetId] = Set.of(indexes);
  }

  @override
  Future<List<String>> learnedKeys() async => const [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    dir = await Directory.systemTemp.createTemp('pe_guard');
  });
  tearDown(() async => dir.delete(recursive: true));

  Future<Directory> base() async => dir;

  Future<(MigrationReport, WordStateRepository)> enter(
      _MemGateway gw, List<WordDataset> ds) async {
    final states = WordStateRepository(baseDir: base);
    final report =
        await LegacyMigration(gateway: gw, wordStates: states, baseDir: base)
            .run(ds);
    return (report, states);
  }

  Future<void> corruptWordState() async {
    final path = '${dir.path}/${WordStateRepository.fileName}';
    await File(path).writeAsString('{not json');
    await File('$path.bak').writeAsString('{also broken');
  }

  final original = [
    _ds(['ngsl_2809_0000', 'ngsl_2809_0001', 'ngsl_2809_0002'])
  ];
  final reordered = [
    _ds(['ngsl_2809_0000', 'ngsl_2809_0002', 'ngsl_2809_0001'])
  ];

  test('store reports corrupt read; missing file is not corrupt', () async {
    final store = JsonFileStore(File('${dir.path}/x.json'));
    expect(await store.read(), isNull);
    expect(store.lastReadCorrupt, isFalse);
    await File('${dir.path}/x.json').writeAsString('{bad');
    expect(await store.read(), isNull);
    expect(store.lastReadCorrupt, isTrue);
    await store.write({'a': 1});
    expect(await store.read(), {'a': 1});
    expect(store.lastReadCorrupt, isFalse);
  });

  test('changed dataset + corrupt word state: V1 ★ is not wiped', () async {
    await enter(_MemGateway({'ngsl_2809': {1}}), original);
    await corruptWordState();

    final gw = _MemGateway({'ngsl_2809': {1}});
    final (report, states) = await enter(gw, reordered);
    expect(states.rebuiltFromCorruption, isTrue);
    expect(report.repairedDatasets, isEmpty);
    expect(report.repairSkippedDatasets, ['ngsl_2809']);
    expect(gw.writes, 0);
    expect(gw.starred['ngsl_2809'], {1});
    // V1 ★ 為準：V2 與 V1 目前顯示的星號一致
    expect(states.get('ngsl_2809_0002').weak, isTrue);

    // 下次進入：狀態檔已正常寫回、教材已相容，不再寫 V1
    final gw2 = _MemGateway({'ngsl_2809': {1}});
    final (report2, states2) = await enter(gw2, reordered);
    expect(states2.rebuiltFromCorruption, isFalse);
    expect(report2.compatibleDatasets, ['ngsl_2809']);
    expect(gw2.writes, 0);
  });

  test('changed dataset with healthy word state still repairs V1 ★', () async {
    await enter(_MemGateway({'ngsl_2809': {1}}), original);
    final gw = _MemGateway({'ngsl_2809': {1}});
    final (report, states) = await enter(gw, reordered);
    expect(states.rebuiltFromCorruption, isFalse);
    expect(report.repairedDatasets, ['ngsl_2809']);
    expect(gw.starred['ngsl_2809'], {2});
  });

  test('compatible dataset + corrupt word state rebuilds weak from V1 ★',
      () async {
    await enter(_MemGateway({'ngsl_2809': {0, 2}}), original);
    await corruptWordState();
    final gw = _MemGateway({'ngsl_2809': {0, 2}});
    final (report, states) = await enter(gw, original);
    expect(report.compatibleDatasets, ['ngsl_2809']);
    expect(gw.writes, 0);
    expect(states.get('ngsl_2809_0000').weak, isTrue);
    expect(states.get('ngsl_2809_0002').weak, isTrue);
  });
}
