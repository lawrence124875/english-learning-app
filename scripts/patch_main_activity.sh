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
