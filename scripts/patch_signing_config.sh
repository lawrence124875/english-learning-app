#!/usr/bin/env bash
# 設定正式的 Android 發布簽署金鑰（release signing key）。
# Google Play 不接受用預設的除錯金鑰（debug key）簽署的 AAB/APK，
# 一定要用一組真正的、獨立產生的金鑰。這個腳本從環境變數讀取
# base64 編碼過的 keystore 檔案內容，還原成實際檔案，並修改
# android/app/build.gradle.kts 讓 release 建置版本改用這組金鑰簽署。
set -euo pipefail

KEYSTORE_PATH="android/app/release-key.jks"

echo "$ANDROID_KEYSTORE_BASE64" | base64 -d > "$KEYSTORE_PATH"
echo "已還原 keystore 檔案到 $KEYSTORE_PATH"

cat > android/key.properties << EOF
storePassword=$ANDROID_KEYSTORE_PASSWORD
keyPassword=$ANDROID_KEY_PASSWORD
keyAlias=$ANDROID_KEY_ALIAS
storeFile=release-key.jks
EOF

GRADLE_KTS="android/app/build.gradle.kts"

python3 - "$GRADLE_KTS" << 'PYEOF'
import re, sys
path = sys.argv[1]
with open(path, encoding="utf-8") as f:
    content = f.read()

if "englishapp_release_signing" not in content:
    # Kotlin 腳本的 import 一定要放在檔案最上方（所有其他程式碼之前），
    # 不能像一般程式碼那樣直接用完整路徑 java.util.Properties()
    # 寫在檔案中間，否則會編譯失敗（Unresolved reference）。
    imports = "import java.util.Properties\nimport java.io.FileInputStream\n\n"
    content = imports + content

    # 在 android { ... } 區塊最前面插入讀取 key.properties 的邏輯，
    # 以及 signingConfigs.release 設定，並把 buildTypes.release 的
    # signingConfig 改指向它（原本預設指向 debug 金鑰）。
    inject = '''
// englishapp_release_signing
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
'''
    content = content.replace("android {", inject + "\nandroid {", 1)

    signing_block = '''
    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
            }
        }
    }
'''
    # 插入 signingConfigs 區塊，放在 buildTypes 前面。
    if "buildTypes {" in content:
        content = content.replace("buildTypes {", signing_block + "\n    buildTypes {", 1)

    # 把 release buildType 裡指向 debug 金鑰的設定，改成指向 release。
    new_content = re.sub(
        r'signingConfig\s*=\s*signingConfigs\.getByName\("debug"\)',
        'signingConfig = signingConfigs.getByName("release")',
        content,
    )
    if new_content == content:
        # 找不到現成的 debug 簽署參照可以替換，改成直接在
        # release{...} 區塊裡插入一行，確保一定會套用到正確金鑰。
        new_content = re.sub(
            r'(release\s*\{)',
            r'\1\n            signingConfig = signingConfigs.getByName("release")',
            content,
            count=1,
        )
    content = new_content

with open(path, "w", encoding="utf-8") as f:
    f.write(content)
PYEOF

echo "已設定 release 簽署金鑰"
