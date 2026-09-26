# 智慧聽覺巡航：開發交接文件（Claude 每次新對話先讀這份）

> 這份文件是給「下一個對話的 Claude」看的完整交接紀錄。
> **每次改版、做出新決策、踩到新坑之後，都要同步更新這份文件並 commit。**
> 注意：repo 是公開的，這裡不能寫任何密碼、金鑰、權杖明文。

最後更新：2026-09-26（第九版 0.1.6+9）

---

## 0. 新對話開始時的標準流程

1. 向 Lawrence 要 GitHub 權杖（fine-grained token，只授權這個 repo；權限 Contents 讀寫、Workflows 讀寫）。權杖**不存進記憶、不寫進任何檔案**，每次對話由他貼上。
   要權杖時主動附上網址：建立新權杖 https://github.com/settings/personal-access-tokens/new ；管理現有權杖 https://github.com/settings/personal-access-tokens 。未到期的舊權杖可沿用。
2. Clone repo：`git clone https://github.com/lawrence124875/english-learning-app.git`（公開 repo，clone 不需權杖）。
3. 先讀本文件，再依需求讀程式碼。
4. Commit 時用 `git -c user.name="Claude" -c user.email="noreply@anthropic.com" commit ...`（容器沒有 git 身分設定）。
5. Push：`git push "https://x-access-token:<TOKEN>@github.com/lawrence124875/english-learning-app.git" HEAD:main`，輸出要用 sed 把權杖遮掉。
6. Push 後 GitHub Actions 自動建置（約 12~20 分鐘）。用 API 查狀態：
   `curl -H "Authorization: Bearer <TOKEN>" https://api.github.com/repos/lawrence124875/english-learning-app/actions/runs?per_page=5`
   **容器內沒有 Flutter SDK（網路白名單擋掉 Google 儲存空間），無法本機編譯，一律靠 CI 驗證。** 改完程式一定要等建置成功才回報完成。
7. 容器網路白名單只有 GitHub、pypi、npm 等；**連不到 Firebase / Google API**。需要操作 Firebase 時，應該用 GitHub Secrets + Actions 代為執行（見第 9 節）。

---

## 1. 專案概況

- App 名稱：智慧聽覺巡航 - 英語背景朗讀（Flutter，僅 Android；iOS 尚未開發）
- 套件名稱 applicationId：**`tw.bcc.englishapp`**
  - 注意：CI 的 `flutter create --project-name english_learning_app --org tw.bcc` 會產生 `tw.bcc.english_learning_app`，但 `scripts/patch_firebase.sh` 會**強制改回 `tw.bcc.englishapp`**。2026-09-24 曾誤判套件名稱，已更正。
- 開發者：Lawrence（BCC 員工，個人專案）
- 核心功能：背景/鎖屏英語單字朗讀巡航、雙語朗讀（英文＋翻譯）、不熟悉單字庫（星號）、學習統計、每日提醒、匯入自訂 CSV 教材、訂閱解鎖、App 內更新
- 內建教材（皆為合法授權的公開學術資料，CC BY / CC BY-SA）：
  NGSL 2809、NGSL-Spoken 720、PHRASE List 506、PhaVE List 150，共 4,185 項
- 商業模式：免費版每份教材開放前 1/3，看獎勵廣告 +20；Premium 訂閱解鎖 100% 並移除廣告（月繳 NT$149 / 年繳 NT$999）。訂閱經 RevenueCat。
- 目標族群：學過很多次英文卻學不好、年紀漸長、生活沒有英文環境的成人。行銷主軸「20/80 法則、核心單字涵蓋 92% 日常英文、背景朗讀不浪費時間、找回信心」。

---

## 2. 程式架構與關鍵檔案

