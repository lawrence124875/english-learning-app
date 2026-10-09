import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../domain/models/sentence.dart';
import '../providers/practical_english_state.dart';

/// 句子翻譯（SPEC §6.4）：依翻譯自己的語言決定文字方向；目前翻譯語言
/// 沒有翻譯時顯示「此句尚無翻譯」；跟隨英文介面時不顯示。
class TranslationText extends StatelessWidget {
  final PracticalEnglishState state;
  final Sentence sentence;
  final TextStyle? style;
  final TextAlign textAlign;

  const TranslationText(
      {super.key,
      required this.state,
      required this.sentence,
      this.style,
      this.textAlign = TextAlign.start});

  @override
  Widget build(BuildContext context) {
    if (state.translationLocale == null) return const SizedBox.shrink();
    final translation = state.translationFor(sentence);
    if (translation == null) {
      return Text(
        AppLocalizations.of(context)!.peNoTranslation,
        textAlign: textAlign,
        key: ValueKey('pe_no_translation_${sentence.id}'),
        style: (style ?? const TextStyle()).copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic),
      );
    }
    final rtl = translation.isRtl;
    return SizedBox(
      width: double.infinity,
      child: Text(
        translation.text,
        key: ValueKey('pe_translation_${sentence.id}'),
        style: style,
        textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
        textAlign: textAlign,
      ),
    );
  }
}
