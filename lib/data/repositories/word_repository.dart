import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../domain/models/word_item.dart';

/// 教材資料的統一存取介面。
/// 目前實作是讀本地 assets JSON；第二階段接上 Firebase 時，
/// 只需要新增一個 FirebaseWordRepository 實作同一個介面，
/// 上層的播放邏輯、UI 完全不用改。
abstract class WordRepository {
  Future<List<WordDataset>> loadAllDatasets();
}

class LocalAssetWordRepository implements WordRepository {
  static const _files = [
    'assets/data/ngsl_2809.json',
    'assets/data/ngsl_spoken_720.json',
    'assets/data/phrase_list_506.json',
    'assets/data/phave_list_150.json',
  ];

  @override
  Future<List<WordDataset>> loadAllDatasets() async {
    final results = <WordDataset>[];
    for (final path in _files) {
      final raw = await rootBundle.loadString(path);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      json['builtIn'] = true;
      results.add(WordDataset.fromJson(json));
    }
    return results;
  }
}
