#!/usr/bin/env bash
# Release 版本預設會啟用 R8 程式碼壓縮，但 Firebase 的元件探索機制
# 依賴反射（reflection）找到各個 Registrar 類別的無參數建構子，
# R8 若沒有正確的 keep 規則，會把這些建構子當成「用不到」而砍掉，
# 導致 Firebase.initializeApp() 在執行期丟出 NullPointerException。
set -euo pipefail

PROGUARD_FILE="android/app/proguard-rules.pro"

mkdir -p "$(dirname "$PROGUARD_FILE")"
touch "$PROGUARD_FILE"

if grep -q "com.google.firebase.components.ComponentRegistrar" "$PROGUARD_FILE" 2>/dev/null; then
  echo "Firebase ProGuard 規則已經加過，略過。"
  exit 0
fi

cat >> "$PROGUARD_FILE" << 'EOF'

# --- Firebase：避免 R8 誤刪元件探索機制需要的類別 ---
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep class com.google.firebase.** { *; }
-keep interface com.google.firebase.** { *; }
-keep class * implements com.google.firebase.components.ComponentRegistrar { <init>(); }
-dontwarn com.google.firebase.**

# --- RevenueCat / Google Play Billing ---
-keep class com.android.billingclient.api.** { *; }
-dontwarn com.android.billingclient.api.**
-keep class com.revenuecat.purchases.** { *; }
-dontwarn com.revenuecat.purchases.**

# --- Google Mobile Ads (AdMob) ---
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# --- WorkManager / Room：避免 R8 改掉資料庫實作類別名稱，
# 導致執行期反射查找失敗（"Failed to create an instance of
# androidx.work.impl.WorkDatabase.canonicalName"）---
-keep class * extends androidx.room.RoomDatabase { *; }
-keep @androidx.room.Database class * { *; }
-keep class androidx.work.impl.WorkDatabase { *; }
-keep class androidx.work.impl.WorkDatabase_Impl { *; }
-keep class androidx.work.impl.** { *; }
-keepclassmembers class * extends androidx.room.RoomDatabase { <init>(); }
-dontwarn androidx.room.**
-dontwarn androidx.work.**
EOF

echo "已加入 Firebase 的 ProGuard keep 規則到 $PROGUARD_FILE"

# 確認 release buildType 有指向這份 proguard 規則檔（Flutter 預設樣板通常已經有，
# 這裡做保險性修補，避免規則檔沒被實際套用）。
for f in "android/app/build.gradle.kts" "android/app/build.gradle"; do
  if [ -f "$f" ] && ! grep -q "proguard-rules.pro" "$f"; then
    python3 - "$f" << 'PYEOF'
import re, sys
path = sys.argv[1]
with open(path, encoding="utf-8") as fh:
    content = fh.read()

release_block_kts = re.compile(r'(release\s*\{)')
if "getDefaultProguardFile" not in content and re.search(release_block_kts, content):
    insertion = (
        '\n            isMinifyEnabled = true\n'
        '            proguardFiles(\n'
        '                getDefaultProguardFile("proguard-android-optimize.txt"),\n'
        '                "proguard-rules.pro"\n'
        '            )'
    )
    content = release_block_kts.sub(r'\1' + insertion, content, count=1)
    with open(path, "w", encoding="utf-8") as fh:
        fh.write(content)
    print(f"已在 {path} 補上 proguardFiles 設定")
PYEOF
  fi
done
