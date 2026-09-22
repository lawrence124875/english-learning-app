import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/word_item.dart';

/// 使用者自己匯入的教材，存在裝置本機（App 文件夾），不會上傳到
/// 任何伺服器。每份自訂教材存成一個獨立的 JSON 檔案，
/// SharedPreferences 只記錄「目前有哪些自訂教材的 id 清單」。
class CustomDatasetRepository {
  static const _idsKey = 'custom_dataset_ids';

  Future<Directory> _dir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/custom_datasets');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<List<String>> _loadIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_idsKey) ?? [];
  }

  Future<void> _saveIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_idsKey, ids);
  }

  /// 載入使用者目前已匯入的所有自訂教材。
  Future<List<WordDataset>> loadAll() async {
    final ids = await _loadIds();
    final dir = await _dir();
    final result = <WordDataset>[];
    for (final id in ids) {
      final file = File('${dir.path}/$id.json');
      if (await file.exists()) {
        try {
          final json = jsonDecode(await file.readAsString());
          result.add(WordDataset.fromJson(json as Map<String, dynamic>));
        } catch (_) {
          // 損毀的檔案就跳過，不影響其他教材載入。
        }
      }
    }
    return result;
  }

  /// 新增/覆蓋一份自訂教材。
  Future<void> save(WordDataset dataset) async {
    final dir = await _dir();
    final file = File('${dir.path}/${dataset.id}.json');
    final json = {
      'id': dataset.id,
      'name': dataset.name,
      'short': dataset.shortName,
      'items': dataset.items
          .map((w) => {'id': w.id, 'w': w.word, 'm': w.translations})
          .toList(),
    };
    await file.writeAsString(jsonEncode(json));

    final ids = await _loadIds();
    if (!ids.contains(dataset.id)) {
      ids.add(dataset.id);
      await _saveIds(ids);
    }
  }

  /// 刪除一份自訂教材。
  Future<void> delete(String datasetId) async {
    final dir = await _dir();
    final file = File('${dir.path}/$datasetId.json');
    if (await file.exists()) {
      await file.delete();
    }
    final ids = await _loadIds();
    ids.remove(datasetId);
    await _saveIds(ids);
  }
}
