/// 播放範圍模式，對應原網頁版四種模式。
enum ScopeMode {
  allRandom, // 全部清單（隨機播放）
  allSequential, // 全部清單（依序播放）
  starredRandom, // 僅不熟悉（隨機播放）
  starredSequential, // 僅不熟悉（依序播放）
}

/// 朗讀內容模式。
enum ReadMode {
  englishOnly, // 純英文
  bilingual, // 英雙讀（先英文，再中文）
}

/// 對應原網頁版的播放設定（語速、間隔、重複次數等）。
/// 這組設定是「全域」的，四份教材共用同一組朗讀偏好。
class PlaybackSettings {
  final ScopeMode scopeMode;
  final ReadMode readMode;
  final int repeatCount; // 英文重複朗讀次數：1-3
  final bool speakOnManualNavigate; // 手動切換單字時是否發音
  final bool showTranslation; // 顯示中文翻譯
  final double intervalSeconds; // 單字間隔停頓（秒）
  final double speechRate; // 朗讀語速
  final String? voiceId; // 選定的語音（系統 TTS voice identifier）
  final bool settingsPanelExpanded; // 設定面板是否展開（記住上次狀態）

  const PlaybackSettings({
    this.scopeMode = ScopeMode.allRandom,
    this.readMode = ReadMode.bilingual,
    this.repeatCount = 2,
    this.speakOnManualNavigate = true,
    this.showTranslation = true,
    this.intervalSeconds = 1.5,
    this.speechRate = 0.5,
    this.voiceId,
    this.settingsPanelExpanded = false,
  });

  PlaybackSettings copyWith({
    ScopeMode? scopeMode,
    ReadMode? readMode,
    int? repeatCount,
    bool? speakOnManualNavigate,
    bool? showTranslation,
    double? intervalSeconds,
    double? speechRate,
    String? voiceId,
    bool clearVoiceId = false,
    bool? settingsPanelExpanded,
  }) {
    return PlaybackSettings(
      scopeMode: scopeMode ?? this.scopeMode,
      readMode: readMode ?? this.readMode,
      repeatCount: repeatCount ?? this.repeatCount,
      speakOnManualNavigate:
          speakOnManualNavigate ?? this.speakOnManualNavigate,
      showTranslation: showTranslation ?? this.showTranslation,
      intervalSeconds: intervalSeconds ?? this.intervalSeconds,
      speechRate: speechRate ?? this.speechRate,
      voiceId: clearVoiceId ? null : (voiceId ?? this.voiceId),
      settingsPanelExpanded:
          settingsPanelExpanded ?? this.settingsPanelExpanded,
    );
  }

  /// 收合時顯示的一行設定摘要，例如「英雙讀・讀2次・0.9x」
  String get summaryLine {
    final readModeLabel =
        readMode == ReadMode.bilingual ? '英雙讀' : '純英文';
    return '$readModeLabel・讀$repeatCount次・${speechRate}x';
  }

  Map<String, dynamic> toJson() => {
        'scopeMode': scopeMode.index,
        'readMode': readMode.index,
        'repeatCount': repeatCount,
        'speakOnManualNavigate': speakOnManualNavigate,
        'showTranslation': showTranslation,
        'intervalSeconds': intervalSeconds,
        'speechRate': speechRate,
        'voiceId': voiceId,
        'settingsPanelExpanded': settingsPanelExpanded,
      };

  factory PlaybackSettings.fromJson(Map<String, dynamic> json) {
    return PlaybackSettings(
      scopeMode: ScopeMode.values[json['scopeMode'] as int? ?? 0],
      readMode: ReadMode.values[json['readMode'] as int? ?? 1],
      repeatCount: json['repeatCount'] as int? ?? 2,
      speakOnManualNavigate: json['speakOnManualNavigate'] as bool? ?? true,
      showTranslation: json['showTranslation'] as bool? ?? true,
      intervalSeconds:
          (json['intervalSeconds'] as num?)?.toDouble() ?? 1.5,
      speechRate: (json['speechRate'] as num?)?.toDouble() ?? 0.9,
      voiceId: json['voiceId'] as String?,
      settingsPanelExpanded: json['settingsPanelExpanded'] as bool? ?? false,
    );
  }
}

/// 每份教材各自獨立的播放進度狀態，對應原網頁版 datasetStates。
class DatasetPlaybackState {
  final List<int> playlist; // 洗牌/排序後的 index 清單
  final int currentStep;
  final int cycleCount;

  const DatasetPlaybackState({
    this.playlist = const [],
    this.currentStep = 0,
    this.cycleCount = 1,
  });

  DatasetPlaybackState copyWith({
    List<int>? playlist,
    int? currentStep,
    int? cycleCount,
  }) {
    return DatasetPlaybackState(
      playlist: playlist ?? this.playlist,
      currentStep: currentStep ?? this.currentStep,
      cycleCount: cycleCount ?? this.cycleCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'playlist': playlist,
        'currentStep': currentStep,
        'cycleCount': cycleCount,
      };

  factory DatasetPlaybackState.fromJson(Map<String, dynamic> json) {
    return DatasetPlaybackState(
      playlist: (json['playlist'] as List<dynamic>? ?? [])
          .map((e) => e as int)
          .toList(),
      currentStep: json['currentStep'] as int? ?? 0,
      cycleCount: json['cycleCount'] as int? ?? 1,
    );
  }
}
