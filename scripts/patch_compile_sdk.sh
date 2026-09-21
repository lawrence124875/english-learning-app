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

# 新版 flutter create 的 build.gradle.kts 範本裡，keystore.properties
# 讀取邏輯用了 java.util.Properties()、java.io.FileInputStream() 這種
# 完整路徑寫法，但範本本身漏掉對應的 import 語句，導致 Kotlin 編譯器
# 找不到 java 這個頂層套件參照（"Unresolved reference 'util'/'io'"）。
# 這是 Flutter 範本本身的瑕疵，不是我們自己的程式碼問題，在這裡補上
# 缺少的 import 語句即可修正。
if path.endswith(".kts"):
    needs_util = "java.util.Properties" in content and "import java.util.Properties" not in content
    needs_io = "java.io.FileInputStream" in content and "import java.io.FileInputStream" not in content
    if needs_util or needs_io:
        imports_to_add = ""
        if needs_util:
            imports_to_add += "import java.util.Properties\n"
        if needs_io:
            imports_to_add += "import java.io.FileInputStream\n"
        # 插入在第一個 plugins { ... } 區塊之前（檔案最前面）。
        content = imports_to_add + content

# Kotlin DSL: compileSdk = flutter.compileSdkVersion  →  compileSdk = 36
# Groovy: compileSdkVersion flutter.compileSdkVersion  →  compileSdkVersion 36
content = re.sub(r'compileSdk\s*=\s*flutter\.compileSdkVersion', 'compileSdk = 36', content)
content = re.sub(r'compileSdkVersion\s+flutter\.compileSdkVersion', 'compileSdkVersion 36', content)

# 明確寫死最低支援版本為 Android 5.0（API 21），對應我們定案的支援範圍，
# 不再讓它跟著 Flutter SDK 版本的預設值漂移。
content = re.sub(r'minSdk\s*=\s*flutter\.minSdkVersion', 'minSdk = 21', content)
content = re.sub(r'minSdkVersion\s+flutter\.minSdkVersion', 'minSdkVersion 21', content)

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

# 多個套件（Firebase/AdMob/RevenueCat/flutter_local_notifications）各自帶入
# 不同版本的 androidx.work（WorkManager），版本衝突會導致 WorkDatabase 在
# App 啟動時初始化失敗而直接崩潰。強制統一成單一版本解決衝突。
if "resolutionStrategy" not in content:
    force_block = (
        '\nconfigurations.all {\n'
        '    resolutionStrategy {\n'
        '        force("androidx.work:work-runtime:2.9.1")\n'
        '        force("androidx.work:work-runtime-ktx:2.9.1")\n'
        '    }\n'
        '}\n'
    ) if is_kts else (
        "\nconfigurations.all {\n"
        "    resolutionStrategy {\n"
        "        force 'androidx.work:work-runtime:2.9.1'\n"
        "        force 'androidx.work:work-runtime-ktx:2.9.1'\n"
        "    }\n"
        "}\n"
    )
    content = content.rstrip() + "\n" + force_block

with open(path, "w", encoding="utf-8") as fh:
    fh.write(content)
PYEOF
  fi
done
