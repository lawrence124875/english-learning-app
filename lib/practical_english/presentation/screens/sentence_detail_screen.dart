import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../domain/models/sentence.dart';
import '../../domain/services/sentence_selector.dart';
import '../providers/practical_english_state.dart';
import '../widgets/word_status_label.dart';

/// 句子學習頁。[sentences] 是進入時的列表快照：標記弱字／我會了會讓
/// 主列表重新排序，但這裡的上一句／下一句順序不跟著跳動。
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
  late int _index = widget.initialIndex;
  late final PracticalEnglishState _state =
      context.read<PracticalEnglishState>();

  Sentence get _sentence => widget.sentences[_index];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _state.recordPractice(_sentence));
  }

  @override
  void dispose() {
    _state.stopSpeaking();
    super.dispose();
  }

  void _go(int delta) {
    final next = _index + delta;
    if (next < 0 || next >= widget.sentences.length) return;
    _state.stopSpeaking();
    setState(() => _index = next);
    _state.recordPractice(_sentence);
  }

  Future<void> _play() async {
    final ok = await _state.speak(_sentence);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.peTtsFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = context.watch<PracticalEnglishState>();
    final s = _sentence;
    final translation = state.translationFor(s);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('${_index + 1} / ${widget.sentences.length}'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(s.sentenceText,
                key: const Key('pe_detail_sentence'),
                style: text.headlineSmall),
            if (translation != null) ...[
              const SizedBox(height: 8),
              Text(translation, style: text.titleMedium),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FilledButton.icon(
                key: const Key('pe_play'),
                onPressed: _play,
                icon: const Icon(Icons.volume_up),
                label: Text(l10n.pePlay),
              ),
            ),
            const SizedBox(height: 20),
            Text(l10n.peTargetWords, style: text.titleSmall),
            const SizedBox(height: 4),
            for (final ref in s.wordIds.toSet()) _WordRow(wordRef: ref),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('pe_prev'),
                  onPressed: _index > 0 ? () => _go(-1) : null,
                  icon: const Icon(Icons.chevron_left),
                  label: Text(l10n.pePrevious),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('pe_next'),
                  onPressed: _index < widget.sentences.length - 1
                      ? () => _go(1)
                      : null,
                  icon: const Icon(Icons.chevron_right),
                  label: Text(l10n.peNext),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WordRow extends StatelessWidget {
  final String wordRef;

  const _WordRow({required this.wordRef});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = context.watch<PracticalEnglishState>();
    final word = state.wordFor(wordRef)?.item.word ?? wordRef;
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
                  child: Text(word,
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
