import 'dart:convert';

/// 免費版規則（2026-10-28 定案，v24 起）。數字集中在這裡，畫面與測試共用。
class FreeTierRules {
  /// 單字教材：前 1/3 免費（不分段）。
  static const unlockFraction = 1 / 3;

  /// 每看一次獎勵廣告，在 1/3 之後多開的數量。
  static const rewardedUnlockAmount = 20;

  /// 獎勵廣告每日上限（本機日期）。
  static const rewardedDailyLimit = 3;

  /// 不熟悉單字庫：所有教材合計上限。
  static const starredLimit = 30;

  /// V2 實用英文：每天最多幾句。
  static const peDailySentences = 5;
}

/// 本機日期字串（yyyy-mm-dd），當作「當天」的判斷依據。
String freeTierDayKey(DateTime now) =>
    '${now.year.toString().padLeft(4, '0')}-'
    '${now.month.toString().padLeft(2, '0')}-'
    '${now.day.toString().padLeft(2, '0')}';

/// 免費版「當天」的額度紀錄：獎勵廣告次數與各教材額外解鎖量、
/// 今天已使用的 V2 句子。存在 SharedPreferences，重開 App 仍保留；
/// 日期一換就全部歸零、不累積。
class FreeDailyState {
  final String day;
  final int rewardedUses;
  final Map<String, int> extraUnlocked;
  final Set<String> peSentenceIds;

  const FreeDailyState({
    required this.day,
    this.rewardedUses = 0,
    this.extraUnlocked = const {},
    this.peSentenceIds = const {},
  });

  static const prefsKey = 'free_daily_v1';

  /// 若紀錄不是 [today] 的，回傳全新的一天。
  FreeDailyState forDay(String today) =>
      day == today ? this : FreeDailyState(day: today);

  int get rewardedLeft =>
      (FreeTierRules.rewardedDailyLimit - rewardedUses).clamp(0, 1 << 30);

  bool get canUseRewarded => rewardedLeft > 0;

  /// 用掉一次獎勵廣告，[datasetId] 多開 20 個。已達上限時回傳 null。
  FreeDailyState? withRewardedUnlock(String datasetId) {
    if (!canUseRewarded) return null;
    return FreeDailyState(
      day: day,
      rewardedUses: rewardedUses + 1,
      extraUnlocked: {
        ...extraUnlocked,
        datasetId:
            (extraUnlocked[datasetId] ?? 0) + FreeTierRules.rewardedUnlockAmount,
      },
      peSentenceIds: peSentenceIds,
    );
  }

  /// 今天還能不能開這一句（已開過的句子重看不另計）。
  bool canUsePeSentence(String id) =>
      peSentenceIds.contains(id) ||
      peSentenceIds.length < FreeTierRules.peDailySentences;

  FreeDailyState withPeSentence(String id) => peSentenceIds.contains(id)
      ? this
      : FreeDailyState(
          day: day,
          rewardedUses: rewardedUses,
          extraUnlocked: extraUnlocked,
          peSentenceIds: {...peSentenceIds, id},
        );

  String toJsonString() => jsonEncode({
        'day': day,
        'rewardedUses': rewardedUses,
        'extra': extraUnlocked,
        'pe': peSentenceIds.toList(),
      });

  /// 解析失敗（舊格式、損毀）時當成全新的一天，絕不丟例外。
  static FreeDailyState fromJsonString(String? raw, String today) {
    if (raw == null) return FreeDailyState(day: today);
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return FreeDailyState(
        day: m['day'] as String,
        rewardedUses: (m['rewardedUses'] as num).toInt(),
        extraUnlocked: (m['extra'] as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, (v as num).toInt())),
        peSentenceIds: (m['pe'] as List).cast<String>().toSet(),
      ).forDay(today);
    } catch (_) {
      return FreeDailyState(day: today);
    }
  }
}

/// 加星號的結果：已加入、已移除，或免費版已滿 30 個而沒加入。
enum StarToggleResult { added, removed, limitReached }