```
lib/
  main.dart                      App 進入點、MaterialApp、語言設定、edge-to-edge、audio_service 初始化
  data/repositories/
    remote_word_repository.dart  ★實際使用中的教材載入（main.dart 注入的是這個）
    word_repository.dart         介面＋舊的 LocalAssetWordRepository（目前沒被使用）
    custom_dataset_repository.dart 自訂匯入教材存取
    progress_repository.dart / stats_repository.dart  進度與統計（SharedPreferences）
  data/sources/
    background_l10n.dart   ★語言判斷的單一來源（介面、通知、鎖屏、教材翻譯全用它）
    tts_service.dart / tts_audio_handler.dart  朗讀與背景播放（audio_service）
    notification_service.dart  每日提醒、久未使用提醒（每次開 App 重新排程）
    subscription_service.dart  RevenueCat 訂閱（每次啟動向 RevenueCat 查權限，不在本機存 VIP 標記）
    update_service.dart        Google Play 應用程式內更新（in_app_update）
    csv_import_service.dart    CSV 匯入（錯誤用 CsvImportError enum 回報，畫面層翻譯）
    feedback_service.dart      意見回饋寫入 Firestore（含 locale 欄位）
    ads_service.dart           AdMob（插頁/開啟應用程式/獎勵/橫幅廣告＋全螢幕廣告頻率控制與生命週期監聽）
    analytics_service.dart     Firebase Analytics 事件（第 9 版新增）
  domain/models/word_item.dart  WordItem / WordDataset（translations map、resolveLocale、builtIn 旗標）
  presentation/
    providers/app_state.dart   核心狀態；meaningLocaleFor() 決定翻譯語言
    dataset_labels.dart        內建教材名稱多語言化
    screens/ widgets/
  l10n/app_*.arb               介面文字（8 種）
assets/data/                   四份教材 JSON + manifest.json
scripts/                       CI 用的 Android 修補腳本
store_assets/                  商店文案（STORE_LISTING.md、各語言 md）
docs/                          GitHub Pages：隱私權政策、app-ads.txt（公開網站！）
```

### 翻譯語言決定邏輯（重要）
- `BackgroundL10n.resolve()`：手機語言 → App 介面語言。中文會分繁簡：scriptCode=Hans 或地區 CN/SG/MY → 簡體；其餘繁體。不支援的語言 → 繁體中文。MaterialApp 的 `localeListResolutionCallback` 也呼叫它，確保一致。
- `BackgroundL10n.translationKey()`：介面語言 → 教材 JSON 翻譯 key（zh-TW / zh-CN / ja / ko / vi / id / es / pt-BR），同時也當 TTS 語言代碼。
- `AppState.meaningLocaleFor(word)`：內建教材（builtIn=true）用 translationKey；自訂教材用匯入時選的 primaryLocale；該語言沒有翻譯時 `resolveLocale` 退回 zh-TW（並用 zh-TW 語音念，避免「中文字配日文發音」）。
- 朗讀翻譯前會移除 `〜 ～ ~ …` 占位符號（部分 TTS 會念出來）。

---

## 3. 教材資料規則（改教材前必讀）

- 格式：`{"id","name","short","count","items":[{"id","w","m":{語言:翻譯}}]}`，JSON 以緊湊格式存（separators=(',',':')）。
- 8 種翻譯 key：`zh-TW`（原始）、`zh-CN`（由 zh-TW 用 OpenCC `tw2sp` 轉換，再把「单字→单词」、「」→“”）、`ja`、`ko`、`vi`、`id`、`es`、`pt-BR`。
- **星號與學習進度用「教材中的項目索引」記錄**：修改內建教材時**只能改內容或在最後面新增**，絕不能刪除、插入或重排，否則舊使用者的星號會對到錯的字。
- 翻譯原則（Lawrence 指定）：以最高頻、最常用的意思為主；Lawrence 無法請母語人士抽查。曾把約 30 個冷門中文釋義改為常用義（例：may 五月→可能；可以）。
- `assets/data/manifest.json` 的 `version` 是**內建內容版本**（目前 2）。`RemoteWordRepository` 只有在雲端快取版本 **大於** 內建版本時才使用雲端內容。改內建教材內容時要把這個 version +1。

---

