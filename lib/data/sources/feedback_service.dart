import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 使用者意見回饋類別。
enum FeedbackCategory { bug, suggestion, other }

extension FeedbackCategoryLabel on FeedbackCategory {
  String get label {
    switch (this) {
      case FeedbackCategory.bug:
        return '回報問題';
      case FeedbackCategory.suggestion:
        return '功能建議';
      case FeedbackCategory.other:
        return '其他';
    }
  }
}

/// 意見回饋服務：把使用者填寫的內容送進 Firestore「feedback」集合。
/// 只寫入，不讀取（Firestore 安全規則需設定成 create-only，
/// 避免使用者端能讀到其他人的回饋內容，詳見 FIRESTORE_RULES.md）。
class FeedbackService {
  static Future<void> submit({
    required String message,
    required FeedbackCategory category,
    String? contactEmail,
  }) async {
    final info = await PackageInfo.fromPlatform();
    await FirebaseFirestore.instance.collection('feedback').add({
      'message': message,
      'category': category.name,
      'contactEmail': contactEmail,
      'appVersion': '${info.version}+${info.buildNumber}',
      'platform': 'android',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
