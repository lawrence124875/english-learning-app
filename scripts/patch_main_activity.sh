#!/usr/bin/env bash
# audio_service 套件要求 MainActivity 繼承 AudioServiceActivity，
# 而不是 `flutter create` 預設產生的 FlutterActivity，
# 否則背景播放服務初始化時會直接丟例外，App 開起來就是白畫面閃退。
set -euo pipefail

MAIN_ACTIVITY=$(find android/app/src/main -name "MainActivity.kt" | head -n 1)

if [ -z "$MAIN_ACTIVITY" ]; then
  echo "找不到 MainActivity.kt，略過修補。"
  exit 0
fi

echo "修補 $MAIN_ACTIVITY..."

python3 << PYEOF
path = "$MAIN_ACTIVITY"
with open(path, encoding="utf-8") as f:
    content = f.read()

content = content.replace(
    "import io.flutter.embedding.android.FlutterActivity",
    "import com.ryanheise.audioservice.AudioServiceActivity",
)
content = content.replace(
    "class MainActivity: FlutterActivity()",
    "class MainActivity: AudioServiceActivity()",
)
content = content.replace(
    "class MainActivity : FlutterActivity()",
    "class MainActivity : AudioServiceActivity()",
)

with open(path, "w", encoding="utf-8") as f:
    f.write(content)

print("已將 MainActivity 改為繼承 AudioServiceActivity")
PYEOF

# ── MainActivity 啟動模式改為 singleTask（第十四版，2026-09-29）──
# 問題：點每日提醒通知回到 App，畫面停住不能操作。
# 原因：flutter create 範本的 MainActivity 是 launchMode="singleTop"（新版範本
# 還加了 taskAffinity=""）。通知的 PendingIntent（flutter_local_notifications
# 用啟動 Intent＋SELECT_NOTIFICATION）在 App 已在背景時，會再建立「第二個」
# MainActivity。AudioServiceActivity 讓所有 MainActivity 共用同一個快取的
# FlutterEngine，新的畫面接上引擎後，舊的那個被銷毀時把引擎一起拆離，
# 新畫面就只剩最後一格影像、無法操作。
# 修法：singleTask 保證只會有一個 MainActivity，通知/桌面圖示都回到同一個
# （走 onNewIntent），不會再重複建立。
MANIFEST="android/app/src/main/AndroidManifest.xml"
if [ -f "$MANIFEST" ]; then
python3 << 'PYEOF'
import re
path = "android/app/src/main/AndroidManifest.xml"
with open(path, encoding="utf-8") as f:
    content = f.read()
m = re.search(r'<activity\b[^>]*android:name="\.MainActivity"[^>]*>', content, re.S)
if not m:
    raise SystemExit("找不到 MainActivity 的 <activity> 標籤，請檢查 manifest")
tag = m.group(0)
if 'android:launchMode=' in tag:
    new_tag = re.sub(r'android:launchMode="[^"]*"', 'android:launchMode="singleTask"', tag)
else:
    new_tag = tag.replace('android:name=".MainActivity"',
                          'android:name=".MainActivity"\n            android:launchMode="singleTask"', 1)
content = content.replace(tag, new_tag, 1)
with open(path, "w", encoding="utf-8") as f:
    f.write(content)
print("MainActivity launchMode 已設為 singleTask")
PYEOF
fi
