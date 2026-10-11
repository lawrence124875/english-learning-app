#!/usr/bin/env python3
"""檢查句庫翻譯檔（tools/practical_english/translations/<語言>.tsv）。

格式：UTF-8，Tab 分隔，表頭 `id<TAB>text`；id 是 source/batch_*.tsv 的句子流水號。

檢查：句數與 id 完全對應（不缺、不多、不重複）、文字非空且沒有 Tab、
文字種類符合語言（簡中不得出現繁體字、日文要有假名或漢字、韓文要有諺文、
泰文要有泰文字母、阿拉伯文要有阿拉伯字母）、沒有原封不動的英文句、
長度與英文比例不離譜、結尾有標點。

用法：python3 tools/practical_english/check_translations.py <語言> [翻譯檔] [--ids <只檢查這些 id 的 TSV>]
  不指定翻譯檔時讀 translations/<語言>.tsv，id 以全部正式句子為準。
"""
import csv, glob, os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
LANGS = ['zh-CN', 'ja', 'ko', 'vi', 'id', 'es', 'pt-BR', 'th', 'ar']
# 常見「只出現在繁體」的字；簡中翻譯不應該出現。
TRAD_ONLY = set('們這個說來時會對沒還過學錢買賣東車開關門聽讀寫話語請問題電腦機場飛機醫院應該覺發現經濟歡雞'
                '麼與從後裡體點樣場長書國實現認識讓給種總點單樂難頭髮護邊見專業運動氣隊農歷歲氣圖館際網壞')
SCRIPT = {
    'ja': re.compile(r'[぀-ヿ一-鿿]'),
    'ko': re.compile(r'[가-힣]'),
    'th': re.compile(r'[฀-๿]'),
    'ar': re.compile(r'[؀-ۿ]'),
    'zh-CN': re.compile(r'[一-鿿]'),
}
LATIN = {'vi', 'id', 'es', 'pt-BR'}
END = re.compile(r'[.!?。！？…」』"\'”»)）؟!]$')


def read(path):
    with open(path, encoding='utf-8') as f:
        rows = list(csv.reader(f, delimiter='\t', quoting=csv.QUOTE_NONE))
    return rows[0], rows[1:]


def main():
    args = sys.argv[1:]
    ids_path = None
    if '--ids' in args:
        i = args.index('--ids')
        ids_path = args[i + 1]
        del args[i:i + 2]
    if not args or args[0] not in LANGS:
        sys.exit(__doc__)
    lang = args[0]
    path = args[1] if len(args) > 1 else os.path.join(HERE, 'translations', f'{lang}.tsv')

    english = {}
    for p in sorted(glob.glob(os.path.join(HERE, 'source', 'batch_*.tsv'))):
        for r in csv.DictReader(open(p, encoding='utf-8'), delimiter='\t', quoting=csv.QUOTE_NONE):
            english[r['id']] = r['sentence']
    if ids_path:
        expected = [r[0] for r in read(ids_path)[1] if r]
    else:
        expected = list(english)

    header, rows = read(path)
    errors, warnings = [], []
    if header != ['id', 'text']:
        errors.append(f'表頭應為 id<TAB>text，實際 {header}')
    seen = {}
    for n, r in enumerate(rows, 2):
        if not r or not ''.join(r).strip():
            continue
        if len(r) != 2:
            errors.append(f'第 {n} 行欄位數 {len(r)}')
            continue
        sid, text = r[0].strip(), r[1].strip()
        if sid in seen:
            errors.append(f'id {sid} 重複')
        seen[sid] = text
        if not text:
            errors.append(f'id {sid} 沒有翻譯')
            continue
        en = english.get(sid, '')
        if text.lower() == en.lower():
            errors.append(f'id {sid} 與英文原句相同（未翻譯）')
        if lang in SCRIPT and not SCRIPT[lang].search(text):
            errors.append(f'id {sid} 沒有 {lang} 文字：{text}')
        if lang == 'zh-CN':
            bad = sorted({c for c in text if c in TRAD_ONLY})
            if bad:
                errors.append(f'id {sid} 有繁體字 {"".join(bad)}：{text}')
        if lang == 'ja' and not re.search(r'[぀-ヿ]', text):
            warnings.append(f'id {sid} 日文沒有假名：{text}')
        if lang in LATIN and re.search(r'[一-鿿぀-ヿ]', text):
            errors.append(f'id {sid} 混入中日文字：{text}')
        if not END.search(text):
            warnings.append(f'id {sid} 結尾沒有標點：{text}')
        if en and lang in LATIN and not 0.5 <= len(text) / max(len(en), 1) <= 3.0:
            warnings.append(f'id {sid} 長度比例異常：{en} → {text}')
    missing = [i for i in expected if i not in seen]
    extra = [i for i in seen if i not in set(expected)]
    if missing:
        errors.append(f'缺少 {len(missing)} 句：{" ".join(missing[:20])}')
    if extra:
        errors.append(f'多出 {len(extra)} 句：{" ".join(extra[:20])}')
    for w in warnings[:40]:
        print('提醒 ' + w)
    if errors:
        print('\n'.join(errors[:80]))
        sys.exit(f'{lang}: {len(errors)} 個錯誤')
    print(f'{lang}: 檢查通過 {len(seen)} 句（提醒 {len(warnings)} 項）')


if __name__ == '__main__':
    main()
