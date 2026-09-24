import '../domain/models/word_item.dart';
import '../l10n/app_localizations.dart';

/// 內建教材的顯示名稱依介面語言翻譯；自訂教材顯示使用者取的名字。
String datasetName(WordDataset d, AppLocalizations l) {
  switch (d.id) {
    case 'ngsl_2809':
      return l.datasetNameNgsl;
    case 'ngsl_spoken_720':
      return l.datasetNameSpoken;
    case 'phrase_list_506':
      return l.datasetNamePhrase;
    case 'phave_list_150':
      return l.datasetNamePhave;
    default:
      return d.name;
  }
}

String datasetShortName(WordDataset d, AppLocalizations l) {
  switch (d.id) {
    case 'ngsl_2809':
      return l.datasetShortNgsl;
    case 'ngsl_spoken_720':
      return l.datasetShortSpoken;
    case 'phrase_list_506':
      return l.datasetShortPhrase;
    case 'phave_list_150':
      return l.datasetShortPhave;
    default:
      return d.shortName;
  }
}
