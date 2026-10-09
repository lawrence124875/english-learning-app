#!/usr/bin/env python3
"""Practical English 內建句庫產生器（SPEC §4、§6、§13 的 content pipeline，App 外執行）。

來源：tools/practical_english/source/batch_*.tsv（UTF-8，Tab 分隔，有表頭）
  id          句子流水號（1, 2, 3…），輸出成 pe_core_000001；全部批次接續、不可跳號
  ngsl_index  目標字在 ngsl_2809 的 0-based index；主要詞不是 NGSL 時留空
  word        目標字（必須等於 ngsl_2809 該 index 的 "w"，或主要詞 ID 的 "w"，用來防打錯）
  form        目標字在句子裡實際出現的樣子（例如 takes、Would），必須以完整單字出現
  sentence    英文句子（原創）
  zh-TW       繁中翻譯
  level       A1–C2
  category    daily、work、travel…
  primary_word_id     主要詞 ID（每句恰好 1 個）：有 ngsl_index 時必須是該 NGSL 字；
                      留空時可為 4 份詞表的任一 ID（NGSL 以外的詞、詞義不同另造句的同拼字詞）
  secondary_word_ids  次要詞 ID，`|` 分隔，可空白；只能用 4 份正式詞表裡的 ID
  phrase_candidate    片語候選（只留在來源檔，不進 App），可空白
  tagging_notes       標記備註（只留在來源檔，不進 App），可空白

詞義審查：tools/practical_english/sense_review.tsv
  主要詞在其他清單有同拼字項目時，繁中翻譯相同的自動連結；翻譯不同的必須有一列
  decision=include／exclude 且 status=approved，才會寫進 wordIds（V2 架構確認版 §3.2）。

輸出：assets/practical_english/pe_core.json（每句一行，方便看 diff）
  wordIds           主要詞＋詞義確認過的同拼字 ID（免費規則 A 只看這個）
  secondaryWordIds  次要詞（不影響解鎖與覆蓋率；空的不輸出）

規則：
- 只能在尾端新增（append-only）：已發布的 pe_core ID 必須維持原本順序與 wordIds，
  句子文字或翻譯改動會列出警告（修錯字可以，換成別的句子不行）。
- wordIds 只放主要詞與詞義確認過的同拼字項目，App 不在執行時猜。
- 同一句英文不能出現兩次（以 SPEC §6.2 的 normalize 比對）。

用法：python3 tools/practical_english/build_pe_core.py [--check]
  --check 只驗證、不寫檔（內容與現有 JSON 不同時回傳錯誤）。
  python3 tools/practical_english/build_pe_core.py --draft <輸出.json> <來源.tsv> [來源.tsv …]
  草稿預覽：只讀指定檔案、寫到指定位置，絕不寫 pe_core.json；未審的詞義列為提醒。
"""
import csv, glob, json, os, re, sys
from collections import defaultdict

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DATA = os.path.join(ROOT, 'assets', 'data')
OUT = os.path.join(ROOT, 'assets', 'practical_english', 'pe_core.json')
SRC = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'source')
FILES = ['ngsl_2809', 'ngsl_spoken_720', 'phrase_list_506', 'phave_list_150']
HEADER = ['id', 'ngsl_index', 'word', 'form', 'sentence', 'zh-TW', 'level', 'category',
          'primary_word_id', 'secondary_word_ids', 'phrase_candidate', 'tagging_notes']
OPTIONAL = {'secondary_word_ids', 'phrase_candidate', 'tagging_notes'}
SENSE = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'sense_review.tsv')
SENSE_HEADER = ['sentence_id', 'primary_word_id', 'candidate_id', 'primary_zh', 'candidate_zh',
                'decision', 'status', 'note']
EMPTY = '{"schema":1,"datasetId":"pe_core","sentences":[]}\n'
LEVELS = {'A1', 'A2', 'B1', 'B2', 'C1', 'C2'}
FREE_FRACTION = 1 / 3  # 與 AppState._freeUnlockFraction 相同，只用來印統計


def normalize(text):
    t = re.sub(r'\s+', ' ', text.strip())
    t = t.translate(str.maketrans({'‘': "'", '’': "'", '“': '"', '”': '"'}))
    return re.sub(r'[.!?。！？]+$', '', t).lower()


