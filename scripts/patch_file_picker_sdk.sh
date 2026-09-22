#!/usr/bin/env bash
# file_picker 套件本身的 android/build.gradle 沒有明確指定
# compileSdk（或指定的版本低於它的間接相依套件
# flutter_plugin_android_lifecycle 要求的 36），導致編譯失敗
# （"file_picker is currently compiled against android-34"）。
#
# 這個套件的原始碼放在 pub-cache（不是我們的 repo 裡），
# 所以直接找到它實際下載下來的資料夾，修改它自己的 build.gradle，
# 而不是像之前那樣嘗試「全域強制」所有套件（那個做法容易連帶
# 弄壞不相關的東西，這次改成只精準修改真正出問題的這一個套件）。
set -euo pipefail

PUB_CACHE="${PUB_CACHE:-$HOME/.pub-cache}"
FOUND=0

for dir in "$PUB_CACHE"/hosted/pub.dev/file_picker-*; do
  [ -d "$dir" ] || continue
  GRADLE_FILE="$dir/android/build.gradle"
  if [ -f "$GRADLE_FILE" ]; then
    FOUND=1
    echo "修補 $GRADLE_FILE 的 compileSdk..."
    python3 - "$GRADLE_FILE" << 'PYEOF'
import re, sys
path = sys.argv[1]
with open(path, encoding="utf-8") as f:
    content = f.read()

# Groovy 語法：compileSdkVersion 34 或 compileSdk 34 之類的寫法，
# 一律換成 36，跟我們主專案的 compileSdk 對齊。
new_content = re.sub(r'compileSdkVersion\s+\d+', 'compileSdkVersion 36', content)
new_content = re.sub(r'compileSdk\s+\d+', 'compileSdk 36', new_content)

if new_content != content:
    with open(path, "w", encoding="utf-8") as f:
        f.write(new_content)
    print("已更新 compileSdk 為 36")
else:
    print("找不到 compileSdk/compileSdkVersion 設定可以替換，略過")
PYEOF
  fi
done

if [ "$FOUND" -eq 0 ]; then
  echo "找不到 file_picker 套件的 pub-cache 資料夾，略過（可能套件已移除或路徑不同）"
fi
