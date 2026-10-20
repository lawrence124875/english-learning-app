import 'package:flutter/foundation.dart';

/// Practical English 就緒開關（SPEC §16、架構確認版 §9）。
///
/// 關閉時：首頁選單看不到「實用英文」與「新功能」，啟動時也不會跳出
/// What's New（也不寫入 What's New 的判斷資料，之後開啟時 V1 舊使用者
/// 仍會看到一次）。
///
/// 開啟必須是單獨一個 commit，並經 Lawrence 批准。門檻：≥300 句已審英文
/// 句子、≥100 句免費可學、選單中每種翻譯語言覆蓋率 ≥95% 且抽樣錯誤率 ≤3%、
/// 全部測試與實機／V1 回歸驗收通過。
class PracticalEnglishRelease {
  PracticalEnglishRelease._();

  static const bool ready = true;

  /// 測試用：覆寫開關。
  @visibleForTesting
  static bool? debugOverride;

  static bool get enabled => debugOverride ?? ready;
}
