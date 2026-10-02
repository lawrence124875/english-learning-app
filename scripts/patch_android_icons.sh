#!/usr/bin/env bash
# 把 App 桌面圖示（tools/icons/out/android，由 generate_launcher_icons.py 產生）
# 複製進 flutter create 產生的 android 專案，取代 Flutter 預設圖示。
set -euo pipefail
RES=android/app/src/main/res
cp -R tools/icons/out/android/. "$RES/"
echo "已套用 App 圖示：" && ls "$RES"/mipmap-*/

# 資源壓縮保留清單（比照謙卦 0.1.0+15）：audio_service 用名稱字串查詢
# 鎖定畫面／通知列的暫停、播放、停止按鈕圖示，release 版 shrinkResources
# 會誤判沒用到而刪除，導致小米等手機的媒體卡片整排按鈕不顯示。
mkdir -p "$RES/raw"
cat > "$RES/raw/keep.xml" <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<!-- audio_service_*：鎖定畫面／通知列媒體按鈕圖示，只以名稱字串引用，須防止資源壓縮移除 -->
<resources xmlns:tools="http://schemas.android.com/tools"
    tools:keep="@drawable/audio_service_*" />
XML
echo "已加入 res/raw/keep.xml（保留 audio_service 按鈕圖示）"
