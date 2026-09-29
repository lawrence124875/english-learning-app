#!/usr/bin/env bash
# iOS 建置前修補（只在 macOS runner 執行）：Firebase 設定檔、Bundle ID、
# 最低 iOS 版本、Info.plist（背景朗讀、AdMob、語言、顯示名稱）。
# ios/ 目錄每次 CI 由 flutter create 重新產生，手動改不會保留。
set -euo pipefail

PLIST=ios/Runner/Info.plist
PB=/usr/libexec/PlistBuddy
BUNDLE_ID=tw.bcc.englishapp
MIN_IOS=15.0

# 1) Firebase 設定檔
if [ -n "${FIREBASE_GOOGLE_SERVICE_INFO_PLIST:-}" ]; then
  printf '%s\n' "$FIREBASE_GOOGLE_SERVICE_INFO_PLIST" > ios/Runner/GoogleService-Info.plist
  plutil -lint ios/Runner/GoogleService-Info.plist
  echo "已寫入 GoogleService-Info.plist"
else
  echo "::error::找不到 FIREBASE_GOOGLE_SERVICE_INFO_PLIST Secret"
  exit 1
fi

# 2) Xcode 專案：Bundle ID、最低版本、把 GoogleService-Info.plist 加進 Runner 資源
ruby -e "require 'xcodeproj'" 2>/dev/null || sudo gem install xcodeproj --no-document
ruby <<RUBY
require 'xcodeproj'
proj = Xcodeproj::Project.open('ios/Runner.xcodeproj')
proj.targets.each do |t|
  t.build_configurations.each do |c|
    c.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '${MIN_IOS}'
    if t.name == 'Runner'
      c.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = '${BUNDLE_ID}'
    elsif t.name == 'RunnerTests'
      c.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = '${BUNDLE_ID}.RunnerTests'
    end
  end
end
proj.build_configurations.each { |c| c.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '${MIN_IOS}' }
runner = proj.targets.find { |t| t.name == 'Runner' }
group = proj.main_group.find_subpath('Runner', false) || proj.main_group
unless group.files.any? { |f| f.path == 'GoogleService-Info.plist' }
  ref = group.new_reference('GoogleService-Info.plist')
  runner.add_resources([ref])
end
proj.save
puts 'Xcode 專案已修補'
RUBY

# 3) Info.plist
setp() { $PB -c "Delete :$1" "$PLIST" 2>/dev/null || true; $PB -c "Add :$1 $2 $3" "$PLIST"; }
setp CFBundleDisplayName string "智慧聽覺巡航"
# 背景朗讀
$PB -c "Delete :UIBackgroundModes" "$PLIST" 2>/dev/null || true
$PB -c "Add :UIBackgroundModes array" "$PLIST"
$PB -c "Add :UIBackgroundModes:0 string audio" "$PLIST"
# AdMob（沒有這個鍵 App 一啟動就閃退）。個人版不顯示廣告，用 Google 測試 App ID；
# 正式上架 iOS 時改用 AdMob 新建的 iOS App ID（Secret ADMOB_IOS_APP_ID）。
setp GADApplicationIdentifier string "${ADMOB_IOS_APP_ID:-ca-app-pub-3940256099942544~1458002511}"
# 支援語言（iOS 需要列出，Flutter 才拿得到正確的手機語言）
$PB -c "Delete :CFBundleLocalizations" "$PLIST" 2>/dev/null || true
$PB -c "Add :CFBundleLocalizations array" "$PLIST"
i=0
for l in zh-Hant zh-Hans en ja ko vi id es pt-BR th ar; do
  $PB -c "Add :CFBundleLocalizations:$i string $l" "$PLIST"; i=$((i+1))
done
setp ITSAppUsesNonExemptEncryption bool false
plutil -lint "$PLIST"

# 4) App 圖示：用 tools/icons/out/ios/icon_1024.png 依原本每張圖的尺寸覆蓋 Flutter 預設圖示
ICONSET=ios/Runner/Assets.xcassets/AppIcon.appiconset
if [ -f tools/icons/out/ios/icon_1024.png ] && [ -d "$ICONSET" ]; then
  for f in "$ICONSET"/*.png; do
    w=$(sips -g pixelWidth "$f" | awk '/pixelWidth/{print $2}')
    sips -s format png -z "$w" "$w" tools/icons/out/ios/icon_1024.png --out "$f" >/dev/null
  done
  echo "已替換 App 圖示"
fi

# 5) Podfile 最低版本（有 Podfile 時）
if [ -f ios/Podfile ]; then
  sed -i '' -E "s/^#? *platform :ios, '[0-9.]+'/platform :ios, '${MIN_IOS}'/" ios/Podfile
  grep -n "platform :ios" ios/Podfile || sed -i '' "1s/^/platform :ios, '${MIN_IOS}'\n/" ios/Podfile
fi

# 6) AppDelegate：通知在前景顯示＋開 App 時清除圖示角標（2026-09-29）
# - 沒設 UNUserNotificationCenter delegate 時，App 在前景的通知 iOS 一律不顯示
#   （通知診斷「立即測試」在 iPhone 沒反應就是這個原因）。
# - 通知帶 badge 1（notification_service.dart），App 變成使用中時歸零。
APPDELEGATE=ios/Runner/AppDelegate.swift
if [ -f "$APPDELEGATE" ] && ! grep -q "UNUserNotificationCenter" "$APPDELEGATE"; then
python3 <<'PYEOF'
import re
path = "ios/Runner/AppDelegate.swift"
s = open(path, encoding="utf-8").read()
if "import UserNotifications" not in s:
    s = s.replace("import UIKit", "import UIKit\nimport UserNotifications", 1)
inject = """    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    NotificationCenter.default.addObserver(
      forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main
    ) { _ in
      if #available(iOS 16.0, *) {
        UNUserNotificationCenter.current().setBadgeCount(0) { _ in }
      } else {
        UIApplication.shared.applicationIconBadgeNumber = 0
      }
    }
"""
m = re.search(r"didFinishLaunchingWithOptions[^{]*\{\n", s)
if not m:
    raise SystemExit("找不到 didFinishLaunchingWithOptions，請檢查 AppDelegate.swift")
s = s[:m.end()] + inject + s[m.end():]
open(path, "w", encoding="utf-8").write(s)
print("AppDelegate 已加入通知 delegate 與角標清除")
PYEOF
fi

echo "iOS 修補完成"
