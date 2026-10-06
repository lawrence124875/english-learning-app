# 智慧聽覺巡航：聊天專案用精簡摘要

> 給 claude.ai「智慧聽覺巡航」專案的 Claude 看的背景資料（從 HANDOFF.md 擷取）。完整紀錄以 repo 的 `HANDOFF.md` 為準。
> repo 是公開的，這裡不寫任何密碼、金鑰、權杖。
> 最後同步：2026-10-06（0.3.1+19 修正大字溢出、鎖屏綠底封面）

## 1. 分工（Lawrence 決定）
- **聊天（本專案）**：討論、決策、Play Console／AdMob／RevenueCat／Firebase 後台操作與截圖判讀。**不碰程式**。
- **Claude Code 雲端工作階段**：所有程式、HANDOFF 與文件、CI 建置。一件事開一個工作階段。
- 聊天這邊需要改程式時，整理成**提示詞**，由 Lawrence 貼到 Code。提示詞開頭可用：「請先讀 english-learning-app 的 HANDOFF.md，照 §0 流程工作」。
- 建置產物（APK/AAB）只放私人 repo `lawrence124875/english-app-builds` 的 Releases（`android-release-run<N>`），**絕不放公開 Artifacts**。

## 2. App 基本資料
- 名稱：智慧聽覺巡航 - 英語背景朗讀（Flutter，目前只上 Android；iOS 只有自用版）。開發者名稱 **LC Lab**（Lawrence Chang）。
- 套件名稱 `tw.bcc.englishapp`（上架後永久不能改）。
- 核心功能：背景／鎖屏英語單字朗讀巡航、雙語朗讀、不熟悉單字庫（星號）、學習統計、每日提醒、匯入自訂 CSV（可學 14 種語言）、分享、App 內更新。
- 內建教材（CC BY / CC BY-SA 公開學術資料）：NGSL 2809、NGSL-Spoken 720、PHRASE List 506、PhaVE 150，共 4,185 項。
- 介面 11 語：繁中、簡中、日、韓、越、印尼、西、葡、泰、阿拉伯（RTL）、英（英文只當不支援語言的預設介面）。
- 商業模式：免費版每份教材開放前 1/3，看獎勵廣告 +20；Premium 解鎖全部並移除廣告（月繳 NT$149／年繳 NT$999，經 RevenueCat）。
- 目標族群：學過很多次英文卻學不好、年紀漸長、沒有英文環境的成人。行銷主軸「20/80 法則、核心單字涵蓋 92% 日常英文、背景朗讀不浪費時間、找回信心」。
- 配色：柔和鼠尾草綠／藍綠（主色 `#5B8A72`、輔助藍 `#6B8CAE`、暖橘點綴 `#E0A458`），依色彩心理學選擇，Lawrence 喜歡、要保留。

## 3. 目前版本狀態（2026-10-06）
| 版本 | 內容 | 狀態 |
|---|---|---|
| 0.1.12+15 | 分享給朋友、7 語關鍵字 App 名稱；與 11 語商店資訊（含新增 en-US）一起送審 | 審查中 |
| 0.1.13+16 | 鎖屏／通知朗讀卡片按鈕修正、快速連按同步修正、關閉 App 後卡片殘留修正 | 實機通過；**第十五版過審後上傳** Release `android-release-run214` 的 AAB＋`store_assets/release_notes_v16.md` |
| 0.3.1+19 | 修正大字長片語蓋到按鈕；鎖屏封面改無字綠底（小米加 App 圖示），移除大字封面開關 | **取代第十八版上傳**（第十八版不上傳），第十七版之後上傳；待紅米實機確認＋`release_notes_v19.md` |
| 0.3.0+18 | 介面改版：柔光卡片／深色模式、首頁版面 D、單字大小、鎖屏大字封面、每日提醒改良（開始朗讀／稍後提醒） | 建置成功（`android-release-run216`），待紅米實機確認；不上傳，由第十九版取代＋`release_notes_v18.md` |
| 0.1.14+17 | 歐洲廣告同意（Google UMP）＋選單「廣告隱私設定」；隱私權政策中英雙語 | 建置成功（`android-release-run215`），待實機確認；**第十六版之後上傳**＋`release_notes_v17.md` |
- **版號規則**：下一個新建置版本起 versionName 用 **0.3.x**（下一版 `0.3.0+18`），versionCode 每次 +1、上傳過的號碼不能重用。
- 封閉測試：TestersCommunity（15 位測試者），2026-09-24 起算，預計 **約 10/10 期滿**。