## 4. 多語言（i18n）

- 支援 8 種：繁中 zh（預設/fallback）、簡中 zh_Hans、日 ja、韓 ko、越 vi、印尼 id、西 es、葡 pt（教材用 pt-BR）。
- 範本 ARB：`app_zh.arb`（placeholder 的 @meta 只寫在這個檔）。gen-l10n 設定在 `l10n.yaml`。
- 背景程式（沒有 BuildContext）用 `BackgroundL10n.current()` 取字串。

### 新增一種語言的檢查清單
1. 新增 `lib/l10n/app_xx.arb`（所有 key 都要有，placeholder 要一致）
2. `main.dart` supportedLocales 加上
3. `background_l10n.dart` 的 `_supported` 與 `translationKey()` 加上
4. `import_dataset_screen.dart` 預設翻譯語言對照表、語言選項；新增 `importLangXx` 字串到所有 ARB
5. `csv_import_service.dart` 表頭偵測字（該語言的「英文」）
6. 四份教材 4,185 項加上該語言翻譯（可重用：NGSL 與 Spoken 重疊 696 字）
7. 商店文案（App 名稱 ≤30、簡短說明 ≤80、完整說明 ≤4000 字元，用 Python len 檢查）
8. 版本號 +1、等 CI 成功

---

## 5. 建置與 CI

- `.github/workflows/build_android.yml`：push 到 main 自動觸發。流程：flutter create 產生 android 資料夾 → 一連串 `scripts/patch_*.sh`（manifest 背景播放權限、MainActivity 改 AudioServiceActivity、compileSdk、Firebase 設定與 applicationId、ProGuard、file_picker、簽署）→ 產出 APK 與 AAB 兩個 artifact。
- `build_personal.yml`：手動觸發，`FORCE_PREMIUM=true` 建置全解鎖無廣告的個人版 APK。
- 簽署金鑰存在 GitHub Secrets：`ANDROID_KEYSTORE_BASE64`、`ANDROID_KEYSTORE_PASSWORD`、`ANDROID_KEY_ALIAS`(=englishapp)、`ANDROID_KEY_PASSWORD`。Lawrence 本機也有備份。**金鑰遺失＝App 永遠無法更新。**
- AdMob 廣告單元 Secrets：`ADMOB_APP_ID`、`ADMOB_REWARDED_AD_UNIT_ID`、`ADMOB_INTERSTITIAL_AD_UNIT_ID`、`ADMOB_BANNER_AD_UNIT_ID`、`ADMOB_APP_OPEN_AD_UNIT_ID`（第 9 版新增；未設定時程式退回 Google 測試 ID）。
- minSdk 固定 21（Android 5.0+）。`purchases_flutter` 鎖在 `">=9.0.0 <10.8.0"`（9.0+ 符合 Billing Library 8；10.8+ 會把 minSdk 提到 23）。
- 版本號在 `pubspec.yaml`（`version: x.y.z+N`，N 是 Play 的版本代碼，每次上傳都要比之前任何上傳過的大；可以跳號，上傳過的號碼不能重用）。

---

## 6. 版本紀錄

| 版本代碼 | 版本名稱 | 內容 | Play 上傳 |
|---|---|---|---|
| 3 | 0.1.0 | 封閉測試首發版 | 已上傳 |
| 4 | 0.1.1 | 自訂教材匯入、日韓越介面、翻譯修正、訂閱頁條款與管理訂閱入口 | 已上傳並送審（2026-09-24） |
| 5 | 0.1.2 | 印尼文、教材四語翻譯、標題自動縮小、App 內更新 | 已上傳 |
| 6 | 0.1.3 | edge-to-edge 無邊框畫面 | **未上傳（跳過）** |
| 7 | 0.1.4 | 簡中、西、葡介面與教材翻譯 | **未上傳（跳過，有翻譯不跟隨語言的 bug）** |
| 8 | 0.1.5 | 修正內建教材翻譯未跟隨介面語言（RemoteWordRepository 補 builtIn；雲端快取需比內建新才使用） | 已上傳送審（2026-09-24，Actions #102） |
| 9 | 0.1.6 | 插頁廣告只在前景顯示（背景播完一輪改為待顯示）、開啟應用程式廣告（每小時上限、離開≥30秒、冷啟動不顯示）、全螢幕廣告間隔≥3分鐘、Firebase Analytics 事件、越南文/印尼文 App 內標題與商店一致 | **暫不上傳**：Lawrence 2026-09-26 決定累積近期小修正後，再以第 9 版（或屆時的版本號）一起上傳 |

