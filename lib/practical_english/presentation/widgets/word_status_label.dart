import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../domain/services/sentence_selector.dart';

String wordStatusLabel(AppLocalizations l10n, WordStatus status) {
  switch (status) {
    case WordStatus.unseen:
      return l10n.peStatusUnseen;
    case WordStatus.seen:
      return l10n.peStatusSeen;
    case WordStatus.learning:
      return l10n.peStatusLearning;
    case WordStatus.weak:
      return l10n.peStatusWeak;
    case WordStatus.mastered:
      return l10n.peStatusMastered;
  }
}

/// 單字狀態小標籤（弱字用錯誤色、精熟用主色，其餘中性）。
class WordStatusChip extends StatelessWidget {
  final String word;
  final WordStatus status;

  const WordStatusChip({super.key, required this.word, required this.status});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = switch (status) {
      WordStatus.weak => scheme.error,
      WordStatus.mastered => scheme.primary,
      _ => scheme.onSurfaceVariant,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$word · ${wordStatusLabel(AppLocalizations.of(context)!, status)}',
        style: TextStyle(fontSize: 12, color: color),
      ),
    );
  }
}
