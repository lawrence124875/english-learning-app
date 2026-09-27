#!/usr/bin/env python3
"""第 11 版起：把 tools/translations/batch_*.tsv 的泰文、阿拉伯文翻譯合併進四份教材。

batch 檔格式（UTF-8，Tab 分隔，無表頭）：英文原文<TAB>泰文<TAB>阿拉伯文
以英文原文（教材的 "w"）比對，同一個字出現在多份教材會一起寫入。
只改 "m" 裡的 th / ar，不動項目順序（星號與進度用索引記錄，不能重排）。
用法：python3 tools/translations/merge.py   （會印出各教材完成度）
"""
import csv, glob, json, os, sys
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DATA = os.path.join(ROOT, 'assets', 'data')
FILES = ['ngsl_2809', 'ngsl_spoken_720', 'phrase_list_506', 'phave_list_150']

tr = {}
for path in sorted(glob.glob(os.path.join(os.path.dirname(__file__), 'batch_*.tsv'))):
    with open(path, encoding='utf-8') as f:
        for n, row in enumerate(csv.reader(f, delimiter='\t', quoting=csv.QUOTE_NONE), 1):
            if not row or not row[0].strip():
                continue
            if len(row) != 3 or not row[1].strip() or not row[2].strip():
                sys.exit(f'{os.path.basename(path)} 第 {n} 行格式錯誤：{row}')
            tr[row[0].strip()] = (row[1].strip(), row[2].strip())

unknown = set(tr)
for name in FILES:
    p = os.path.join(DATA, name + '.json')
    d = json.load(open(p, encoding='utf-8'))
    done = 0
    for it in d['items']:
        t = tr.get(it['w'])
        if t:
            it['m']['th'], it['m']['ar'] = t
            unknown.discard(it['w'])
        if 'th' in it['m'] and 'ar' in it['m']:
            done += 1
    with open(p, 'w', encoding='utf-8') as f:
        json.dump(d, f, ensure_ascii=False, separators=(',', ':'))
    print(f'{name}: {done}/{len(d["items"])}')
if unknown:
    sys.exit(f'batch 裡有教材找不到的字：{sorted(unknown)[:20]}')
