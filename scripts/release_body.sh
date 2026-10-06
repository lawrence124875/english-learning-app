#!/usr/bin/env bash
# 產生 english-app-builds Release 的說明文字（2026-10-06 Lawrence：版本資訊直接放 Release 下方，方便複製）。
# 用法：scripts/release_body.sh <第一行說明> <versionCode>
# 讀 store_assets/release_notes_v<versionCode>.md，把 <zh-TW>…</en-US> 整段放進程式碼區塊，
# 整段複製貼到 Play Console「版本資訊」即可（Play 會依語言標籤自動分配）。
set -euo pipefail
head_line="$1"
code="$2"
f="store_assets/release_notes_v${code}.md"
echo "$head_line"
if [ -f "$f" ]; then
  echo
  echo "## Play 版本資訊（整段複製貼到 Play Console）"
  echo
  echo '```'
  sed -n '/^</,$p' "$f"
  echo '```'
else
  echo
  echo "（找不到 ${f}，這版沒有版本資訊）"
fi
