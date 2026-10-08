# V1 智慧聽覺巡航：正式上架盤點（完整版）

2026-10-08。只盤點、不改程式、不動 V2。
以 [v1_release_audit.md](v1_release_audit_2026-10-08.md)（初版盤點）為底，這版補上：**拆解第十九版 run219 實際 APK 驗證**、資料安全性逐項對照、新發現 5 項。問卷不重寫，直接用 launch_prep.md 第二節。
Play Console／Firebase／RevenueCat／AdMob 後台我看不到，標「需你提供」的不代表沒問題。

---

## 1. 整體結論：READY WITH MINOR FIXES

- **程式與建置：沒有擋上架的問題，不需要改程式、不需要重建。** 第十九版 0.3.1+19（run219）可直接從封閉測試推廣到正式版。
- 「Minor fixes」全部在後台：資料安全性要補「電子郵件」、確認 Firestore 規則、訂閱實機購買測試、Crashlytics 確認，然後送出問卷。

### run219 APK 實測結果（我拆檔驗證，不是看設定推測）

| 項目 | 實際值 | 判斷 |
|---|---|---|
| Application ID | tw.bcc.englishapp | ✅ |
| versionCode／versionName | 19／0.3.1 | ✅ 與 pubspec 一致 |
| targetSdk | 36 | ✅ 符合 Play 目前要求 |
| minSdk | **24**（Android 7.0+） | ⚠️ HANDOFF 寫 21，實際被套件拉到 24；不影響上架，文件要更正 |
| 架構 | arm64-v8a、armeabi-v7a、x86_64 | ✅ |
| 16 KB 分頁 | 所有 arm64 .so 對齊 ≥16 KB | ✅ |
| debuggable | 無（release） | ✅ |
| AdMob 廣告單元 | 4 個正式 ID（pub-6291…，與 app-ads.txt 同一帳號），**沒有任何 Google 測試 ID** | ✅ 初版 M4 已由我驗證解決 |
| AdMob App ID | 正式 ID 已寫入 manifest | ✅ |
| RevenueCat 金鑰 | `goog_` 開頭＝Google Play 正式金鑰，**不是 Test Store 金鑰** | ✅ 測試與正式環境已分離 |
| 前景服務 | AudioService＝mediaPlayback | ✅ 與已提交的聲明一致 |
| 權限 | 見下方第 8 節 | ✅ 無需特別聲明的受限權限 |

---

## 2. Production Release Checklist

| 項目 | 狀態 | 必須處理？ | 建議 |
|---|---|---|---|
| App 基本資訊 | 名稱、套件名、開發者 LC Lab 已定 | 否 | 類別請確認是「教育」（需你提供） |
| Store Listing | 11 語名稱＋簡短／完整說明已上架封閉測試 | 否 | 上架後 1～2 月依搜尋字詞再調（C） |
| Screenshots | 11 語各 5 張（1080×2160）已有 | 否 | — |
| Feature Graphic | 11 語 1024×500 已有；圖示 512×512 | 否 | — |
| Privacy Policy | 中英雙語，涵蓋所有 SDK 與選填信箱 | 否 | — |
| Data Safety | **可能漏「電子郵件地址」** | **是（A2）** | 見第 3 節逐項表 |
| Content Rating | 封閉測試時已填（需你確認無警告） | 確認 | 第 4 節 |
| Target Audience | 問卷寫不為 13 歲以下設計 | 確認 | 第 5 節，需你決定一點 |
| Ads | 正式 ID 已進建置；UMP 已上；AdMob PG | 否 | 上架後連結 Play、看 app-ads.txt 驗證 |
| Subscription | 月繳／年繳商品、24 國價格已設 | **是（A3）** | 實機購買＋恢復購買從未測過 |
| RevenueCat | Entitlement `premium`、Offering default、正式金鑰 ✅ | 是（併 A3） | 「驗證訂閱購買」要先變綠 |
| Firebase | Crashlytics／Analytics／Firestore 回饋；與謙卦共用 | **是（A4）** | Firestore 規則要確認不是測試模式 |
| AAB | run219 AAB（69 MB）在 builds Release，已上傳 Play | 否 | 不重建，直接推廣 |
| Signing | 金鑰在 Secrets，你本機有備份；Play 已接受 | 否 | 確認 Play 應用程式簽署已啟用（應已是） |
| Version | 0.3.1+19；下一版 20 | 否 | — |
| Crash / ANR | 需你提供 | **是（A5）** | Crashlytics＋Play Android Vitals 截圖 |
| 14-day Testing | 2026-10-08 你已確認期滿 | 否 | — |
| Release Notes | release_notes_v19.md（11 語）在 run219 Release 頁 | 否 | 直接複製 |
| Google Play Release | 等問卷核准 | 是（A6、A7） | 推廣 v19、所有國家、100% |

