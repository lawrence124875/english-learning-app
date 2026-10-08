/// 單一單字（以 WordRef 為鍵）在 V2 的學習狀態（SPEC §7.2、§9.1）。
/// 沒有任何狀態的單字不存檔，視為 unseen。
class WordLearningState {
  /// 弱字＝V1「不熟悉★」（同一個使用者訊號，雙向同步）。
  final bool weak;

  /// 只有使用者手動按「我會了」才會是 true。
  final bool mastered;

  /// V1 曾經朗讀過（exposure，不代表學會）。
  final bool exposedInV1;

  /// 在 Practical English 練習過的次數。
  final int peExposureCount;
  final DateTime? lastPracticedAt;

  const WordLearningState({
    this.weak = false,
    this.mastered = false,
    this.exposedInV1 = false,
    this.peExposureCount = 0,
    this.lastPracticedAt,
  });

  static const empty = WordLearningState();

  bool get isEmpty =>
      !weak &&
      !mastered &&
      !exposedInV1 &&
      peExposureCount == 0 &&
      lastPracticedAt == null;

  WordLearningState copyWith({
    bool? weak,
    bool? mastered,
    bool? exposedInV1,
    int? peExposureCount,
    DateTime? lastPracticedAt,
  }) {
    return WordLearningState(
      weak: weak ?? this.weak,
      mastered: mastered ?? this.mastered,
      exposedInV1: exposedInV1 ?? this.exposedInV1,
      peExposureCount: peExposureCount ?? this.peExposureCount,
      lastPracticedAt: lastPracticedAt ?? this.lastPracticedAt,
    );
  }

  factory WordLearningState.fromJson(Map<String, dynamic> json) {
    final last = json['lastPracticedAt'];
    return WordLearningState(
      weak: json['weak'] == true,
      mastered: json['mastered'] == true,
      exposedInV1: json['exposedInV1'] == true,
      peExposureCount: (json['peExposureCount'] as num?)?.toInt() ?? 0,
      lastPracticedAt: last is String ? DateTime.tryParse(last) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (weak) 'weak': true,
        if (mastered) 'mastered': true,
        if (exposedInV1) 'exposedInV1': true,
        if (peExposureCount > 0) 'peExposureCount': peExposureCount,
        if (lastPracticedAt != null)
          'lastPracticedAt': lastPracticedAt!.toUtc().toIso8601String(),
      };

  @override
  bool operator ==(Object other) =>
      other is WordLearningState &&
      other.weak == weak &&
      other.mastered == mastered &&
      other.exposedInV1 == exposedInV1 &&
      other.peExposureCount == peExposureCount &&
      other.lastPracticedAt == lastPracticedAt;

  @override
  int get hashCode =>
      Object.hash(weak, mastered, exposedInV1, peExposureCount, lastPracticedAt);
}
