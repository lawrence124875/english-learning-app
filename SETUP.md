# 後續需要你申請的帳號與金鑰

有幾項服務需要用「你自己的帳號」去申請、產生金鑰，這件事我沒辦法代替你完成（需要你的身份/信用卡/登入驗證）。
申請好之後，把對應的設定檔或金鑰交給我，我就能把程式碼串接完成。

## 1. Firebase 專案

**用途**：單字資料雲端化（之後修正翻譯錯字/加新語言不用重新上架）、使用者回饋收集、當機報告、分析數據。

**申請步驟**：
1. 前往 https://console.firebase.google.com ，用你的 Google 帳號登入
2. 「新增專案」→ 專案名稱可取 `english-learning-app` → 照精靈完成建立
3. 專案建立後，左側選單「專案設定」→「一般」→ 拉到最下面「你的應用程式」→ 點 Android 圖示新增應用程式
4. 套件名稱要填：`tw.bcc.englishapp`（雲端建置時由 scripts/patch_firebase.sh 強制設定 applicationId，跟 Firebase 登記的一致）
5. 下載產生的 `google-services.json` 檔案，傳給我（或直接上傳到 GitHub repo 的 `android/app/` 資料夾底下，我再讀取整合）

## 2. Google Play 開發者帳號

**用途**：正式上架 App 到 Google Play。

**申請步驟**：
1. 前往 https://play.google.com/console/signup
2. 一次性費用 $25 美元，需要信用卡與身份驗證
3. 帳號審核通過後，先不用急著建立 App 資訊，等我們準備好第一個測試版 APK 再一起處理上架流程

## 3. RevenueCat（訂閱付費）

**用途**：處理訂閱邏輯、跨平台訂閱狀態管理，不用自己刻收據驗證這些複雜邏輯。

**申請步驟**：
1. 前往 https://app.revenuecat.com/signup 免費註冊
2. 建立一個新專案，選擇 Android 平台
3. 這一步需要先有 Google Play 開發者帳號、並在 Play Console 建立好 App 的商品資訊（訂閱方案），會等我們App骨架更完整、準備好上架時再一起處理，不用現在急著做

## 4. Google AdMob（廣告）

**用途**：免費版的 Rewarded Ads（廣告加速器機制）。

**申請步驟**：
1. 前往 https://admob.google.com ，用 Google 帳號登入
2. 建立新 App（可以先選「尚未在應用程式商店上架」）
3. 建立一個 Rewarded Ad 廣告單元，複製「廣告單元 ID」給我

---

## 建議順序

現在不用一次把四個都申請完。建議順序：

1. **先申請 Firebase**（最基礎，內容雲端化用得到）
2. 等 App 核心功能測試得差不多，商業模式（免費額度/廣告版位）也定案了，再申請 **AdMob** 和 **RevenueCat**
3. **Google Play 開發者帳號**可以現在就先申請，因為審核本身需要等待時間，可以跟開發同步進行

有任何一步卡住看不懂畫面，直接截圖給我，我可以幫你確認在哪裡點。
