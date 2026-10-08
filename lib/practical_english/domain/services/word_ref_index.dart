import '../../../domain/models/word_item.dart';
import '../models/word_ref.dart';

/// 一個 WordRef 實際對應到的教材、單字與目前在教材中的位置。
/// [index] 只給 V1 相容層（★ 以 index 存）使用，V2 邏輯不得拿它當身分。
class WordLocation {
  final WordDataset dataset;
  final WordItem item;
  final int index;
  const WordLocation(this.dataset, this.item, this.index);
}

/// WordRef → 教材單字的記憶體索引（SPEC §4）。
/// 由目前載入的教材（內建＋自訂）建立，Practical English 生命週期內有效。
class WordRefIndex {
  final Map<String, WordLocation> _byRef;

  WordRefIndex._(this._byRef);

  factory WordRefIndex.build(Iterable<WordDataset> datasets) {
    final map = <String, WordLocation>{};
    for (final dataset in datasets) {
      for (var i = 0; i < dataset.items.length; i++) {
        final item = dataset.items[i];
        // 同一份教材內若有重複 ID（理論上不會），保留第一個。
        map.putIfAbsent(WordRef.of(dataset, item),
            () => WordLocation(dataset, item, i));
      }
    }
    return WordRefIndex._(map);
  }

  WordLocation? resolve(String ref) => _byRef[ref];

  bool contains(String ref) => _byRef.containsKey(ref);

  int get length => _byRef.length;

  Iterable<String> get refs => _byRef.keys;
}
