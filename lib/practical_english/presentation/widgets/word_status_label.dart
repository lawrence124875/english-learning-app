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

  /// 同拼字分組時，各清單的狀態不一樣（SPEC §9.6）。
  final bool differs;

  const WordStatusChip(
      {super.key,
      required this.word,
      required this.status,
      this.differs = false});

  /// 同拼字一組的顯示狀態：有任何不熟悉就顯示不熟悉，否則用第一筆。
  static (WordStatus, bool) combine(List<WordStatus> statuses) {
    final differs = statuses.toSet().length > 1;
    final shown =
        statuses.contains(WordStatus.weak) ? WordStatus.weak : statuses.first;
    return (shown, differs);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = switch (status) {
      WordStatus.weak => scheme.error,
      WordStatus.mastered => scheme.primary,
      _ => scheme.onSurfaceVariant,
    };
    final l10n = AppLocalizations.of(context)!;
    final label = '$word · ${wordStatusLabel(l10n, status)}'
        '${differs ? ' · ${l10n.peStatusDiffers}' : ''}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, color: color),
      ),
    );
  }
}