注意：第 5 版之前的日韓越印尼教材翻譯其實也受第 8 版修正的 bug 影響（實際沒顯示），第 8 版起才真正生效。

---

## 7. Google Play / 上架狀態

- 封閉測試：TestersCommunity 付費服務（Starter，15 位測試者），測試群組 `testers-community@googlegroups.com`。2026-09-24 狀態 Active、15/15 到齊，16 天開始計算。控管型發布：已關閉（審核通過自動上線）。
- 測試期滿 → Play Console 申請正式版存取權（Google 問卷會問測試回饋與修正，版本更新紀錄可當素材）。
- 正式版前 AdMob 無法連結（平台限制），廣告不會顯示。
- 訂閱：`premium_monthly`（NT$149）、年繳（NT$999）。年繳設定：帳單週期每年、寬限期用 Google 建議值、帳戶保留自動計算、方案變更「下個結帳日收費」（建議）、重新訂閱允許。取消訂閱後自動於期末回到免費版，不需後台操作。RevenueCat Offering 的 Package 需設為 Monthly / Annual 類型，訂閱頁才會顯示「月繳/年繳方案」。
- 商店資訊：繁中 + 日韓越印尼 + 簡中/西/葡 皆已送審；**泰文已移除**（App 沒有泰文）。簡中（zh-CN）、西（es-419，可另加 es-ES）、葡（pt-BR）文案在 `store_assets/store_listing_zhcn_es_pt.md`，待上傳。簡短說明採「忠於中文原句（20/80、92%、找回信心）」的版本。
- AI 素材聲明：選「不為素材加上標籤」（截圖為實機畫面、圖示由 generate_assets.py 程式繪製）。
- 隱私權政策、app-ads.txt：GitHub Pages `https://lawrence124875.github.io/english-learning-app/`。

---

## 8. 重要決策紀錄（Lawrence 的決定）

- 一個 App 依裝置語言自動切換，不分多個 App。
- 市場順序：第一階段 繁中→日→韓→越→印尼（完成）；第二階段 簡中＋西＋葡（完成）；第三階段候選：泰、土耳其、阿拉伯（阿拉伯需右至左介面，成本最高）。另可評估 iOS 版（日本 iPhone 約 65%）。
- 不做 App 內捐款／贊助功能（2026-09-24 決定先不做；若做只能用 Play Billing 固定金額商品，不能放外部捐款連結）。
- 版本更新不必等 14 天測試結束（上傳新版不會重置測試天數；只有暫停軌道或測試者退出才會）。
- 拒絕加入無授權的商業版權內容（例：牛津片語清單），以「匯入自訂教材」替代。
- 測試機為小米/Redmi（MIUI），已加小米自啟動設定按鈕，但以標準 Android 行為為準。

---

## 9. Firebase

- 用途：Firestore（意見回饋，collection 由 FIRESTORE_RULES.md 規範）、Crashlytics、Storage（教材雲端更新，**擱置**：Storage 需 Blaze 付費方案，Lawrence 暫不升級）。
- Claude 無法從容器連 Firebase。若未來要透過 Firebase 更新教材：Lawrence 在 Firebase 產生服務帳戶金鑰 → 存進 GitHub Secrets（不可貼在對話）→ Claude 寫 Actions workflow 代為上傳；雲端 manifest version 必須大於內建版本（目前需 ≥3）。

---

## 10. 踩過的坑