## 4. 後台設定現況
**Google Play**
- 訂閱 `premium_monthly`（NT$149）、`premium_yearly`（NT$999）；24 個主要市場手動定價（⚠️ 改價**不要**選「套用到所有國家」，會覆蓋手動價格）。
- 隱私權政策 `https://lawrence124875.github.io/english-learning-app/`（中英雙語）；資料刪除網址同頁 `#data-deletion`。
- 開發者網站 `https://lawrence124875.github.io/`（LC Lab 首頁，英文 App 與謙卦兩張卡片）。
- 正式發布前測試報告到第十五版都沒產生；若期滿仍無，問卷改寫「以 Crashlytics 監控＋每版實機測試」。

**AdMob**
- App 名稱「智慧聽覺巡航 English Words Audio Cruise」；GDPR 訊息「LC Lab GDPR」已發布（英、德、法、西、義，含不同意按鈕，EEA／英國／瑞士）。
- 廣告分級 **PG**；封鎖：賭博與投注、酒精、性愛相關、社交類賭場遊戲、聳色腥。
- app-ads.txt 在網域根目錄 `https://lawrence124875.github.io/app-ads.txt`（與謙卦共用，內容不可改）。
- 正式版上線前無法連結 Play 商店，所以目前沒有廣告收入。

**RevenueCat（2026-10-05 設定完成）**
- 服務帳戶 `revenuecat@learning-english-5ea8b.iam.gserviceaccount.com`（與謙卦共用），Play Console 帳戶權限已授予；JSON 金鑰只在 RevenueCat。
- Entitlement **`premium`**（程式檢查這個名稱）掛 4 個商品；舊的 `english_learning_app_pro` 暫留，確認購買可解鎖後再決定是否封存。
- Offering `default`：`$rc_monthly`、`$rc_annual`。
- 「驗證訂閱購買」原為 ❌（等 Google 權限同步，最長約 36 小時，之後按 Check again）。

**Firebase**
- 專案 `learning-english-5ea8b`，與謙卦（`com.lclab.qiangua`）共用：看 Crashlytics／Analytics 先篩選 App（本 App＝`tw.bcc.englishapp`）。Firestore 規則全專案共用一份（本 App 只用 `feedback` 集合），**不可刪除專案中的謙卦 App**。
- Storage（雲端教材更新）擱置：需 Blaze 付費方案。

## 5. 待辦（依時間）
1. 第十七版實機確認：免費版各種廣告正常；台灣不會跳同意表單、選單沒有「廣告隱私設定」屬正常；個人版（Premium）不跳表單、沒廣告。
2. RevenueCat 購買驗證變綠後，用 Play 授權測試帳號實機買月繳／年繳，確認解鎖與恢復購買。
3. 第十五版過審 → 確認商店各語言名稱 → 上傳第十六版 → 再上傳第十七版。
4. 測試期滿（約 10/10）→ 正式版存取權問卷（草稿 `store_assets/launch_prep.md` 第二節，補上【 】處）→ 申請正式版。
5. 正式版上線後：AdMob 連結 Play 商店並確認 app-ads.txt 驗證；LC Lab 首頁卡片換成 Play 連結；個人全解鎖版重建。
6. 上架後：小預算投 Google App 廣告（NT$1～3 萬、2～3 個市場）看 D1/D7 留存與付費；1～2 個月後依數據決定 ASO 改名、價格、土耳其文、iOS 是否付費上架（US$99/年）。

## 6. 0.3.0 介面（已定案並實作）
- 規格：repo `store_assets/ui_proposals_2026-10-06/spec_0.3.0.md`。主色鼠尾草綠 `#5B8A72`（白字按鈕 `#4F7C65`）；首頁版面 D（單字最大、按鈕小）；淺色「柔光卡片」、深色「夜讀深綠」，預設跟隨系統；單字大小小／中／大；鎖屏大字封面（可關）＋三鍵；每日提醒加顏色、大圖示、「開始朗讀」「稍後提醒」。
- 限制：**通知字型大小由手機系統決定，App 無法直接調整**；封面放大效果依手機而異。

## 7. 重要決策與原則
- 一個 App 依裝置語言自動切換，不分多個 App；套件名稱不改。
- 廣告頻率保守（主要收入是訂閱）：不加「切換教材」插頁廣告；開啟應用程式廣告每小時最多一次；插頁只在前景顯示。
- 不加入無授權的商業版權教材，以「匯入自訂教材」替代；不做 App 內捐款。
- 繁中／簡中桌面名稱維持「智慧聽覺巡航」，日／韓維持在地品牌，其他語言用關鍵字名稱；正式上架後再依「搜尋字詞」數據分析是否改名（改名會重新送審）。
- 商店資訊實驗不能測 App 名稱，只能測圖示、截圖、主題圖、說明。
- 測試機：紅米 Note 8（Android 11、MIUI）；以標準 Android 行為為準。
- iOS：正式上架 Android 後觀察 1～2 個月數據再決定是否付費上架；自用版用 Impactor＋主帳號每 7 天續簽。
