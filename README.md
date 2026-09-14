# 智慧聽覺巡航 - Flutter 版

英文學習四合一朗讀 App（NGSL 2809 / NGSL-Spoken 720 / PHRASE List 506 / PhaVE List 150）。
從原本的 Netlify 網頁版重寫為 Flutter，準備上架 Google Play（先做 Android，iOS 暫緩）。

## 目前進度

**第一階段（核心骨架）**
- [x] 專案結構（`presentation` / `domain` / `data` 三層）
- [x] 四份教材資料轉換為多語言就緒的 JSON（目前只填中文 `zh-TW`）
- [x] 核心播放邏輯：洗牌演算法、播放清單建構（四種範圍模式）
- [x] 星號標記（不熟悉單字庫）、進度／設定持久化（SharedPreferences）
- [x] 主畫面 UI（單頁 scroll、可收合設定面板、記住展開狀態、顯示設定摘要）
- [x] 系統內建 TTS 整合（`flutter_tts`）

**第二階段（背景播放 + 上架準備）**
- [x] 背景播放（`audio_service`），含鎖屏/通知列顯示目前單字＋中文意思與播放控制
- [x] 語音測試/預覽畫面（含高音質語音優先排序）
- [x] 版權/關於頁面（四份教材正式引用文字）
- [x] GitHub Actions 雲端編譯工作流程（自動產生 android/ 專案骨架 + 修補背景播放所需權限 + 建置 APK）
**第三階段（Firebase 整合）**
- [x] Firebase Crashlytics：全域錯誤攔截，測試者當機時自動回報，不用等對方主動反應
- [x] 套件名稱正式定為 `tw.bcc.englishapp`，已在 Firebase 專案登記對應
- [ ] Firebase Analytics：待設計好要追蹤哪些事件後再接
- [ ] 內容雲端化（Remote Config/Firestore）：讓修正翻譯錯字、加新語言不用重新上架
- [ ] 使用者回饋收集表單

**待辦（第四階段）**
- [x] RevenueCat 訂閱付費（`purchases_flutter`）SDK 整合：SubscriptionService 包裝 entitlement 判斷、購買、恢復購買
- [x] Google AdMob（`google_mobile_ads`）SDK 整合：AdsService 提供 Rewarded Ad 載入邏輯
- [x] 免費版額度／廣告版位細節定案並串進 UI：每份教材開放前 1/3，看獎勵廣告額外解鎖20個（本次使用階段有效），底部橫幅廣告常駐＋每輪播完插頁廣告，訂閱後全解鎖＋去廣告
- [x] 本地通知（`flutter_local_notifications`）：可自訂時間的每日複習提醒
- [x] 學習統計畫面：今日已學習、累計已學習、NGSL 2809 進度與官方涵蓋率參考數據

**待辦（第五階段）**
- [ ] Google Play 上架準備：封閉測試（12人/14天）
- [ ] Firebase Analytics：待設計好要追蹤哪些事件後再接
- [ ] 內容雲端化（Remote Config/Firestore）：讓修正翻譯錯字、加新語言不用重新上架
- [ ] 使用者回饋收集表單

**重要說明**：這個專案目前沒有 `android/` 資料夾（原生 Android 專案骨架），因為本機沒有安裝 Flutter SDK 無法產生。這個資料夾會在 GitHub Actions 雲端編譯時**自動產生**（見 `.github/workflows/build_android.yml`），不需要手動處理。

## 如何拿到第一個可安裝的 APK

**已驗證可成功建置**（2026-09-14，commit eb02f5b，含免費版額度/廣告邏輯 + 本地通知 + 學習統計）：已完成商業模式邏輯（1/3免費解鎖、獎勵廣告、插頁/橫幅廣告、訂閱全解鎖去廣告）、每日複習提醒通知、學習統計畫面，並通過雲端編譯。

隱私權政策頁面：https://fastidious-froyo-0caac6.netlify.app/

Firebase API 金鑰先前因新帳號被 Google 誤判停權，已申訴成功恢復正常。

1. 每次推送到 `main` 分支，GitHub 會自動觸發雲端編譯（Actions 分頁可以看到進度，通常 5-10 分鐘）。
2. 編譯完成後，進到該次 workflow run 的頁面，最下面「Artifacts」區塊會有 `english-learning-app-release-apk` 可以下載。
3. 下載後解壓縮，把裡面的 `.apk` 檔傳到你的 Android 手機安裝（需要先在手機設定裡允許「安裝不明來源應用程式」）。

如果編譯失敗，Actions 頁面會顯示詳細錯誤訊息，把錯誤內容貼給我，我會協助修正。

## 資料授權

- NGSL 2809 / NGSL-Spoken 720：CC BY-SA 4.0（Browne, Culligan & Phillips）
- PhaVE List 150：CC BY 4.0（Garnier & Schmitt）
- PHRASE List 506：授權狀態待確認（已規劃聯繫作者 Norbert Schmitt 確認商用授權）

## 開發方式

本專案透過雲端編譯（GitHub Actions / Codemagic）產生 APK/AAB，本機不需安裝 Flutter SDK。
