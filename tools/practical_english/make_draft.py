#!/usr/bin/env python3
"""把撰寫稿轉成句庫草稿 TSV（tools/practical_english/source/draft_NNN.tsv），並更新 sense_review.tsv。

撰寫稿：tools/practical_english/authoring/batch_NNN.txt，UTF-8，一行一句，`|` 分隔 9 欄：
  ngsl_index|form|sentence|zh-TW|level|category|secondaries|phrase_candidate|tagging_notes
  - 第 001–029 批：第 1 欄是 NGSL index，依序 100 個一批（最後一批 9 句）。
  - 第 030 批起（NGSL 以外的詞，以及詞義不同、要另外造句的同拼字詞）：第 1 欄改寫
    正式 ID（例 phrase_list_506_0004），TSV 的 ngsl_index 留空；句子 ID 接在前面批次之後。
  - secondaries：逗號分隔，寫詞表裡的原形；句中形式不同時寫「原形<句中形式」，例如 key<keys。
    ID 由本工具從 assets/data 查出（同拼字取清單順序第一個），不手打。
  - 空行與 # 開頭的行略過。

檢查：ngsl_index 依序、拼字與 NGSL 相符、主要詞與次要詞都以完整單字出現在句中、
次要詞存在於詞表且不重複、整個句庫沒有重複句。

sense_review.tsv：主要詞在其他清單有同拼字、翻譯不同的項目時產生一列；
既有列的 decision／status／note 保留不動，新列預設 include／proposed。

用法：python3 tools/practical_english/make_draft.py 002
      python3 tools/practical_english/make_draft.py --check 002   只檢查，不寫任何檔案
"""
import csv, glob, json, os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
DATA = os.path.join(ROOT, 'assets', 'data')
FILES = ['ngsl_2809', 'ngsl_spoken_720', 'phrase_list_506', 'phave_list_150']
HEADER = ['id', 'ngsl_index', 'word', 'form', 'sentence', 'zh-TW', 'level', 'category',
          'primary_word_id', 'secondary_word_ids', 'phrase_candidate', 'tagging_notes']
SENSE = os.path.join(HERE, 'sense_review.tsv')
SENSE_HEADER = ['sentence_id', 'primary_word_id', 'candidate_id', 'primary_zh', 'candidate_zh',
                'decision', 'status', 'note']
LEVELS = {'A1', 'A2', 'B1', 'B2', 'C1', 'C2'}
BATCH_SIZE = 100
NGSL_BATCHES = 29


def normalize(text):
    t = re.sub(r'\s+', ' ', text.strip()).replace('’', "'")
    return re.sub(r'[.!?]+$', '', t).lower()


def present(form, sentence):
    return re.search(r"(?<![A-Za-z])" + re.escape(form.lower()) + r"(?![A-Za-z])", sentence.lower())


def read_tsv(path, header):
    with open(path, encoding='utf-8') as f:
        rows = list(csv.reader(f, delimiter='\t', quoting=csv.QUOTE_NONE))
    if rows[0] != header:
        sys.exit(f'{path}: 表頭不符')
    return [dict(zip(header, r)) for r in rows[1:] if any(c.strip() for c in r)]