---

## 3. 資料安全性（Data Safety）逐項對照（依程式實際行為）

| Play 類別 | 資料 | 來源 | 選填？ | 用途 | 分享給第三方？ |
|---|---|---|---|---|---|
| 個人資訊 → **電子郵件地址** | 意見回饋的聯絡信箱 | Firestore | 選填 | 開發者通訊 | 否 |
| App 活動 → App 互動 | 播放、切換教材、收藏等事件 | Firebase Analytics | 必要 | 數據分析 | 否（Google 為服務供應商） |
| App 活動 → 其他使用者產生的內容 | 意見回饋文字 | Firestore | 選填 | App 功能／開發者通訊 | 否 |
| App 資訊與效能 → 當機記錄、診斷 | 當機堆疊、裝置型號 | Crashlytics | 必要 | 數據分析 | 否 |
| 裝置或其他 ID | Firebase 安裝 ID、廣告 ID | Firebase、AdMob | 必要 | 數據分析、廣告 | AdMob 廣告用途依 Google 說明勾選 |
| 財務資訊 → 購買記錄 | 訂閱方案、交易編號 | RevenueCat／Play | 購買才有 | App 功能 | 否 |
| 位置 → 大概位置 | AdMob 以 IP 推估 | AdMob | — | 廣告 | 請對照 Google「AdMob 資料揭露」說明決定是否勾 |

其他欄：資料傳輸加密＝是；可要求刪除＝是（Email 方式，隱私權政策已寫）；無帳號系統。
**請把 Play Console 目前填的內容截圖給我，我逐項對。** 初版盤點 M5 沒列「電子郵件」，這是這次新發現。

## 4. 內容分級（IARC）建議答案
暴力／性／毒品／賭博／粗話：全部「否」。使用者互動：否（回饋只送給開發者，使用者之間看不到）。分享位置：否。數位商品購買：是（訂閱）。廣告：是。預期結果：全年齡／3+ 類。需你確認後台「已完成」且沒有警告。

## 5. 目標對象（需要你決定一件事）
問卷第 4 題和隱私權政策都寫「不為 13 歲以下設計」，AdMob 分級 PG。
**建議目標年齡選 18 歲以上（或 16+），不勾任何 13 歲以下年齡層。** 理由：勾了 13 歲以下就會進入家庭政策，AdMob 要改兒童設定、Analytics 也要限制，等於要改程式。學生用 App 不需要我們把他們設為目標對象。
請回覆後台目前勾的年齡層。

## 6. 廣告
- 正式 ID 已驗證、無測試 ID 殘留 ✅；UMP 同意（歐洲）✅；全螢幕廣告前景限定、間隔 ≥3 分鐘 ✅。
- 廣告聲明＝含廣告；廣告 ID 聲明＝是，用途勾「廣告或行銷」「數據分析」（APK 確實有 AD_ID 權限）。
- app-ads.txt：網域根目錄內容正確（pub-6291816733600445），但檔案**開頭有 3 個空白**。多數驗證器會忽略；上架後若 AdMob 顯示驗證失敗，這是第一個懷疑點。檔案與謙卦共用，**不動，除非你同意**。（我這邊連不到網站，無法確認線上版本，需你在 AdMob 看驗證狀態。）

## 7. 訂閱
- 程式：entitlement `premium`、購買／恢復購買／管理訂閱入口都有 ✅。
- RevenueCat：正式金鑰已在 APK ✅。Offering 同時掛 Test Store 和 Play 商品，正式金鑰只會拿到 Play 商品，**不需要拿掉 Test Store**。
- **從未實機購買過**（HANDOFF §17 A-4）。這是最大風險，見 A3。

## 8. Android Release 細項
權限：INTERNET、網路狀態、通知、前景服務（媒體播放）、喚醒鎖、開機接收、震動、**精準鬧鐘（SCHEDULE_EXACT_ALARM，程式在被拒時退回非精準，不需聲明）**、**忽略電池最佳化**（初版 P2，風險低）、Billing、廣告 ID、AdServices。沒有相機、麥克風、位置、聯絡人、儲存空間權限。
R8 壓縮已開（有 Firebase 與媒體按鈕的保留規則）。簽章不需更動。

---

## A. 必須在正式上架前完成