- **App 實際用的是 RemoteWordRepository**，不是 word_repository.dart 裡的 LocalAssetWordRepository；改載入邏輯要改對檔案。
- 套件名稱以 `patch_firebase.sh` 為準（tw.bcc.englishapp）。
- Play Console 上傳當機後，版本代碼可能已被用掉 → 用「從檔案庫新增」選已上傳的 bundle。
- `DropdownButtonFormField` 使用 `initialValue`（新版 Flutter API）。
- 容器無法編譯 Flutter，所有改動靠 CI 驗證；建置失敗時用 Actions API 查 jobs/steps。
- `--dart-define=X=$SECRET` 在 Secret 不存在時傳入**空字串**，`String.fromEnvironment` 的 defaultValue 不會生效。新增的 dart-define 要在程式裡自己判斷空字串再退回預設（見 AdsService 的 App Open ID）。
- 全螢幕廣告本身會觸發 App 生命週期 paused/resumed，任何「回到前景」邏輯都要排除廣告造成的切換。
- Play Console 的 edge-to-edge 提醒在修正後可能仍顯示一段時間（Flutter 框架本身也會被偵測）。

---

## 11. 第 9 版（0.1.6+9）程式修改 —— 2026-09-26 已完成實作（紀錄保留供參考）

Lawrence 2026-09-24 決定以下全部在同一版完成。開新對話時他會說「開始做第九版」。

1. **插頁廣告改在前景顯示（AdMob 政策，必修）**
   現況：`app_state.dart` 在每輪播完時直接呼叫 `AdsService.showInterstitialAd()`，沒有檢查 App 是否在前景；使用者多半鎖屏/背景收聽，可能在背景跳廣告 → 無效流量，可能被停權。
   改法：一輪播完時若不在前景（`WidgetsBinding.instance.lifecycleState != resumed`），設一個「待顯示」旗標；App 回到前景（`didChangeAppLifecycleState` resumed）時再顯示。前景時才直接顯示。
2. **新增「開啟應用程式廣告」(App Open Ad)**：從背景切回 App 時顯示，頻率上限**每 1 小時最多一次**（Lawrence 2026-09-26 由 4 小時改為 1 小時）；且需離開 App 超過 30 秒才顯示（避免短暫切出去回訊息就跳廣告）；冷啟動第一次不顯示（避免一打開就廣告）；Premium 不顯示；與待顯示的插頁廣告不要同時出現。需在 AdMob 建立 App Open 廣告單元（Lawrence 操作），程式先用 Google 測試 ID。
3. **切換教材時的插頁廣告**：加頻率上限（例如距上次任何全螢幕廣告至少 3 分鐘）。
   原則：主要收入是訂閱，廣告頻率保守，避免低評價。AdMob 要正式上架後才能連結，目前沒有廣告收入。
4. **Firebase Analytics 事件**：加 `firebase_analytics`。建議事件：`play_start`、`round_complete`、`dataset_switch`（dataset_id）、`star_word`、`paywall_view`、`purchase_start`、`purchase_success`、`rewarded_ad_watch`、`import_csv`（筆數）、`ui_language`（使用者屬性）。目的：比較各國留存與付費轉換，決定第三階段語言。隱私權政策與 Play「資料安全性」表單要同步更新（Lawrence 操作）。
5. **越南文、印尼文 App 內標題改成與商店名稱一致**：`app_vi.arb` appTitle → `Nghe Tiếng Anh Thông Minh`；`app_id.arb` appTitle → `Belajar Inggris Sambil Dengar`。
6. 版本號改 `0.1.6+9`，等 CI 成功，更新本文件第 6 節版本紀錄。

