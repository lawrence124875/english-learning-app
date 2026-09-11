#!/usr/bin/env bash
# 在 `flutter create` 產生的 AndroidManifest.xml 裡，補上 audio_service
# 套件需要的權限與 service 宣告（背景播放、鎖屏通知控制）。
# 參考 audio_service 官方套件安裝說明所需的設定。
set -euo pipefail

MANIFEST="android/app/src/main/AndroidManifest.xml"

if [ ! -f "$MANIFEST" ]; then
  echo "找不到 $MANIFEST，略過修補（可能是尚未產生 android 專案）。"
  exit 0
fi

# 避免重複修補：如果已經有 FOREGROUND_SERVICE 權限，代表補過了。
if grep -q "FOREGROUND_SERVICE_MEDIA_PLAYBACK" "$MANIFEST"; then
  echo "AndroidManifest 已經修補過，略過。"
  exit 0
fi

python3 << 'PYEOF'
import re

path = "android/app/src/main/AndroidManifest.xml"
with open(path, encoding="utf-8") as f:
    content = f.read()

permissions = """
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.WAKE_LOCK"/>
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
"""

# 在 <manifest ...> 開頭標籤後插入權限宣告。
content = re.sub(
    r'(<manifest[^>]*>)',
    r'\1' + permissions,
    content,
    count=1,
)

import os
admob_app_id = os.environ.get("ADMOB_APP_ID", "")
if admob_app_id:
    admob_meta = (
        f'        <meta-data\n'
        f'            android:name="com.google.android.gms.ads.APPLICATION_ID"\n'
        f'            android:value="{admob_app_id}"/>\n'
    )
    content = content.replace("</application>", admob_meta + "    </application>")
    print("已加入 AdMob App ID meta-data")

service_block = """
        <service
            android:name="com.ryanheise.audioservice.AudioService"
            android:foregroundServiceType="mediaPlayback"
            android:exported="true">
            <intent-filter>
                <action android:name="android.media.browse.MediaBrowserService" />
            </intent-filter>
        </service>
        <receiver
            android:name="com.ryanheise.audioservice.MediaButtonReceiver"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MEDIA_BUTTON" />
            </intent-filter>
        </receiver>
"""

# 在 </application> 前插入 service/receiver 宣告。
content = content.replace("</application>", service_block + "    </application>")

with open(path, "w", encoding="utf-8") as f:
    f.write(content)

print("AndroidManifest.xml 修補完成")
PYEOF
