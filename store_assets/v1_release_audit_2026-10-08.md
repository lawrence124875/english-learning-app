# V1 智慧聽覺巡航：正式上架盤點（Production Release Audit）

2026-10-08。範圍只有 V1；只盤點、不改程式。依據：repo main（4809eeb）的程式、CI、HANDOFF.md、隱私權政策 docs/index.html。Play Console／AdMob／RevenueCat／Firebase 後台我看不到，標「你確認」的要你在後台看。

## 結論

程式和建置沒有發現擋上架的問題，第十九版（0.3.1+19，run219）可以直接當正式版。真正要處理的是：送出申請問卷、你在後台確認 4 件事、核准後選好發布設定。

---

## 一、必須處理（上架前）

| # | 項目 | 誰 | 說明 |
|---|---|---|---|
| M1 | 送出正式版存取權問卷 | 你 | 答案在 launch_prep.md 第二節，英文直接貼 |
| M2 | 訂閱實機購買測試 | 你 | HANDOFF §17 A-4 還沒打勾。RevenueCat「驗證訂閱購買」要先變綠，再用授權測試帳號買月繳一次、確認解鎖與無廣告、再測「恢復購買」。**沒測過就上架，萬一有人付了錢卻沒解鎖，會直接變退款和負評**，這是最大風險 |
| M3 | Crashlytics 第十九版無未結當機 | 你 | 問卷第 8 題要寫這句；有當機就截圖給我 |
| M4 | 確認正式廣告 ID 有進建置 | 你 | 程式在 Secrets 沒設定時會退回 Google 測試廣告（ads_service.dart:104-122）。HANDOFF 記錄 5 個 AdMob Secrets 都已設定，裝 run219 APK 看橫幅或獎勵廣告，**不能出現「Test Ad」字樣**（沒廣告可接受，正式版前 AdMob 還沒連結） |
| M5 | Play Console「應用程式內容」與「政策狀態」沒有警告 | 你 | 隱私權政策網址、資料安全性、廣告聲明（含廣告＝是）、廣告 ID 聲明（用於廣告＋分析）、內容分級、目標對象、前景服務聲明（媒體播放，9/26 已交）都要是已完成。資料安全性要涵蓋：當機記錄與診斷（Crashlytics）、App 互動＋裝置 ID（Analytics、AdMob）、購買記錄（訂閱）、使用者提供的意見回饋文字（Firestore）。隱私權政策這幾項都有寫，表單要對得上 |
| M6 | 核准後的發布設定 | 你 | 建議：封閉測試軌道把第十九版「推廣」到正式版（不重新上傳）；國家選所有可用國家；直接 100%；版本資訊用 release_notes_v19.md（english-app-builds Release run219 可複製） |

## 二、上架當天／上架後馬上做

| # | 項目 | 誰 | 說明 |
|---|---|---|---|
| L1 | AdMob 連結 Play 商店 | 你 | 應用程式設定 → 應用程式商店詳細資料；確認 app-ads.txt 驗證通過（https://lawrence124875.github.io/app-ads.txt） |
| L2 | LC Lab 網站換成 Play 連結 | 我 | 上線後說一聲，我改 index.html 的「即將推出」 |
| L3 | 確認商店頁 11 語名稱、截圖正確，免費版廣告開始出現 | 你 | |
| L4 | 通知 TestersCommunity 測試者、保留封閉測試軌道 | 你 | 軌道保留供日後先測新版 |

## 三、可以上架後再處理

| # | 項目 | 說明 |
|---|---|---|
| P1 | CI 加 `flutter analyze`＋`flutter test` | 目前 build_android.yml 不跑測試（只有 test/fit_word_area_test.dart 一個測試）。加了可在建置前擋錯，不影響這次上架 |
| P2 | 忽略電池最佳化權限 | manifest 有 REQUEST_IGNORE_BATTERY_OPTIMIZATIONS（統計頁提醒的小米保險按鈕用）。Play 政策對這個權限要求嚴格，但封閉測試多次審查都通過；若日後被退件，改成只開系統電池設定頁、移除權限即可 |
| P3 | 隱藏「通知診斷」工具 | 統計頁長按才出現、僅中文、開發用；不影響使用者，可留可拿掉 |
| P4 | RevenueCat 舊 Entitlement `english_learning_app_pro` 封存 | M2 通過後再決定 |
| P5 | Crashlytics 舊問題關閉 | HANDOFF §17 B2 的 ① 若多日無新事件就關閉 |
| P6 | ASO 與商店資訊實驗 | 上架 1～2 個月後看「搜尋字詞」決定是否改名、測截圖與簡短說明 |
| P7 | 小預算廣告驗證、各國價格微調 | HANDOFF §17 D |
| P8 | 個人版重建 | 正式版穩定後（§17 E） |
| P9 | iOS 評估 | 上架 1～2 個月看 Android 數據再決定 |

## 四、V2 相關（只標記，不在這串處理）

- V2 規格 `docs/PRACTICAL_ENGLISH_SPEC.md`、`docs/PRACTICAL_ENGLISH_SPEC_V2_REVIEWED.md` 已在 main。`docs/` 不觸發 CI 建置，**不影響 V1 版本**；但 `docs/` 也是隱私權政策的 GitHub Pages 目錄，規格檔會一起公開在網站上（repo 本來就公開，不是新的外洩）。V2 開工時再決定要不要搬位置。
- 日後 V2 若沿用同一個 App（tw.bcc.englishapp）上架，版本代碼從 20 起跳；V2 開發要用工作分支，main 合併前不要動到 V1 正式版的建置。

## 五、已確認沒問題（不用處理）

- 版本 0.3.1+19 與 pubspec 一致；下一版 versionCode 20。
- 簽章金鑰在 GitHub Secrets，Lawrence 本機有備份。
- targetSdk：第十九版 2026-10-07 已被 Play 接受上傳，符合目前目標 API 要求。
- 隱私權政策中英雙語，已寫 AdMob、Analytics、Crashlytics、Firestore 回饋、RevenueCat、廣告 ID、兒童隱私（13 歲以下）、資料刪除錨點。
- 歐洲廣告同意（UMP）已在第十七版加入、第十九版包含。
- 前景服務（媒體播放）聲明已提交；通知接收器、鎖屏按鈕、卡片殘留都已在實機驗證。
- 24 個主要市場訂閱價格已手動設定。
- 封閉測試問卷第 4 題已改成「not designed for children under 13」，與隱私權政策一致。
