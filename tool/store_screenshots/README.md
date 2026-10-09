# Google Play 商店截圖（0.3.1 起）

截圖是**真正的 App 畫面**：用 Flutter widget 測試把首頁、深色首頁、播放設定、特色介紹、學習統計渲染成 1080×2160 PNG，再補上狀態列與手勢列。介面改版後重跑即可，不必手繪。

## 需要
- Flutter SDK（CI 同為 stable）。
- 字型（跟 Android 手機內建字型一致；Roboto 與 Material 圖示用 Flutter SDK 內附的）：
  Noto Sans TC/SC/JP/KR（noto-cjk `Sans/SubsetOTF/<TC|SC|JP|KR>/NotoSans<..>-{Regular,Medium,Bold}.otf`）、
  Noto Sans Thai/Arabic（notofonts.github.io `fonts/NotoSans<Thai|Arabic>/hinted/ttf/...-{Regular,Medium,Bold}.ttf`），放同一資料夾。
- 主題圖（feature graphic）仍用私人 repo english-app-builds 的 `store_assets/generate_localized_assets.py`（需 fonts-noto-cjk、fontTools、pythainlp、Pillow+raqm）。

## 執行（repo 根目錄）
```
flutter test tool/store_screenshots/store_screenshots_test.dart \
  --dart-define=FLUTTER_ROOT=<flutter 路徑> --dart-define=FONT_DIR=<字型資料夾> [--dart-define=LANGS=zh,ar]
python3 tool/store_screenshots/compose.py          # → store_assets/localized/<lang>/1_home…5_stats.png
python3 store_assets/generate_localized_assets.py  # （在 english-app-builds）→ store_assets/localized/<lang>/feature_graphic.png
```
畫面資料：bill（No.888）、journey、improve；今日 12／累計 1,248；免費版。介面語言用 `BackgroundL10n.debugLocale` 指定（同時決定翻譯語言）。
