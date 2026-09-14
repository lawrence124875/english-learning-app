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

# flutter_local_notifications 需要開啟核心函式庫去糖化（core library desugaring）。
is_kts = path.endswith(".kts")
if "CoreLibraryDesugaringEnabled" not in content and "coreLibraryDesugaringEnabled" not in content:
    if is_kts:
        content = re.sub(
            r'(compileOptions\s*\{)',
            r'\1\n        isCoreLibraryDesugaringEnabled = true',
            content,
            count=1,
        )
    else:
        content = re.sub(
            r'(compileOptions\s*\{)',
            r'\1\n        coreLibraryDesugaringEnabled true',
            content,
            count=1,
        )

if "coreLibraryDesugaring(" not in content and "coreLibraryDesugaring " not in content:
    if is_kts:
        desugar_dep = '\ndependencies {\n    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")\n}\n'
    else:
        desugar_dep = "\ndependencies {\n    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'\n}\n"
    content = content.rstrip() + "\n" + desugar_dep

with open(path, "w", encoding="utf-8") as fh:
    fh.write(content)
PYEOF
  fi
done
