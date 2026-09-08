#!/usr/bin/env bash
# flutter_tts 等套件可能需要比 Flutter 預設樣板更高的 compileSdk，
# 這裡強制指定成 36，確保跟套件需求對齊（Android SDK 版本本身向下相容）。
set -euo pipefail

for f in "android/app/build.gradle.kts" "android/app/build.gradle"; do
  if [ -f "$f" ]; then
    echo "修補 $f 的 compileSdk..."
    python3 - "$f" << 'PYEOF'
import re, sys
path = sys.argv[1]
with open(path, encoding="utf-8") as fh:
    content = fh.read()

# Kotlin DSL: compileSdk = flutter.compileSdkVersion  →  compileSdk = 36
# Groovy: compileSdkVersion flutter.compileSdkVersion  →  compileSdkVersion 36
content = re.sub(r'compileSdk\s*=\s*flutter\.compileSdkVersion', 'compileSdk = 36', content)
content = re.sub(r'compileSdkVersion\s+flutter\.compileSdkVersion', 'compileSdkVersion 36', content)

with open(path, "w", encoding="utf-8") as fh:
    fh.write(content)
PYEOF
  fi
done