def main():
    args = sys.argv[1:]
    check_only = '--check' in args
    draft = None
    if '--draft' in args:
        i = args.index('--draft')
        if len(args) < i + 3:
            sys.exit('用法：--draft <輸出.json> <來源.tsv> [來源.tsv …]')
        draft = ([os.path.abspath(a) for a in args[i + 2:]], os.path.abspath(args[i + 1]))
        if draft[1] == os.path.abspath(OUT):
            sys.exit('--draft 不能寫入 pe_core.json')
    errors, pending = [], []

    datasets = {}
    by_surface = defaultdict(list)
    for name in FILES:
        items = json.load(open(os.path.join(DATA, name + '.json'), encoding='utf-8'))['items']
        datasets[name] = items
        for i, it in enumerate(items):
            by_surface[it['w'].strip().lower()].append((name, i, it['id']))
    ngsl = datasets['ngsl_2809']
    items = {it['id']: it for its in datasets.values() for it in its}

    sense = {}
    if os.path.exists(SENSE):
        with open(SENSE, encoding='utf-8') as f:
            reader = csv.reader(f, delimiter='\t', quoting=csv.QUOTE_NONE)
            if next(reader, None) != SENSE_HEADER:
                errors.append(f'sense_review.tsv: 表頭應為 {SENSE_HEADER}')
            for n, row in enumerate(reader, 2):
                if not row or not ''.join(row).strip():
                    continue
                r = dict(zip(SENSE_HEADER, (c.strip() for c in row)))
                if r['decision'] not in ('include', 'exclude') or r['status'] not in ('proposed', 'approved'):
                    errors.append(f'sense_review.tsv:{n}: decision 須為 include/exclude，status 須為 proposed/approved')
                sense[(r['sentence_id'], r['candidate_id'])] = r

    rows = []
    sources = draft[0] if draft else sorted(glob.glob(os.path.join(SRC, 'batch_*.tsv')))
    for path in sources:
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
                if len(row) != len(HEADER) or any(not c.strip() for h, c in zip(HEADER, row) if h not in OPTIONAL):
                    errors.append(f'{where}: 欄位數或空白欄位錯誤')
                    continue
                rows.append((where, dict(zip(HEADER, (c.strip() for c in row)))))

    sentences, seen_text, seen_target = [], {}, {}
    for expected, (where, r) in enumerate(rows, 1):
        if r['id'] != str(expected):
            errors.append(f'{where}: id 應為 {expected}（必須接續、不跳號）')
        if r['ngsl_index']:
            idx = int(r['ngsl_index']) if r['ngsl_index'].isdigit() else -1
            if not 0 <= idx < len(ngsl) or ngsl[idx]['w'] != r['word']:
                errors.append(f'{where}: ngsl_index {r["ngsl_index"]} 不是 "{r["word"]}"')
                continue
            primary = ngsl[idx]['id']
        else:
            primary = r['primary_word_id']
            if primary not in items or items[primary]['w'] != r['word']:
                errors.append(f'{where}: primary_word_id {primary} 不是 "{r["word"]}"')
                continue
        if not re.search(r"(?<![A-Za-z'])" + re.escape(r['form']) + r"(?![A-Za-z])", r['sentence'], re.I):
            errors.append(f'{where}: 句子裡找不到完整單字 "{r["form"]}"')
        if r['ngsl_index'] and r['form'].lower() != r['word'].lower() and r['word'].lower() not in r['form'].lower():
            print(f'提醒 {where}: form "{r["form"]}" 與 word "{r["word"]}" 拼法不同，請確認是同一字的變化')
        if r['level'] not in LEVELS:
            errors.append(f'{where}: level "{r["level"]}" 不合法')
        if any(c in r['sentence'] for c in '‘’“”'):
            errors.append(f'{where}: 請用直引號')
        key = normalize(r['sentence'])
        if key in seen_text:
            errors.append(f'{where}: 與 {seen_text[key]} 重複')
        seen_text[key] = where
        if primary in seen_target:
            errors.append(f'{where}: 主要詞 {primary} 已在 {seen_target[primary]} 當過主要詞')
        seen_target.setdefault(primary, where)
        if r['primary_word_id'] != primary:
            errors.append(f'{where}: primary_word_id 應為 {primary}')
        refs = [primary]
        for _, _, cand in by_surface[r['word'].strip().lower()]:
            if cand == primary:
                continue
            if items[cand]['m'].get('zh-TW') == items[primary]['m'].get('zh-TW'):
                refs.append(cand)
                continue
            review = sense.get((r['id'], cand))
            if review is None or review['status'] != 'approved':
                pending.append(f'{where}: {primary}「{items[primary]["m"].get("zh-TW")}」與 {cand}'
                               f'「{items[cand]["m"].get("zh-TW")}」翻譯不同，' +
                               ('詞義審查尚未批准' if review else 'sense_review.tsv 沒有這一列'))
            elif review['decision'] == 'include':
                refs.append(cand)
        secondary = [x.strip() for x in r['secondary_word_ids'].split('|') if x.strip()]
        for ref in secondary:
            if ref not in items:
                errors.append(f'{where}: 次要詞 {ref} 不在正式詞表')
            elif ref in refs or items[ref]['w'].strip().lower() == r['word'].strip().lower():
                errors.append(f'{where}: 次要詞 {ref} 與主要詞重複')
        if len(set(secondary)) != len(secondary):
            errors.append(f'{where}: 次要詞 ID 重複')
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
            **({'secondaryWordIds': secondary} if secondary else {}),
        })

    if pending and not draft:
        errors.extend(pending)
    # append-only：已發布的句子不能被換掉、刪掉或重排。
    old = json.load(open(OUT, encoding='utf-8')).get('sentences', []) if os.path.exists(OUT) and not draft else []
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
    text = ('{"schema":1,"datasetId":"pe_core","sentences":[\n' + body + '\n]}\n') if sentences else EMPTY

    free_limit = {n: int(len(items) * FREE_FRACTION) for n, items in datasets.items()}
    locked = 0
    for s in sentences:
        # 規則 A（SPEC §12）：這裡每句只有一個目標詞彙，任一 WordRef 在免費範圍內就解鎖。
        if not any(int(ref.rsplit('_', 1)[1]) < free_limit[ref.rsplit('_', 1)[0]] for ref in s['wordIds']):
            locked += 1
    covered = {ref for s in sentences for ref in s['wordIds']}
    n_sec = sum(len(s.get('secondaryWordIds', [])) for s in sentences)
    print(f'句子 {len(sentences)}（新增 {len(sentences) - len(old)}），wordIds 涵蓋 {len(covered)}／{len(items)} 個詞；'
          f'次要詞 {n_sec} 個；免費版未看廣告時鎖住 {locked} 句')
    if draft:
        for p in pending:
            print('詞義待審 ' + p)
        print(f'詞義待審 {len(pending)} 項（正式建置時會擋下）')
        with open(draft[1], 'w', encoding='utf-8') as f:
            f.write(text)
        print(f'草稿預覽已寫入 {draft[1]}（沒有動 pe_core.json）')
        return

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
