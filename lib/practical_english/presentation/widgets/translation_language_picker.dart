import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../providers/practical_english_state.dart';

/// 翻譯語言選單（SPEC §6.4）：「跟隨 App 語言」＋登錄表 10 種語言（以
/// 該語言自己的名稱顯示；只列內建句庫覆蓋率達標的語言），右側是有該語言
/// 翻譯的句子數。不收費。
Future<void> showTranslationLanguagePicker(
    BuildContext context, PracticalEnglishState state) {
  final l10n = AppLocalizations.of(context)!;
  final current = state.translationLocaleSetting;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      Widget option(String? code, String label, {int? count}) => ListTile(
            key: Key('pe_translation_option_${code ?? 'follow'}'),
            leading: Icon(current == code
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked),
            title: Text(label),
            trailing: count == null ? null : Text('$count'),
            onTap: () {
              Navigator.pop(sheetContext);
              state.setTranslationLocale(code);
            },
          );
      return SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text(l10n.peTranslationLanguage,
                  style: Theme.of(sheetContext).textTheme.titleMedium),
            ),
            option(null, l10n.peTranslationFollowApp),
            for (final lang in state.pickerLanguages)
              option(lang.code, lang.endonym,
                  count: state.translatedCount(lang.code)),
          ],
        ),
      );
    },
  );
}