### 第 9 版實作說明（給之後維護的人）
- 廣告邏輯全部集中在 `AdsService`：
  - `adsEnabled`：預設 false，`AppState.initialize()` 查完 RevenueCat 才設為 `!isPremium`；購買/恢復成功時設 false。
  - `onRoundComplete()`：前景 → 立即嘗試插頁；背景 → `_pendingInterstitial = true`，回前景時顯示。
  - `_AdLifecycleObserver`（WidgetsBindingObserver）：paused 記錄離開時間；resumed 時**最多顯示一則**：先處理待顯示插頁，否則判斷開啟應用程式廣告（離開≥30 秒、距上次 App Open ≥1 小時、距上次任何全螢幕廣告 ≥3 分鐘）。冷啟動沒有離開紀錄，不會顯示。
  - 全螢幕廣告（含獎勵廣告）顯示期間 `_fullScreenAdShowing = true`：廣告 Activity 蓋住 App 造成的 paused/resumed 不算使用者離開，否則看完 30 秒以上的獎勵影片回來會被誤判而跳 App Open。
  - `skipNextAppOpenAd()`：主動離開 App 的流程（Play 付款/恢復購買、管理訂閱網址、關於頁外部連結、選 CSV 檔、App 內更新、通知/電池/小米設定頁）呼叫，回來不跳 App Open。新增類似流程時記得加。
- **切換教材原本就沒有插頁廣告**（第 11 節第 3 項的前提有誤）。第 9 版只加了全域 3 分鐘間隔，沒有新增切換教材廣告版位；是否要加由 Lawrence 決定。
- Analytics：`AnalyticsService`，事件 `play_start`、`round_complete`（dataset_id, cycle）、`dataset_switch`、`star_word`（只記加星號）、`paywall_view`、`purchase_start`/`purchase_success`（package_id）、`rewarded_ad_watch`、`import_csv`（item_count）；使用者屬性 `ui_language`、`is_premium`。自訂教材 id 一律記成 `custom`，不記任何教材名稱或單字內容。

---

## 12. 待辦（非程式）

- [ ] 第 9 版先不上傳（Lawrence 2026-09-26 決定）：近期小修正都完成後再一起實機測試、上傳
- [ ] App 內「特色介紹」頁（Lawrence 2026-09-26 提出）：比照商店介紹，說明 20/80 法則與 92% 涵蓋率、解決的痛點、背景朗讀、雙語朗讀與不熟悉單字庫、可匯入自訂教材等特色；8 種語言，文案以各語言商店說明為基礎
- [x] AdMob「開啟應用程式」廣告單元（名稱「開啟時」）已建立，ID 已存 GitHub Secret `ADMOB_APP_OPEN_AD_UNIT_ID`（2026-09-26）。第九版請用設定 Secret 之後的建置產物（Actions #108 之後那次）
- [x] 隱私權政策（docs/index.html）已新增 Firebase Analytics 匿名使用統計說明（2026-09-26）
- [x] Play Console「資料安全性」已補上 Analytics（App 互動＋裝置 ID 用途加「分析」），刪除資料網址填 `https://lawrence124875.github.io/english-learning-app/#data-deletion`（2026-09-26）
- [x] Play Console「前景服務權限」聲明已提交：類型「媒體播放」，附示範影片（2026-09-26）。之後若新增其他前景服務類型或權限（例如忽略電池最佳化）需另行聲明
- [ ] 決定是否要加「切換教材」插頁廣告版位（目前沒有）

- [x] 第 8 版已上傳送審（2026-09-24）
- [x] 簡中、西、葡商店資訊已新增（2026-09-24）
- [x] 各國訂閱價格：Lawrence 決定（2026-09-26）只用台幣定價、由 Google 自動換算，不個別調降；日後改台幣價格時選「套用到所有國家」同步。等有各國付費數據再考慮個別調整（launch_prep.md 的建議表保留作參考）
- [ ] 正式版存取權問卷：草稿見 `store_assets/launch_prep.md`（測試期滿後填，需補上實際收到的測試回饋）
- [ ] 各語言商店截圖：目前先全部沿用繁中截圖（Lawrence 決定）；正式上架前後優先補日、西、葡。清單見 `store_assets/launch_prep.md`
- [ ] 收集 TestersCommunity 回報並修正
- [ ] 之後：第三階段語言、iOS 評估
