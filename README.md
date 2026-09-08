# 智慧聽覺巡航 - Flutter 版

英文學習四合一朗讀 App（NGSL 2809 / NGSL-Spoken 720 / PHRASE List 506 / PhaVE List 150）。
從原本的 Netlify 網頁版重寫為 Flutter，準備上架 Google Play（先做 Android，iOS 暫緩）。

## 目前進度（第一階段核心骨架）

- [x] 專案結構（`presentation` / `domain` / `data` 三層）
- [x] 四份教材資料轉換為多語言就緒的 JSON（目前只填中文 `zh-TW`）
- [x] 核心播放邏輯：洗牌演算法、播放清單建構（四種範圍模式）
- [x] 星號標記（不熟悉單字庫）、進度／設定持久化（SharedPreferences）
- [x] 主畫面 UI（單頁 scroll、可收合設定面板、記住展開狀態、顯示設定摘要）
- [x] 系統內建 TTS 整合（`flutter_tts`）

## 待辦（後續階段）

- [ ] 背景播放（`audio_service` + `just_audio`），含鎖屏顯示目前單字＋中文意思
- [ ] 語音測試/預覽畫面
- [ ] Firebase 整合：內容雲端化（Remote Config/Firestore）、回饋收集、Crashlytics、Analytics
- [ ] RevenueCat 訂閱付費（`purchases_flutter`）：免費版（廣告）＋ Premium 訂閱
- [ ] 廣告 SDK（Google AdMob）：Rewarded Ads 加速器設計
- [ ] 版權/關於頁面（四份教材正式引用文字）
- [ ] 本地通知（`flutter_local_notifications`，未來複習提醒用）
- [ ] GitHub Actions 雲端編譯設定（Android APK/AAB）
- [ ] Google Play 上架準備：隱私權政策頁、封閉測試（12人/14天）

## 資料授權

- NGSL 2809 / NGSL-Spoken 720：CC BY-SA 4.0（Browne, Culligan & Phillips）
- PhaVE List 150：CC BY 4.0（Garnier & Schmitt）
- PHRASE List 506：授權狀態待確認（已規劃聯繫作者 Norbert Schmitt 確認商用授權）

## 開發方式

本專案透過雲端編譯（GitHub Actions / Codemagic）產生 APK/AAB，本機不需安裝 Flutter SDK。
