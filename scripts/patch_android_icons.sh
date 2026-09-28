#!/usr/bin/env bash
# 把 App 桌面圖示（tools/icons/out/android，由 generate_launcher_icons.py 產生）
# 複製進 flutter create 產生的 android 專案，取代 Flutter 預設圖示。
set -euo pipefail
RES=android/app/src/main/res
cp -R tools/icons/out/android/. "$RES/"
echo "已套用 App 圖示：" && ls "$RES"/mipmap-*/
