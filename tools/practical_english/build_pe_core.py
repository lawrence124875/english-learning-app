#!/usr/bin/env python3
"""Practical English 內建句庫產生器（SPEC §4、§6、§13 的 content pipeline，App 外執行）。

來源：tools/practical_english/source/batch_*.tsv（UTF-8，Tab 分隔，有表頭）
  id          句子流水號（1, 2, 3…），輸出成 pe_core_000001；全部批次接續、不可跳號
  ngsl_index  目標字在 ngsl_2809 的 0-based index
  word        目標字（必須等於 ngsl_2809 該 index 的 "w"，用來防打錯 index）
  form        目標字在句子裡實際出現的樣子（例如 takes、Would），必須以完整單字出現
  sentence    英文句子（原創）
  zh-TW       繁中翻譯
  level       A1–C2
  category    daily、work、travel…

輸出：assets/practical_english/pe_core.json（每句一行，方便看 diff）

規則：
- 只能在尾端新增（append-only）：已發布的 pe_core ID 必須維持原本順序與 wordIds，
  句子文字或翻譯改動會列出警告（修錯字可以，換成別的句子不行）。
- wordIds 連到四份內建教材中所有同拼字的項目（SPEC §4），App 不在執行時猜。
- 同一句英文不能出現兩次（以 SPEC §6.2 的 normalize 比對）。

用法：python3 tools/practical_english/build_pe_core.py [--check]
  --check 只驗證、不寫檔（內容與現有 JSON 不同時回傳錯誤）。
"""
import csv, glob, json, os, re, sys
from collections import defaultdict

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DATA = os.path.join(ROOT, 'assets', 'data')
OUT = os.path.join(ROOT, 'assets', 'practical_english', 'pe_core.json')
SRC = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'source')
FILES = ['ngsl_2809', 'ngsl_spoken_720', 'phrase_list_506', 'phave_list_150']
HEADER = ['id', 'ngsl_index', 'word', 'form', 'sentence', 'zh-TW', 'level', 'category']
LEVELS = {'A1', 'A2', 'B1', 'B2', 'C1', 'C2'}
FREE_FRACTION = 1 / 3  # 與 AppState._freeUnlockFraction 相同，只用來印統計


def normalize(text):
    t = re.sub(r'\s+', ' ', text.strip())
    t = t.translate(str.maketrans({'‘': "'", '’': "'", '“': '"', '”': '"'}))
    return re.sub(r'[.!?。！？]+$', '', t).lower()


