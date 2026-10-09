import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../presentation/app_theme.dart';
import '../../data/sentence_now_playing.dart';
import '../../domain/models/sentence.dart';
import '../../domain/services/sentence_selector.dart';
import '../providers/practical_english_state.dart';
import '../providers/sentence_player.dart';
import '../widgets/translation_text.dart';
import '../widgets/word_status_label.dart';

/// 句子學習與播放頁（設計圖 ②③④）。[sentences] 是進入時的列表快照：
/// 標記弱字／我會了會讓主列表重新排序，但這裡的上一句／下一句順序不跟著跳動。
///
/// 播放由 [SentencePlayer] 負責：連續播放、手動逐句、與 V1 共用 TTS、
/// 接管鎖屏。離開這一頁就停止播放並交還鎖屏。
class SentenceDetailScreen extends StatefulWidget {
  final List<Sentence> sentences;
  final int initialIndex;

  const SentenceDetailScreen({
    super.key,
    required this.sentences,
    required this.initialIndex,
  });

  @override
  State<SentenceDetailScreen> createState() => _SentenceDetailScreenState();
}

class _SentenceDetailScreenState extends State<SentenceDetailScreen> {
  late final PracticalEnglishState _state =
      context.read<PracticalEnglishState>();
  late final SentencePlayer _player;

  @override
  void initState() {
    super.initState();
    final handler = _state.audioHandler;
    _player = SentencePlayer(
      state: _state,
      tts: _state.tts,
      playback: _state.playbackCoordinator,
      sentences: widget.sentences,
      initialIndex: widget.initialIndex,
      onError: (_, __) => _snack(AppLocalizations.of(context)!.peTtsFailed),
      nowPlaying: handler == null
          ? null
          : (p) => AudioHandlerSentenceNowPlaying(handler, p),
    )..onVoiceUnavailable =
        (_) => _snack(AppLocalizations.of(context)!.peVoiceUnavailable);
    _player.loadSettings();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _state.recordPractice(_player.current));
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// 手動操作：連續播放中按下時提示一次「已停止連續播放」。
  void _manual(Future<bool> Function() action) {
    if (_player.isAutoPlaying) {
      _snack(AppLocalizations.of(context)!.peAutoStopped);
    }
    action();
  }

  Future<void> _playTranslation() async {
    if (_player.isAutoPlaying) await _player.pause();
    final l10n = AppLocalizations.of(context)!;
    final result = await _state.speakTranslation(_player.current);
    if (result == TranslationSpeechResult.voiceUnavailable) {
      _snack(l10n.peVoiceUnavailable);
    } else if (result == TranslationSpeechResult.failed) {
      _snack(l10n.peTtsFailed);
    }
  }