def main():
    args = sys.argv[1:]
    check_only = '--check' in args
    args = [a for a in args if a != '--check']
    if len(args) != 1 or not args[0].isdigit():
        sys.exit(__doc__)
    batch = int(args[0])
    src = os.path.join(HERE, 'authoring', f'batch_{batch:03d}.txt')
    out = os.path.join(HERE, 'source', f'draft_{batch:03d}.tsv')

    items, by_w = {}, {}
    for name in FILES:
        for it in json.load(open(os.path.join(DATA, name + '.json'), encoding='utf-8'))['items']:
            items[it['id']] = it
            by_w.setdefault(it['w'].strip().lower(), []).append(it['id'])
    ngsl = json.load(open(os.path.join(DATA, 'ngsl_2809.json'), encoding='utf-8'))['items']

    # 其他批次的句子，用來檢查重複
    seen = {}
    for path in glob.glob(os.path.join(HERE, 'source', '*_*.tsv')):
        if os.path.abspath(path) == os.path.abspath(out):
            continue
        for r in read_tsv(path, HEADER):
            seen[normalize(r['sentence'])] = f"{os.path.basename(path)}#{r['id']}"

    lines = [l.rstrip('\n') for l in open(src, encoding='utf-8')]
    lines = [l for l in lines if l.strip() and not l.startswith('#')]
    errors, rows = [], []
    extra = batch > NGSL_BATCHES
    first_idx = (batch - 1) * BATCH_SIZE
    # 其他批次已用掉的主要詞，避免同一個 ID 當兩次主要詞
    used = {}
    for path in glob.glob(os.path.join(HERE, 'source', 'draft_*.tsv')):
        if os.path.abspath(path) != os.path.abspath(out):
            for r in read_tsv(path, HEADER):
                used[r['primary_word_id']] = f"{os.path.basename(path)}#{r['id']}"
    if extra:
        first_id = len(ngsl) + 1
        for b in range(NGSL_BATCHES + 1, batch):
            prev = os.path.join(HERE, 'source', f'draft_{b:03d}.tsv')
            if not os.path.exists(prev):
                if check_only:
                    continue  # 只檢查時句子 ID 不重要
                sys.exit(f'缺少 {os.path.relpath(prev, ROOT)}，請依序產生')
            first_id += len(read_tsv(prev, HEADER))
    else:
        first_id = first_idx + 1
    for n, line in enumerate(lines):
        f = line.split('|')
        where = f'batch_{batch:03d}.txt 第 {n + 1} 句'
        if len(f) != 9:
            errors.append(f'{where}: 欄位數 {len(f)}，應為 9')
            continue
        idx, form, sent, zh, level, cat, secs, phrase, notes = (x.strip() for x in f)
        if extra:
            if idx not in items:
                errors.append(f'{where}: 第 1 欄應為正式 ID，「{idx}」不存在')
                continue
            pid, idx = idx, ''
            word = items[pid]['w']
        elif idx != str(first_idx + n):
            errors.append(f'{where}: ngsl_index 應為 {first_idx + n}，寫的是 {idx}')
            continue
        else:
            pid = ngsl[int(idx)]['id']
            word = ngsl[int(idx)]['w']
        if pid in used:
            errors.append(f'{where}: {pid} 已是 {used[pid]} 的主要詞')
        used[pid] = where
        if not present(form, sent):
            errors.append(f'{where}: 主要詞形式「{form}」不在句中')
        if level not in LEVELS or not cat or not zh or not sent:
            errors.append(f'{where}: level／category／翻譯／句子有誤')
        if any(c in sent for c in '‘’“”'):
            errors.append(f'{where}: 請用直引號')
        key = normalize(sent)
        if key in seen:
            errors.append(f'{where}: 與 {seen[key]} 重複')
        seen[key] = where
        sec_ids = []
        for spec in [s.strip() for s in secs.split(',') if s.strip()]:
            lemma, _, sform = spec.partition('<')
            ids = by_w.get(lemma.lower())
            if not ids:
                errors.append(f'{where}: 次要詞「{lemma}」不在詞表')
                continue
            if not present(sform or lemma, sent):
                errors.append(f'{where}: 次要詞形式「{sform or lemma}」不在句中')
            if lemma.lower() == word.strip().lower() or ids[0] in sec_ids:
                errors.append(f'{where}: 次要詞「{lemma}」與主要詞或其他次要詞重複')
            sec_ids.append(ids[0])
        rows.append([str(first_id + n), idx, word, form, sent, zh, level, cat, pid,
                     '|'.join(sec_ids), phrase, notes])
    expected = min(BATCH_SIZE, len(ngsl) - first_idx)
    if not extra and len(rows) != expected:
        errors.append(f'句數 {len(rows)}，應為 {expected}')
    if errors:
        sys.exit('\n'.join(errors) + f'\n{len(errors)} 個錯誤，未輸出')
    if check_only:
        print(f'檢查通過：{len(rows)} 句（未寫入）')
        return

    with open(out, 'w', encoding='utf-8', newline='') as fo:
        fo.write('\t'.join(HEADER) + '\n')
        for r in rows:
            fo.write('\t'.join(r) + '\n')

    old = {}
    if os.path.exists(SENSE):
        for r in read_tsv(SENSE, SENSE_HEADER):
            old[(r['sentence_id'], r['candidate_id'])] = r
    added = 0
    for r in rows:
        pid = r[8]
        for cand in by_w[r[2].strip().lower()]:
            if cand == pid or items[cand]['m'].get('zh-TW') == items[pid]['m'].get('zh-TW'):
                continue
            if (r[0], cand) not in old:
                own = cand in used
                old[(r[0], cand)] = dict(zip(SENSE_HEADER, [
                    r[0], pid, cand, items[pid]['m'].get('zh-TW', ''), items[cand]['m'].get('zh-TW', ''),
                    'exclude' if own else 'include', 'proposed',
                    '詞義不同，這個 ID 另有自己的例句' if own else '同一個字，兩份清單的翻譯用字不同；句中詞義兩邊都涵蓋']))
                added += 1
    with open(SENSE, 'w', encoding='utf-8', newline='') as fo:
        fo.write('\t'.join(SENSE_HEADER) + '\n')
        for r in sorted(old.values(), key=lambda r: (int(r['sentence_id']), r['candidate_id'])):
            fo.write('\t'.join(r[h] for h in SENSE_HEADER) + '\n')

    n_sec = sum(len(r[9].split('|')) if r[9] else 0 for r in rows)
    print(f'已寫入 {os.path.relpath(out, ROOT)}：{len(rows)} 句，次要詞 {n_sec} 個；sense_review 新增 {added} 列')


if __name__ == '__main__':
    main()