def main():
    check_only = '--check' in sys.argv[1:]
    errors = []

    datasets = {}
    by_surface = defaultdict(list)
    for name in FILES:
        items = json.load(open(os.path.join(DATA, name + '.json'), encoding='utf-8'))['items']
        datasets[name] = items
        for i, it in enumerate(items):
            by_surface[it['w'].strip().lower()].append((name, i, it['id']))
    ngsl = datasets['ngsl_2809']

    rows = []
    for path in sorted(glob.glob(os.path.join(SRC, 'batch_*.tsv'))):
        with open(path, encoding='utf-8') as f:
            reader = csv.reader(f, delimiter='\t', quoting=csv.QUOTE_NONE)
            header = next(reader, None)
            if header != HEADER:
                errors.append(f'{os.path.basename(path)}: 表頭應為 {HEADER}')
                continue
            for n, row in enumerate(reader, 2):
                if not row or not ''.join(row).strip():
                    continue
                where = f'{os.path.basename(path)}:{n}'
                if len(row) != len(HEADER) or any(not c.strip() for c in row):
                    errors.append(f'{where}: 欄位數或空白欄位錯誤')
                    continue
                rows.append((where, dict(zip(HEADER, (c.strip() for c in row)))))

    sentences, seen_text, seen_target = [], {}, {}
    for expected, (where, r) in enumerate(rows, 1):
        if r['id'] != str(expected):
            errors.append(f'{where}: id 應為 {expected}（必須接續、不跳號）')
        idx = int(r['ngsl_index']) if r['ngsl_index'].isdigit() else -1
        if not 0 <= idx < len(ngsl) or ngsl[idx]['w'] != r['word']:
            errors.append(f'{where}: ngsl_index {r["ngsl_index"]} 不是 "{r["word"]}"')
            continue
        if not re.search(r"(?<![A-Za-z'])" + re.escape(r['form']) + r"(?![A-Za-z])", r['sentence']):
            errors.append(f'{where}: 句子裡找不到完整單字 "{r["form"]}"')
        if r['form'].lower() != r['word'].lower() and r['word'].lower() not in r['form'].lower():
            print(f'提醒 {where}: form "{r["form"]}" 與 word "{r["word"]}" 拼法不同，請確認是同一字的變化')
        if r['level'] not in LEVELS:
            errors.append(f'{where}: level "{r["level"]}" 不合法')
        if any(c in r['sentence'] for c in '‘’“”'):
            errors.append(f'{where}: 請用直引號')
        key = normalize(r['sentence'])
        if key in seen_text:
            errors.append(f'{where}: 與 {seen_text[key]} 重複')
        seen_text[key] = where
        if idx in seen_target:
            print(f'提醒 {where}: ngsl_index {idx} 已在 {seen_target[idx]} 出現過')
        seen_target.setdefault(idx, where)
        refs = [ref for _, _, ref in by_surface[r['word'].lower()]]
        sentences.append({
            'id': f'pe_core_{expected:06d}',
            'wordIds': refs,
            'datasetId': 'pe_core',
            'targetLanguage': 'en-US',
            'sentenceText': r['sentence'],
            'translations': {'zh-TW': r['zh-TW']},
            'level': r['level'],
            'category': r['category'],
            'patternId': None,
            'scenarioId': None,
        })

    # append-only：已發布的句子不能被換掉、刪掉或重排。
    old = json.load(open(OUT, encoding='utf-8')).get('sentences', []) if os.path.exists(OUT) else []
    if len(sentences) < len(old):
        errors.append(f'句子數從 {len(old)} 變成 {len(sentences)}：不可刪除已發布的句子')
    for o, s in zip(old, sentences):
        if o['id'] != s['id'] or o['wordIds'] != s['wordIds']:
            errors.append(f'{o["id"]}: ID 或 wordIds 與已發布版本不同（只能在尾端新增）')
        elif o['sentenceText'] != s['sentenceText'] or o['translations'] != s['translations']:
            print(f'提醒 {o["id"]}: 文字有修改「{o["sentenceText"]}」→「{s["sentenceText"]}」')

    if errors:
        print('\n'.join(errors))
        sys.exit(f'{len(errors)} 個錯誤，未輸出')

    body = ',\n'.join(json.dumps(s, ensure_ascii=False, separators=(',', ':')) for s in sentences)
    text = '{"schema":1,"datasetId":"pe_core","sentences":[\n' + body + '\n]}\n'

    free_limit = {n: int(len(items) * FREE_FRACTION) for n, items in datasets.items()}
    locked = 0
    for s in sentences:
        # 規則 A（SPEC §12）：這裡每句只有一個目標詞彙，任一 WordRef 在免費範圍內就解鎖。
        if not any(int(ref.rsplit('_', 1)[1]) < free_limit[ref.rsplit('_', 1)[0]] for ref in s['wordIds']):
            locked += 1
    covered = len({int(r['ngsl_index']) for _, r in rows})
    print(f'句子 {len(sentences)}（新增 {len(sentences) - len(old)}），涵蓋 NGSL {covered} 字；'
          f'免費版未看廣告時鎖住 {locked} 句')

    if check_only:
        current = open(OUT, encoding='utf-8').read() if os.path.exists(OUT) else ''
        if current != text:
            sys.exit('pe_core.json 不是最新，請執行 build_pe_core.py')
        return
    with open(OUT, 'w', encoding='utf-8') as f:
        f.write(text)
    print(f'已寫入 {os.path.relpath(OUT, ROOT)}')


if __name__ == '__main__':
    main()
