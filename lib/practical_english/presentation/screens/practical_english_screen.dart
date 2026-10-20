import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/sources/tts_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../presentation/providers/app_state.dart';
import '../../domain/models/sentence.dart';
import '../../domain/services/sentence_selector.dart';
import '../providers/practical_english_state.dart';
import '../widgets/translation_language_picker.dart';
import '../widgets/translation_text.dart';
import '../widgets/word_status_label.dart';
import 'sentence_detail_screen.dart';
import 'sentence_import_screen.dart';

/// Practical English 主畫面。PracticalEnglishState 隨這個 route 建立／釋放，
/// V1 啟動與主畫面完全不受影響。
class PracticalEnglishScreen extends StatelessWidget {
  /// 測試用：直接給一個已建立的 state（由呼叫端負責 dispose）。
  final PracticalEnglishState? state;

  const PracticalEnglishScreen({super.key, this.state});

  @override
  Widget build(BuildContext context) {
    final injected = state;
    if (injected != null) {
      return ChangeNotifierProvider<PracticalEnglishState>.value(
        value: injected,
        child: const _PracticalEnglishView(),
      );
    }
    return ChangeNotifierProvider<PracticalEnglishState>(
      create: (ctx) => PracticalEnglishState(
        appState: ctx.read<AppState>(),
        tts: ctx.read<TtsService>(),
      )..load(),
      child: const _PracticalEnglishView(),
    );
  }
}

class _PracticalEnglishView extends StatelessWidget {
  const _PracticalEnglishView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = context.watch<PracticalEnglishState>();
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.peTitle),
        actions: [
          if (state.isReady)
            IconButton(
              key: const Key('pe_translation_action'),
              tooltip: l10n.peTranslationLanguage,
              icon: const Icon(Icons.translate),
              onPressed: () => showTranslationLanguagePicker(context, state),
            ),
          if (state.isReady)
            IconButton(
              key: const Key('pe_import_action'),
              tooltip: l10n.peImportTitle,
              icon: const Icon(Icons.upload_file),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: state,
                    child: const SentenceImportScreen(),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(child: _body(context, state, l10n)),
    );
  }

  Widget _body(BuildContext context, PracticalEnglishState state,
      AppLocalizations l10n) {
    switch (state.status) {
      case PracticalEnglishLoadStatus.idle:
      case PracticalEnglishLoadStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case PracticalEnglishLoadStatus.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.peLoadFailed),
              const SizedBox(height: 12),
              FilledButton(onPressed: state.load, child: Text(l10n.peRetry)),
            ],
          ),
        );
      case PracticalEnglishLoadStatus.ready:
        break;
    }

    final sentences = state.sentences;
    final locked = state.lockedCount;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SegmentedButton<LearningMode>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                    value: LearningMode.weakPriority,
                    label: Text(l10n.peModeWeakPriority)),
                ButtonSegment(
                    value: LearningMode.weakOnly,
                    label: Text(l10n.peModeWeakOnly)),
                ButtonSegment(
                    value: LearningMode.all, label: Text(l10n.peModeAll)),
              ],
              selected: {state.mode},
              onSelectionChanged: (s) => state.setMode(s.first),
            ),
          ),
        ),
        SliverToBoxAdapter(child: _CoverageCard(state: state)),
        if (locked > 0 && !state.isPremium)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline, size: 16),
                  const SizedBox(width: 6),
                  Expanded(child: Text(l10n.peLockedCount(locked))),
                ],
              ),
            ),
          ),
        if (sentences.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.mode == LearningMode.weakOnly
                      ? l10n.peEmptyWeakOnly
                      : l10n.peEmpty,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )
        else
          SliverList.builder(
            itemCount: sentences.length,
            itemBuilder: (context, i) =>
                _SentenceTile(sentences: sentences, index: i),
          ),
      ],
    );
  }
}

class _CoverageCard extends StatelessWidget {
  final PracticalEnglishState state;

  const _CoverageCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = state.coverage;
    final text = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.peCoverageTitle, style: text.titleSmall),
            const SizedBox(height: 6),
            Text(l10n.peCoverageSentences(
                c.accessibleSentences, c.totalSentences)),
            Text(l10n.peCoverageWords(c.wordsWithSentences, c.totalWords)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                for (final s in WordStatus.values)
                  Text('${wordStatusLabel(l10n, s)} ${c.count(s)}',
                      style: text.bodySmall),
                Text('${l10n.peCoveragePracticed} ${c.practicedWords}',
                    style: text.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SentenceTile extends StatelessWidget {
  final List<Sentence> sentences;
  final int index;

  const _SentenceTile({required this.sentences, required this.index});

  @override
  Widget build(BuildContext context) {
    final state = context.read<PracticalEnglishState>();
    final s = sentences[index];
    return ListTile(
      key: ValueKey('pe_sentence_${s.id}'),
      title: Text(s.sentenceText),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TranslationText(state: state, sentence: s),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final group in state.wordGroups(s))
                Builder(builder: (_) {
                  final (status, differs) = WordStatusChip.combine(
                      [for (final r in group.refs) state.statusOf(r)]);
                  return WordStatusChip(
                      word: group.word, status: status, differs: differs);
                }),
            ],
          ),
        ],
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: state,
            child: SentenceDetailScreen(
                sentences: List.of(sentences), initialIndex: index),
          ),
        ),
      ),
    );
  }
}
