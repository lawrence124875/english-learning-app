import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 使用者意見回饋類別。
/// （顯示文字放在畫面層依語言翻譯，這裡只保留代碼，寫進資料庫的
/// 永遠是 bug / suggestion / other，方便在後台統一篩選。）
enum FeedbackCategory { bug, suggestion, other }

/// 意見回饋服務：把使用者填寫的內容送進 Firestore「feedback」集合。
/// 只寫入，不讀取（Firestore 安全規則需設定成 create-only，
/// 避免使用者端能讀到其他人的回饋內容，詳見 FIRESTORE_RULES.md）。
class FeedbackService {
  static Future<void> submit({
    required String message,
    required FeedbackCategory category,
    String? contactEmail,
    String? locale,
  }) async {
    final info = await PackageInfo.fromPlatform();
    await FirebaseFirestore.instance.collection('feedback').add({
      'message': message,
      'category': category.name,
      'contactEmail': contactEmail,
      'appVersion': '${info.version}+${info.buildNumber}',
      'platform': 'android',
      // 使用者當時的 App 介面語言，方便判斷該用哪種語言回覆
      'locale': locale,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
