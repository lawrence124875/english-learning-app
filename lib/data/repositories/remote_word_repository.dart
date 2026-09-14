import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/word_item.dart';
import 'word_repository.dart';

/// 內容雲端化版本的單字資料 repository。
///
/// 運作方式：
/// 1. App 啟動時，先嘗試從 Firebase Storage 抓 manifest.json 的版本號。
/// 2. 如果雲端版本比本機快取新（或本機還沒有快取），下載四份教材 JSON
///    存到 App 的本機文件目錄，並更新快取版本號。
/// 3. 實際載入資料時，優先用本機快取檔案；如果從來沒抓過雲端資料
///    （例如第一次啟動就沒有網路），退回使用隨 App 內建的 assets 版本，
///    確保離線時 App 仍然完全可用。
///
/// 這樣設計的好處：之後修正單字翻譯錯字、或加入日文/韓文/越南文，
/// 只需要更新 Firebase Storage 上的檔案並提高版本號，使用者下次開啟
/// App 就會自動抓到最新內容，不需要重新送審、重新上架。
class RemoteWordRepository implements WordRepository {
  static const _manifestPath = 'content/manifest.json';
  static const _cachedVersionKey = 'content_cached_version_v1';
  static const _fetchTimeout = Duration(seconds: 6);

  static const _bundledFiles = {
    'ngsl_2809': 'assets/data/ngsl_2809.json',
    'ngsl_spoken_720': 'assets/data/ngsl_spoken_720.json',
    'phrase_list_506': 'assets/data/phrase_list_506.json',
    'phave_list_150': 'assets/data/phave_list_150.json',
  };

  Future<void> _trySyncFromCloud() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedVersion = prefs.getInt(_cachedVersionKey) ?? 0;

      final manifestRef = FirebaseStorage.instance.ref(_manifestPath);
      final manifestBytes =
          await manifestRef.getData(5 * 1024 * 1024).timeout(_fetchTimeout);
      if (manifestBytes == null) return;

      final manifest =
          jsonDecode(utf8.decode(manifestBytes)) as Map<String, dynamic>;
      final remoteVersion = manifest['version'] as int? ?? 0;

      if (remoteVersion <= cachedVersion) {
        return; // 已經是最新版本，不用重抓。
      }

      final datasets = manifest['datasets'] as Map<String, dynamic>;
      final dir = await getApplicationDocumentsDirectory();

      for (final entry in datasets.entries) {
        final datasetId = entry.key;
        final fileName = (entry.value as Map<String, dynamic>)['file'] as String;
        final ref = FirebaseStorage.instance.ref('content/$fileName');
        final data =
            await ref.getData(20 * 1024 * 1024).timeout(_fetchTimeout);
        if (data == null) continue; // 單一檔案失敗不影響其他檔案。
        final file = File('${dir.path}/content_$datasetId.json');
        await file.writeAsBytes(data);
      }

      await prefs.setInt(_cachedVersionKey, remoteVersion);
    } catch (_) {
      // 沒有網路、Storage 還沒設定內容、逾時等狀況都靜默失敗，
      // 直接使用本機快取或內建 assets，不影響 App 正常啟動。
    }
  }

  Future<WordDataset?> _loadFromLocalCache(String datasetId) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/content_$datasetId.json');
      if (!await file.exists()) return null;
      final raw = await file.readAsString();
      return WordDataset.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<WordDataset> _loadFromBundledAssets(
      String datasetId, String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    return WordDataset.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<List<WordDataset>> loadAllDatasets() async {
    await _trySyncFromCloud();

    final results = <WordDataset>[];
    for (final entry in _bundledFiles.entries) {
      final cached = await _loadFromLocalCache(entry.key);
      results.add(cached ?? await _loadFromBundledAssets(entry.key, entry.value));
    }
    return results;
  }
}