| # | 項目 | 誰 | 說明 |
|---|---|---|---|
| A1 | 送出正式版存取權問卷 | 你 | 用現有問卷，先處理問卷底部 4 項確認 |
| A2 | 資料安全性補「電子郵件地址（選填）」並逐項對照第 3 節 | 你 | **新發現**。表單與隱私權政策不一致會被退件 |
| A3 | 訂閱實機測試 | 你 | RevenueCat「驗證訂閱購買」變綠 → 授權測試帳號買月繳 → 確認解鎖、廣告消失 → 恢復購買。沒測就把問卷第 8 題 "and the subscription" 刪掉 |
| A4 | Firestore 安全規則確認 | 你 | **新發現**。Firebase 與謙卦共用；規則要是 FIRESTORE_RULES.md 的 create-only 版，不能是「測試模式」（30 天後失效會讓回饋送不出去，且任何人可讀）。截圖規則頁給我 |
| A5 | Crashlytics＋Android Vitals 第十九版無未結當機／ANR | 你 | 問卷第 8 題要用 |
| A6 | 應用程式內容、政策狀態全部無警告 | 你 | 目標對象（第 5 節）、內容分級、廣告、廣告 ID、前景服務 |
| A7 | 核准後推廣第十九版到正式版 | 你 | 所有國家、100%、版本資訊用 run219 Release 頁 |

## B. 建議上架前完成（不是 blocker）

| # | 項目 | 說明 |
|---|---|---|
| B1 | 商店類別確認為「教育」，聯絡 Email、網站 https://lawrence124875.github.io/ 已填 | 需你提供截圖 |
| B2 | 看一次 Play「正式發布前測試報告」 | 有就附在問卷第 8 題，沒有不影響 |
| B3 | HANDOFF 的 minSdk 21 更正為 24 | 文件修正，我做（已在本次更新） |

## C. 上架後再做

初版 P1～P9 全部沿用（CI 加測試、電池權限、通知診斷、舊 Entitlement、Crashlytics 舊問題、ASO、廣告預算、個人版、iOS），另加：
- C1 **CI 鎖定 Flutter 版本**：目前用 `channel: stable` 不鎖版，做第 20 版時工具鏈可能變動。下次要建置前先鎖。（V1 現在不需要處理）
- C2 Firebase Storage 教材更新已擱置，但程式每次啟動仍嘗試讀取，失敗會退回內建教材，不影響使用。可留給 V2 決定。
- C3 RevenueCat 記錄等級 info → warn；allowBackup 明確設定。都是小事，併入第 20 版。
- C4 app-ads.txt 開頭空白（見第 6 節），驗證失敗才處理。
- C5 **公開文件去識別化**（外部安全審查低風險項，2026-10-08）：已掃 main 無機密；Firebase 專案 ID、發布商 ID、套件名本來就公開。上架後把 HANDOFF §7 後台明細、§9、測試群組搬到私人 repo english-app-builds，公開 HANDOFF 只留架構與流程；V2 規格移出 docs/（V2 開工時）。repo 維持公開。✅ 2026-10-08 Lawrence 同意，上架後執行。

## V2 標記
- 只有 C1（Flutter 鎖版）和 C2（雲端教材）可能與 V2 有關：**可以留給 V2**。V1 現在都不需要處理。
- 規格檔放在 docs/（GitHub Pages）會公開在網站上，初版已標記，V2 開工再決定。

---

## Google Play 後台需要你手動完成
A1、A2、A3（含 RevenueCat）、A4（Firebase）、A5、A6、A7；上架後 AdMob 連結 Play 並看 app-ads.txt 驗證。

## Repository 需要修改的項目
上架前：**無**（只更新 HANDOFF 文件）。上架後：LC Lab 網站換 Play 連結；第 20 版時處理 C1、C3。

## 需要你提供的資料
1. 資料安全性目前內容截圖
2. Firestore「規則」頁截圖
3. Crashlytics 第十九版、Play Android Vitals（當機／ANR）截圖
4. 目標對象目前勾的年齡層
5. 訂閱測試結果（或決定先不測、刪問卷那句）
6. 商店設定的類別與聯絡資訊

## 正式上架前還剩幾步：6 步
1. 後台確認 A2、A4、A5、A6（可同一天做完）
2. 訂閱實機測試 A3
3. 送出問卷 A1
4. 等 Google 審核正式版存取權（Google 說通常 7 天內）
5. 推廣第十九版到正式版 A7，等正式版審核
6. 上線後：AdMob 連結＋app-ads.txt 驗證、我更新 LC Lab 網站連結
