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
- [ ] Firebase 整合：內容雲端化（Remote Config/Firestore）、回饋收集、Crashlytics、Analytics — **需要你先建立 Firebase 專案，詳見 SETUP.md**
- [ ] RevenueCat 訂閱付費（`purchases_flutter`）：免費版（廣告）＋ Premium 訂閱 — **需要你先申請 RevenueCat/Google Play Console 帳號，詳見 SETUP.md**
- [ ] 廣告 SDK（Google AdMob）：Rewarded Ads 加速器設計 — **需要你先申請 AdMob 帳號，詳見 SETUP.md**
- [ ] 免費版額度／廣告版位細節定案
- [ ] 本地通知（`flutter_local_notifications`，未來複習提醒用，列入第三階段）
- [ ] Google Play 上架準備：隱私權政策頁、封閉測試（12人/14天）

**重要說明**：這個專案目前沒有 `android/` 資料夾（原生 Android 專案骨架），因為本機沒有安裝 Flutter SDK 無法產生。這個資料夾會在 GitHub Actions 雲端編譯時**自動產生**（見 `.github/workflows/build_android.yml`），不需要手動處理。

## 如何拿到第一個可安裝的 APK

1. 這次的程式碼推送後，GitHub 會自動觸發雲端編譯（Actions 分頁可以看到進度，通常 5-10 分鐘）。
2. 編譯完成後，進到該次 workflow run 的頁面，最下面「Artifacts」區塊會有 `english-learning-app-release-apk` 可以下載。
3. 下載後解壓縮，把裡面的 `.apk` 檔傳到你的 Android 手機安裝（需要先在手機設定裡允許「安裝不明來源應用程式」）。

如果編譯失敗，Actions 頁面會顯示詳細錯誤訊息，把錯誤內容貼給我，我會協助修正。

## 資料授權

- NGSL 2809 / NGSL-Spoken 720：CC BY-SA 4.0（Browne, Culligan & Phillips）
- PhaVE List 150：CC BY 4.0（Garnier & Schmitt）
- PHRASE List 506：授權狀態待確認（已規劃聯繫作者 Norbert Schmitt 確認商用授權）

## 開發方式

本專案透過雲端編譯（GitHub Actions / Codemagic）產生 APK/AAB，本機不需安裝 Flutter SDK。