  String _seconds(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  String _summary(AppLocalizations l10n, SentencePlaybackSettings s) =>
      l10n.peSettingsSummary(
          s.readTranslation ? l10n.peEnglishAndTranslation : l10n.peEnglishOnly,
          s.repeatCount,
          _seconds(s.intervalSeconds));

  void _openSettings() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => ListenableBuilder(
        listenable: _player,
        builder: (context, _) => _SettingsSheet(
          player: _player,
          speechRate: _state.speechRate,
          onRate: _state.setSpeechRate,
          seconds: _seconds,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = AppPalette.of(context);
    final state = context.watch<PracticalEnglishState>();
    final text = Theme.of(context).textTheme;
    return ListenableBuilder(
      listenable: _player,
      builder: (context, _) {
        final s = _player.current;
        final groups = state.wordGroups(s);
        final others = state.otherWordsOf(s);
        final hasTranslation = state.translationFor(s) != null;
        final total = widget.sentences.length;
        final meta = [s.category, s.level].whereType<String>().join(' · ');
        return Scaffold(
          backgroundColor: palette.bgBottom,
          appBar: AppBar(
            title: Text(l10n.peTitle),
            backgroundColor: palette.bgTop,
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              children: [
                Card(
                  color: palette.card,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text('No. ${_player.index + 1} / $total',
                                key: const Key('pe_position'),
                                style: text.bodySmall
                                    ?.copyWith(color: palette.muted)),
                            const Spacer(),
                            Text(meta,
                                style: text.bodySmall
                                    ?.copyWith(color: palette.muted)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: (_player.index + 1) / total,
                            minHeight: 4,
                            backgroundColor: palette.track,
                          ),
                        ),
                        const SizedBox(height: 36),
                        _HighlightedSentence(
                          key: const Key('pe_detail_sentence'),
                          text: s.sentenceText,
                          words: [for (final g in groups) g.word],
                          style: text.headlineSmall?.copyWith(
                              color: palette.word,
                              fontWeight: FontWeight.w600,
                              height: 1.35),
                          highlight:
                              Theme.of(context).colorScheme.primaryContainer,
                        ),
                        const SizedBox(height: 12),
                        TranslationText(
                          state: state,
                          sentence: s,
                          textAlign: TextAlign.center,
                          style: text.titleMedium
                              ?.copyWith(color: palette.translation),
                        ),
                        const SizedBox(height: 36),
                        Wrap(
                          // 長語言（越南文等）在窄螢幕自動換行，不溢出。
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _Pill(
                              key: const Key('pe_prev'),
                              icon: Icons.skip_previous,
                              label: l10n.pePrevious,
                              onTap: () => _manual(_player.previous),
                            ),
                            FilledButton.icon(
                              key: const Key('pe_autoplay'),
                              onPressed: _player.togglePlay,
                              icon: Icon(_player.isAutoPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow),
                              label: Text(_player.isAutoPlaying
                                  ? l10n.pePause
                                  : l10n.peAutoPlay),
                            ),
                            _Pill(
                              key: const Key('pe_next'),
                              icon: Icons.skip_next,
                              label: l10n.peNext,
                              trailing: true,
                              onTap: () => _manual(_player.next),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            TextButton.icon(
                              key: const Key('pe_play'),
                              onPressed: () => _manual(_player.replay),
                              icon: const Icon(Icons.replay, size: 18),
                              label: Text(l10n.peReplay),
                            ),
                            if (hasTranslation)
                              TextButton.icon(
                                key: const Key('pe_play_translation'),
                                onPressed: _playTranslation,
                                icon: const Icon(Icons.translate, size: 18),
                                label: Text(l10n.pePlayTranslation),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Material(
                  color: palette.softRow,
                  borderRadius: BorderRadius.circular(14),
                  child: ListTile(
                    key: const Key('pe_playback_settings'),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    leading: const Icon(Icons.tune),
                    title: Text(l10n.pePlaybackSettings),
                    subtitle: Text(_summary(l10n, _player.settings)),
                    trailing: const Icon(Icons.expand_more),
                    onTap: _openSettings,
                  ),
                ),
                const SizedBox(height: 16),
                Text(l10n.peTargetWords, style: text.titleSmall),
                const SizedBox(height: 4),
                for (final group in groups)
                  for (final ref in group.refs)
                    _WordRow(wordRef: ref, showList: group.refs.length > 1),
                if (others.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(l10n.peOtherWords, style: text.titleSmall),
                  const SizedBox(height: 4),
                  for (final ref in others) _WordRow(wordRef: ref),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 上一句／下一句的小膠囊按鈕（同 V1 單字頁）。
class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool trailing;

  const _Pill(
      {super.key,
      required this.icon,
      required this.label,
      required this.onTap,
      this.trailing = false});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final iconWidget = Icon(icon, size: 18, color: palette.onPill);
    final labelWidget =
        Text(label, style: TextStyle(color: palette.onPill, fontSize: 13));
    return Material(
      color: palette.pill,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: trailing
                ? [labelWidget, const SizedBox(width: 4), iconWidget]
                : [iconWidget, const SizedBox(width: 4), labelWidget],
          ),
        ),
      ),
    );
  }
}

/// 英文句子，目標單字（含 missed、years 這類變化形）加底色。
class _HighlightedSentence extends StatelessWidget {
  final String text;
  final List<String> words;
  final TextStyle? style;
  final Color highlight;

  const _HighlightedSentence(
      {super.key,
      required this.text,
      required this.words,
      required this.style,
      required this.highlight});

  @override
  Widget build(BuildContext context) {
    final usable = words.where((w) => w.trim().isNotEmpty).toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    final spans = <TextSpan>[];
    if (usable.isEmpty) {
      spans.add(TextSpan(text: text));
    } else {
      final pattern = RegExp(
          r'\b(' + usable.map(RegExp.escape).join('|') + r")[\w'’-]*",
          caseSensitive: false);
      var last = 0;
      for (final m in pattern.allMatches(text)) {
        if (m.start > last)
          spans.add(TextSpan(text: text.substring(last, m.start)));
        spans.add(TextSpan(
            text: m.group(0), style: TextStyle(backgroundColor: highlight)));
        last = m.end;
      }
      if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
    }
    return Text.rich(
      TextSpan(style: style, children: spans),
      textAlign: TextAlign.center,
      // 句子一律由左到右（阿拉伯文介面也一樣）。
      textDirection: TextDirection.ltr,
    );
  }
}

/// 播放設定（設計圖 ④）。
class _SettingsSheet extends StatelessWidget {
  final SentencePlayer player;
  final double speechRate;
  final Future<void> Function(double) onRate;
  final String Function(double) seconds;

  const _SettingsSheet(
      {required this.player,
      required this.speechRate,
      required this.onRate,
      required this.seconds});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final s = player.settings;
    Widget row(String label, Widget control) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(child: Text(label)),
              control,
            ],
          ),
        );
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.pePlaybackSettings,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(l10n.peReadContent),
            const SizedBox(height: 6),
            SegmentedButton<bool>(
              key: const Key('pe_setting_translation'),
              segments: [
                ButtonSegment(value: false, label: Text(l10n.peEnglishOnly)),
                ButtonSegment(
                    value: true, label: Text(l10n.peEnglishAndTranslation)),
              ],
              selected: {s.readTranslation},
              showSelectedIcon: false,
              onSelectionChanged: (v) =>
                  player.updateSettings(s.copyWith(readTranslation: v.first)),
            ),
            row(
              l10n.peRepeatCount,
              SegmentedButton<int>(
                key: const Key('pe_setting_repeat'),
                segments: [
                  for (final n in const [1, 2, 3])
                    ButtonSegment(value: n, label: Text('$n')),
                ],
                selected: {s.repeatCount},
                showSelectedIcon: false,
                onSelectionChanged: (v) =>
                    player.updateSettings(s.copyWith(repeatCount: v.first)),
              ),
            ),
            row(
              l10n.peInterval,
              SegmentedButton<double>(
                key: const Key('pe_setting_interval'),
                segments: [
                  for (final n in const [1.0, 2.0, 4.0])
                    ButtonSegment(
                        value: n, label: Text(l10n.peSecondsValue(seconds(n)))),
                ],
                selected: {s.intervalSeconds},
                emptySelectionAllowed: true,
                showSelectedIcon: false,
                onSelectionChanged: (v) {
                  if (v.isNotEmpty) {
                    player.updateSettings(s.copyWith(intervalSeconds: v.first));
                  }
                },
              ),
            ),
            const SizedBox(height: 4),
            _RateSlider(initial: speechRate, onChanged: onRate),
            Text(l10n.peRateShared,
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _RateSlider extends StatefulWidget {
  final double initial;
  final Future<void> Function(double) onChanged;

  const _RateSlider({required this.initial, required this.onChanged});

  @override
  State<_RateSlider> createState() => _RateSliderState();
}

class _RateSliderState extends State<_RateSlider> {
  late double _rate = widget.initial.clamp(0.3, 1.5);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.speechRateLabel(_rate.toStringAsFixed(1))),
        Slider(
          key: const Key('pe_setting_rate'),
          value: _rate,
          min: 0.3,
          max: 1.5,
          divisions: 24,
          onChanged: (v) => setState(() => _rate = v),
          onChangeEnd: widget.onChanged,
        ),
      ],
    );
  }
}

class _WordRow extends StatelessWidget {
  final String wordRef;

  /// 同拼字出現在多份清單時，標出這一筆屬於哪份清單（SPEC §9.6）。
  final bool showList;

  const _WordRow({required this.wordRef, this.showList = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = context.watch<PracticalEnglishState>();
    final location = state.wordFor(wordRef);
    final word = location?.item.word ?? wordRef;
    final meaning = state.meaningFor(wordRef);
    final status = state.statusOf(wordRef);
    final weak = status == WordStatus.weak;
    final mastered = status == WordStatus.mastered;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                      showList && location != null
                          ? '$word · ${location.dataset.shortName}'
                          : word,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                WordStatusChip(word: word, status: status),
              ],
            ),
            if (meaning != null) Text(meaning),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                  key: Key('pe_weak_$wordRef'),
                  onPressed: () => state.setWeak(wordRef, !weak),
                  child: Text(weak ? l10n.peUnmarkWeak : l10n.peMarkWeak),
                ),
                FilledButton.tonal(
                  key: Key('pe_mastered_$wordRef'),
                  onPressed: () => state.setMastered(wordRef, !mastered),
                  child: Text(mastered ? l10n.peUndoMastered : l10n.peIKnowIt),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
