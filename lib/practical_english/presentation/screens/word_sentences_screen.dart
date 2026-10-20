import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/sources/tts_service.dart';
import '../../../domain/models/word_item.dart';
import '../../../l10n/app_localizations.dart';
import '../../../presentation/providers/app_state.dart';
import '../../../presentation/screens/paywall_screen.dart';
import '../../domain/models/word_ref.dart';
import '../providers/practical_english_state.dart';
import 'sentence_detail_screen.dart';

/// 首頁「看例句」：直接打開含目前單字的句子（上一句／下一句只在這些句子之間）。
/// PracticalEnglishState 隨這個 route 建立／釋放，同實用英文主畫面。
class WordSentencesScreen extends StatelessWidget {
  final WordDataset dataset;
  final WordItem item;

  /// 測試用：直接給一個已載入的 state（由呼叫端負責 dispose）。
  final PracticalEnglishState? state;

  const WordSentencesScreen(
      {super.key, required this.dataset, required this.item, this.state});

  @override
  Widget build(BuildContext context) {
    final ref = WordRef.of(dataset, item);
    final injected = state;
    if (injected != null) {
      return ChangeNotifierProvider<PracticalEnglishState>.value(
        value: injected,
        child: _WordSentencesView(wordRef: ref, word: item.word),
      );
    }
    return ChangeNotifierProvider<PracticalEnglishState>(
      create: (ctx) => PracticalEnglishState(
        appState: ctx.read<AppState>(),
        tts: ctx.read<TtsService>(),
      )..load(),
      child: _WordSentencesView(wordRef: ref, word: item.word),
    );
  }
}

class _WordSentencesView extends StatelessWidget {
  final String wordRef;
  final String word;

  const _WordSentencesView({required this.wordRef, required this.word});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = context.watch<PracticalEnglishState>();
    Widget message(Widget child) => Scaffold(
          appBar: AppBar(title: Text(l10n.peTitle)),
          body: Center(
              child: Padding(padding: const EdgeInsets.all(24), child: child)),
        );
    switch (state.status) {
      case PracticalEnglishLoadStatus.idle:
      case PracticalEnglishLoadStatus.loading:
        return message(const CircularProgressIndicator());
      case PracticalEnglishLoadStatus.error:
        return message(Text(l10n.peLoadFailed));
      case PracticalEnglishLoadStatus.ready:
        break;
    }
    final sentences = state.sentencesForWord(wordRef);
    if (sentences.isEmpty && state.hasOnlyLockedSentencesForWord(wordRef)) {
      return message(Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline, size: 32),
          const SizedBox(height: 12),
          Text(
            l10n.peExamplesNeedPremium(word),
            key: const Key('pe_examples_premium'),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('pe_examples_upgrade'),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PaywallScreen())),
            child: Text(l10n.menuPremium),
          ),
        ],
      ));
    }
    if (sentences.isEmpty) {
      return message(Text(
        l10n.peNoExamples(word),
        key: const Key('pe_no_examples'),
        textAlign: TextAlign.center,
      ));
    }
    return SentenceDetailScreen(
      // 換字時（理論上不會）重新建立播放器。
      key: ValueKey(wordRef),
      sentences: sentences,
      initialIndex: 0,
    );
  }
}
