#!/usr/bin/env bash
# 把 google-services.json 放進 android/app/，並在 Gradle 設定裡加上
# Google Services 外掛，讓 Firebase 原生 SDK 能正確初始化。
set -euo pipefail

if [ -z "${FIREBASE_GOOGLE_SERVICES_JSON:-}" ]; then
  echo "找不到 FIREBASE_GOOGLE_SERVICES_JSON 環境變數，略過 Firebase 設定。"
  exit 0
fi

echo "$FIREBASE_GOOGLE_SERVICES_JSON" > android/app/google-services.json
echo "已寫入 android/app/google-services.json"

python3 << 'PYEOF'
import re

# 1. 在 settings.gradle.kts 的 plugins {} 區塊加上 google-services 外掛版本宣告
settings_path = "android/settings.gradle.kts"
with open(settings_path, encoding="utf-8") as f:
    content = f.read()

if "com.google.gms.google-services" not in content:
    content = re.sub(
        r'(plugins\s*\{)',
        r'\1\n    id("com.google.gms.google-services") version "4.4.2" apply false',
        content,
        count=1,
    )
    with open(settings_path, "w", encoding="utf-8") as f:
        f.write(content)
    print("已修補 settings.gradle.kts")

# 2. 在 app/build.gradle.kts 的 plugins {} 區塊套用 google-services 外掛
app_gradle_path = "android/app/build.gradle.kts"
with open(app_gradle_path, encoding="utf-8") as f:
    content = f.read()

if 'id("com.google.gms.google-services")' not in content:
    content = re.sub(
        r'(plugins\s*\{)',
        r'\1\n    id("com.google.gms.google-services")',
        content,
        count=1,
    )
    with open(app_gradle_path, "w", encoding="utf-8") as f:
        f.write(content)
    print("已修補 app/build.gradle.kts")
PYEOF
