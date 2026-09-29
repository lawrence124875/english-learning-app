# 智慧聽覺巡航：開發交接文件（Claude 每次新對話先讀這份）

> 這份文件是給「下一個對話的 Claude」看的完整交接紀錄。
> **每次改版、做出新決策、踩到新坑之後，都要同步更新這份文件並 commit。**
> 注意：repo 是公開的，這裡不能寫任何密碼、金鑰、權杖明文。

最後更新：2026-09-29（第十二版 0.1.9+12 程式與版本資訊完成，待實機確認後上傳；**Android 後續事項總整理見 §17，新對話從 §17 開始**）

---

## 0. 新對話開始時的標準流程

1. 向 Lawrence 要 GitHub 權杖（fine-grained token，只授權這個 repo；權限 Contents 讀寫、Workflows 讀寫、Actions 讀取以上）。權杖**不存進記憶、不寫進任何檔案**，每次對話由他貼上。
   要權杖時主動附上網址：建立新權杖 https://github.com/settings/personal-access-tokens/new ；管理現有權杖 https://github.com/settings/personal-access-tokens 。未到期的舊權杖可沿用。
2. Clone repo：`git clone https://github.com/lawrence124875/english-learning-app.git`（公開 repo，clone 不需權杖）。
3. 先讀本文件，再依需求讀程式碼。
4. Commit 時用 `git -c user.name="Claude" -c user.email="noreply@anthropic.com" commit ...`（容器沒有 git 身分設定）。
5. Push：`git push "https://x-access-token:<TOKEN>@github.com/lawrence124875/english-learning-app.git" HEAD:main`，輸出要用 sed 把權杖遮掉。
6. Push 後 GitHub Actions 自動建置（約 12~20 分鐘）。用 API 查狀態：
   `curl -H "Authorization: Bearer <TOKEN>" https://api.github.com/repos/lawrence124875/english-learning-app/actions/runs?per_page=5`
   **容器內沒有 Flutter SDK（網路白名單擋掉 Google 儲存空間），無法本機編譯，一律靠 CI 驗證。** 改完程式一定要等建置成功才回報完成。
6b. **讀建置錯誤**：容器連不到日誌下載網址（Azure blob），`build_android.yml` 建置失敗時會把錯誤行輸出成 `::error::` annotation，用 `GET /repos/.../check-runs/<job_id>/annotations` 讀取（權杖需加 Actions 讀取權限）。
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

- 第 11 版起另支援泰文 th、阿拉伯文 ar（阿拉伯文為 RTL 介面，見 §13）。
- 支援 8 種主要語言：繁中 zh、簡中 zh_Hans、日 ja、韓 ko、越 vi、印尼 id、西 es、葡 pt（教材用 pt-BR）；另有英文 en 介面（`app_en.arb`，第 10 版新增），**只當英文手機與不支援語言（泰/土/德/法…）的預設介面**，不是新市場。第 10 版前 fallback 是繁中。
- 英文介面下內建教材沒有翻譯：`AppState._hideBuiltInTranslation` 讓內建教材不顯示、不朗讀翻譯（不能退回中文）。自訂教材仍照匯入時選的翻譯語言。
- 自訂教材「第一欄語言」（第 10 版）：`WordDataset.wordLocale`（TTS 代碼，預設 `en-US`，舊教材無此欄位視為英文），匯入畫面用 endonym 下拉選單（英、繁中、簡中、日、韓、越、印尼、西、葡、法、德、義、泰），`_speakCurrent` 用它朗讀第一欄。使用者選的英文語音（pinnedVoice）只套用在 en 開頭的語言。
- CSV 表頭偵測（第 10 版）：`CsvImportService._headerWords`，第一欄**或第二欄**是欄位名稱或語言名稱（english/japanese/日本語/español…）就跳過第一列（例：英文介面學日文寫「japanese,english」）。Dart const set 不能有重複項目，新增時注意。
- 英文介面學任何語言（第 10 版，Lawrence 要求不限日文）：第一欄與翻譯欄都可選 13 種語言（`_wordLocaleOptions` 值為 TTS 代碼如 fr-FR；`_translationLocaleOptions` 值為翻譯 key 如 fr、zh-CN，也當 TTS 代碼），名稱都用 endonym，原本翻譯欄用的 `importLangXx` ARB 字串已不使用。翻譯欄預設：簡中介面→zh-CN、英文介面且手機語言是法/德/義/泰→該語言、其餘英文介面→en；匯入完成時用 `TtsService.isLanguageAvailable` 檢查第一欄與翻譯欄語言手機有沒有 TTS 語音，沒有就在完成訊息加提示（新 key `importVoiceMissing`，placeholder `language`）請使用者到「設定 → 文字轉語音」安裝。翻譯語言的英文選項 `importLangEn` 改為單純「英文」（原本寫「例如額外附註」會誤導學其他語言的人）。
- 範本 ARB：`app_zh.arb`（placeholder 的 @meta 只寫在這個檔）。gen-l10n 設定在 `l10n.yaml`。
- 背景程式（沒有 BuildContext）用 `BackgroundL10n.current()` 取字串。

### 新增一種語言的檢查清單
1. 新增 `lib/l10n/app_xx.arb`（所有 key 都要有，placeholder 要一致；新增 key 時 **9 個 ARB 含 app_en.arb** 都要加）
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
| 9 | 0.1.6 | 插頁廣告只在前景顯示（背景播完一輪改為待顯示）、開啟應用程式廣告（每小時上限、離開≥30秒、冷啟動不顯示）、全螢幕廣告間隔≥3分鐘、Firebase Analytics 事件、越南文/印尼文 App 內標題與商店一致、App 內特色介紹滑動導覽 | 已上傳封閉測試並送審（2026-09-27，連同 8 語新商店截圖/主題圖、多語版本資訊） |
| 11 | 0.1.8 | 泰文、阿拉伯文介面（RTL）與教材翻譯；自訂 CSV 支援阿拉伯文（兩欄選項、表頭字、分號/阿拉伯文分隔符號）；內建教材缺翻譯的項目不退回中文；功能介紹頁 14 語自訂教材、橫向左右排版 | **已上傳封閉測試，連同泰/阿商店資訊審查通過並發布（2026-09-28）** |
| 12 | 0.1.9 | 正式 App 桌面圖示（Android 自適應圖示）、桌面 App 名稱依手機語言顯示 10 語 appTitle（原為 english_learning_app）；iOS 相容的平台判斷（Android 行為不變）。版本資訊 `store_assets/release_notes_v12.md`（10 語） | 2026-09-29 程式完成，Actions #164、#165 建置成功（#165 只多改 HANDOFF，程式相同）；**2026-09-29 Lawrence 以 #165 的 AAB 上傳封閉測試（未先實機測試）** |
| 10 | 0.1.7 | **修正每日提醒從未跳出**：manifest 補上 flutter_local_notifications 的 ScheduledNotificationReceiver、ScheduledNotificationBootReceiver 與 RECEIVE_BOOT_COMPLETED（先前所有手機的定時提醒都不會觸發）；第二輪（紅米實測仍未跳出）：改用精準鬧鐘（SCHEDULE_EXACT_ALARM，使用者設定提醒時若未允許會開系統「鬧鐘與提醒」頁；未允許則退回非精準）、提醒頻道改高重要性 `reminder_high`（會跳橫幅，舊頻道刪除）；第三輪（2026-09-27 紅米實測仍無通知、通知中心與圖示角標皆無）：新增隱藏「通知診斷」工具（學習統計頁**長按「每日提醒」標題**）：顯示初始化結果、通知權限、精準鬧鐘權限、提醒頻道重要性、已排程 ID，並可發「立即測試」與「1 分鐘後測試」通知，用來區分是「通知根本發不出來」還是「排程沒觸發」。Lawrence 回報：通知開關、自啟動、省電無限制都已設定；特殊權限裡找不到「鬧鐘與提醒」；設定時間後有顯示「已完成設定」（=排程有進系統），但從未跳出「允許通知」系統視窗。測試機為紅米 Note 8／Android 11（所以沒有通知權限視窗、沒有「鬧鐘與提醒」，精準鬧鐘預設允許）。按 Home 鍵不滑掉 App、鎖屏等候仍無提醒，但朗讀的鎖屏媒體通知正常顯示→排除強制停止，問題在提醒頻道或排程觸發。診斷工具在 Actions #125 建置成功。**真正原因找到**：診斷顯示權限/頻道/排程全正常、立即通知會跳，但 1 分鐘測試報 `scheduledDate: Must be a date in the future`——`_nextInstanceOfLocalTime` 等處把本地時間先減時區偏移再丟 `TZDateTime.from`，但 `from` 取的是絕對時間點（epoch），等於多減 8 小時：每日提醒其實每天在設定時間**提早 8 小時**觸發（設 19:00 會在 11:00 跳），久未使用提醒也提早 8 小時。已改為直接 `TZDateTime.from(本地DateTime, tz.UTC)`。踩坑：**TZDateTime.from 不看牆上時鐘，別手動加減時區偏移**。2026-09-27 Actions #127 紅米實測：1 分鐘測試與每日提醒皆準時跳出 ✅。「通知診斷」工具保留（隱藏、僅中文，開發用） 另含：自訂教材 CSV 第一欄語言可選（朗讀用該語言 TTS）、英文介面作為不支援語言的預設（新增 app_en.arb）、功能介紹與匯入說明加一句「也可匯入英文以外的語言」（新 key `importWordLangLabel`）、CSV 表頭改為第一或第二欄是語言名稱也算表頭、翻譯語言英文選項改為單純「英文」、匯入時檢查手機有無該語言 TTS 語音並提示安裝、翻譯欄擴充為 13 種（新增簡中、法、德、義、泰） | 提醒已實機驗證通過；第一欄語言與英文介面待實機確認後上傳 |

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
- 市場順序：第一階段 繁中→日→韓→越→印尼（完成）；第二階段 簡中＋西＋葡（完成）；**第三階段（2026-09-27 Lawrence 決定）：第十一版同時做泰文＋阿拉伯文**，之後土耳其文。
- 第三階段市場分析（2026-09-27，EF EPI 2025＋StatCounter 2026）：泰國 EPI 402（極低）、Android 64%、約 7,100 萬人；阿拉伯文 埃及 EPI 458／沙烏地 404、埃及 Android 84～91%、一語涵蓋 20 多國且海灣國家購買力高；土耳其 EPI 488、Android 約 74%、約 8,600 萬人（通膨需在地定價）。不建議／往後：德法義（英文程度高，德國 615 極高）、孟加拉/巴基斯坦/印度（英文已普及、付費力低）、伊朗/俄（Play 付款受制裁）。
- 阿拉伯文右到左（RTL）：Flutter 加入 `ar` locale 後 Material 元件會**自動鏡像**，成本不高（先前說「成本最高」是高估）。程式裡寫死方向只有 5 處要改成 directional 寫法：`home_screen.dart` Alignment.centerLeft、skip_previous/skip_next 圖示，`onboarding_screen.dart` Alignment.centerRight，`settings_panel.dart` Alignment.centerLeft（改 AlignmentDirectional.centerStart/End 等）。需實機確認英文單字＋阿拉伯文翻譯同畫面（首頁單字卡、鎖屏）。翻譯用標準阿拉伯文（MSA）。另可評估 iOS 版（日本 iPhone 約 65%）。
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
- 新增任何 Android 原生套件功能時，要確認該套件 README 要求的 manifest 宣告（receiver/service/permission）有加進 `scripts/patch_android_manifest.sh`；android/ 目錄每次 CI 重新產生，手動改不會保留。
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

- [x] 第 9 版已上傳封閉測試並送審（2026-09-27）
- [x] App 內「特色介紹」滑動導覽（2026-09-26 完成，含在第 9 版）：`onboarding_screen.dart`，6 頁（20/80＋92%、目標族群痛點、背景朗讀、雙語＋不熟悉單字庫、匯入自訂教材、四大教材＋免費體驗）；首次開啟自動顯示一次（SharedPreferences `onboarding_seen_v1`，內容大改時改 v2 讓所有人再看一次），選單「功能介紹」可再看；8 語文案（ARB key `intro*`、`menuIntro`）以各語言商店說明為基礎
- [x] AdMob「開啟應用程式」廣告單元（名稱「開啟時」）已建立，ID 已存 GitHub Secret `ADMOB_APP_OPEN_AD_UNIT_ID`（2026-09-26）。第九版請用設定 Secret 之後的建置產物（Actions #108 之後那次）
- [x] 隱私權政策（docs/index.html）已新增 Firebase Analytics 匿名使用統計說明（2026-09-26）
- [x] Play Console「資料安全性」已補上 Analytics（App 互動＋裝置 ID 用途加「分析」），刪除資料網址填 `https://lawrence124875.github.io/english-learning-app/#data-deletion`（2026-09-26）
- [x] Play Console「前景服務權限」聲明已提交：類型「媒體播放」，附示範影片（2026-09-26）。之後若新增其他前景服務類型或權限（例如忽略電池最佳化）需另行聲明
- [x] 「切換教材」插頁廣告：Lawrence 2026-09-27 確認**不加**（主要收入是訂閱，廣告頻率保守）

- [x] 第 8 版已上傳送審（2026-09-24）
- [x] 簡中、西、葡商店資訊已新增（2026-09-24）
- [x] 各國訂閱價格：2026-09-26 原決定只用台幣定價＋自動換算；**2026-09-29 改為手動設定 24 個主要市場**（方法：各國 Duolingo 價格約 55%、有在地競品以競品為準；最終價格與方法見 launch_prep.md 第一節），其餘國家維持自動換算。⚠️ 之後改價**不要**選「套用到所有國家」，會覆蓋手動價格。
- [ ] 正式版存取權問卷：草稿見 `store_assets/launch_prep.md`（測試期滿後填，需補上實際收到的測試回饋）
- [x] 8 語商店截圖＋主題圖已上傳 Play Console（2026-09-27；圖在 `store_assets/localized/<lang>/`，腳本 `store_assets/generate_localized_assets.py`）
- [ ] 收集 TestersCommunity 回報並修正
- [ ] 第十版上傳前實機確認：匯入非英文 CSV（選第一欄語言）朗讀正確；手機語言改英文/德文看到英文介面、內建教材不顯示翻譯
- 小米設定按鈕（電池/自啟動）**保留**：提醒不跳的真因是時區換算，但 MIUI 在 App 被清理、重開機後仍可能擋掉排程，按鈕是實際使用的保險（Lawrence 2026-09-27 詢問後的結論）
- [x] 第十版實機驗證提醒（2026-09-27 通過）：先用「通知診斷」回報截圖（立即測試有無跳出、1 分鐘後測試有無跳出）再決定下一步修法；原流程：設定 2～3 分鐘後的提醒時間 → 關掉 App/鎖屏 → 確認通知跳出（紅米需開自啟動、省電無限制）
- [x] **第十版候選（Lawrence 2026-09-27 同意，同日決定併入第十版一起上傳，已完成）**：
  1. 自訂教材 CSV「第一欄語言」可選：目前 `app_state.dart` 朗讀 `word.word` 固定 `languageCode: 'en-US'`，匯入其他語言會用英文發音。改為匯入時選第一欄語言、朗讀用該語言 TTS。定位不變（仍是英文學習 App），只在功能介紹/商店說明提一句「也可匯入其他語言」。
  2. 英文介面只當「不支援語言」的預設介面（目前 fallback 是繁中，泰/土/德/法等手機會看到中文）；**不是**開拓印度等市場的策略。
- [x] 2026-09-29 已在 Play Console 逐國手動調整 24 個市場的訂閱價格（見 launch_prep.md 第一節）。正式上架後依各國付費數據再微調。
- [x] 2026-09-29 已用 App Store 官方內購清單核對越南、泰國、印尼、香港、印度、韓國的 Duolingo 價格：六國都在「約 55%（50～67%）」範圍內，不需調整；僅越南年繳 67% 在上緣，可選擇改 ₫349,000（待 Lawrence 決定）。結果見 launch_prep.md 第一節「六國核對結果」。
- [ ] 正式版上架後：小預算驗證（NT$1～3 萬，2～3 個已上架市場投 Google App 廣告），用 Analytics 看 D1/D7 留存與付費轉換，有數據再決定是否擴大。
- [x] **第十一版 0.1.8+11：泰文＋阿拉伯文（2026-09-28 已上傳發布）**（照 §4「新增一種語言的檢查清單」逐項做，兩種語言）：`app_th.arb`、`app_ar.arb`（全部 key）；main.dart supportedLocales；`BackgroundL10n._supported`／`translationKey()`（th、ar）；匯入畫面兩欄選項加阿拉伯文（`ar-SA`／`ar`，泰文已有），翻譯欄預設值加 th、ar；CSV 表頭字加泰文/阿拉伯文的「英文、翻譯」；四份教材 4,185 項加 th、ar 翻譯（NGSL 與 Spoken 重疊 696 字可重用；翻譯原則：最常用意思；manifest version +1）；阿拉伯文 RTL 5 處修正；商店文案（泰 th、阿 ar，App 名稱 ≤30、簡短 ≤80、完整 ≤4000）；版本資訊。**注意：第十版要上傳的 AAB 用 Actions #132～第十版版本資訊那次的建置，不要用第十一版開工後的建置。**
- [ ] 之後（依 Analytics 數據決定）：第三階段語言（泰文，或改印地語＝印度需「印地語介面＋印地語翻譯」）、iOS 評估（台灣 Android 約 40%、日本約 35%，iOS 優先度應往前）、「2,000 高頻句」新教材（需先確認來源授權）、若大量使用者匯入非英文內容再考慮另上架「任意語言背景朗讀」App。
- 市場分析備註（2026-09-27 統整 Lawrence 提供的兩份外部分析）：簡中商店服務的是海外華人（Play 在中國大陸不可用），不特別投資源；外部分析的 CPI/轉換率為估計值，保守看待。


---

## 13. 第十一版（0.1.8+11）泰文＋阿拉伯文 —— 2026-09-28 開工

### 已完成（commit c404c34，CI #135 建置成功）
- `app_th.arb`、`app_ar.arb`（全部 key，已用程式比對與 app_zh.arb key 集合一致、placeholder 一致）。App 名稱：泰「ฟังภาษาอังกฤษอัจฉริยะ」、阿「الإنجليزية بالاستماع الذكي」（商店名稱可再議，改的話兩邊同步）。
- main.dart supportedLocales、`BackgroundL10n._supported` 加 th、ar（translationKey 直接回傳 th / ar）。
- **內建教材缺翻譯的處理改為逐項**：`AppState._hideBuiltInTranslationFor(word)`——英文介面一律隱藏；非中文介面（泰、阿…）某項沒有該語言翻譯時不顯示、不朗讀（不退回中文）。所以教材翻譯可以分批補、分批 commit，建置出來的 App 不會出錯。
- RTL：AppBar 標題、設定面板、導覽頁「略過」改 AlignmentDirectional；首頁上一個/下一個按鈕在 RTL 時圖示互換（Row 自動鏡像後箭頭仍朝外）。單字卡文字方向**依內容語言**決定（`AppState.isRtlLanguage`、`wordIsRtl`、`meaningIsRtl`）：阿拉伯文介面下英文單字仍 LTR；中文介面匯入的阿拉伯文翻譯仍 RTL。
- 自訂 CSV：第一欄選項加 `ar-SA`（العربية）、翻譯欄加 `ar`；泰/阿介面的翻譯欄預設 th / ar；表頭字加泰文、阿拉伯文（含有無 hamza 寫法）；**分隔符號偵測**：第一列沒有逗號時改用 Tab、`;`、阿拉伯文分號 `؛`(U+061B)、阿拉伯文逗號 `،`(U+060C)。
- 版本號 0.1.8+11。

### 教材翻譯流程（進行中）
- 工具：`tools/translations/`。`wordlist.tsv` = 四份教材去重後 3,489 項（順序：NGSL → Spoken 新增 → PHRASE → PhaVE；欄位：序號、英文、zh-TW、es，用來對齊詞義）。
- 每批寫一個 `batch_NNN.tsv`（UTF-8、Tab 分隔、無表頭：英文<TAB>泰文<TAB>阿拉伯文），然後 `python3 tools/translations/merge.py` 合併進四份教材 JSON（依英文比對、同字多份教材一起寫入、不改順序），會印出各教材完成度。**不要把 merge.py 輸出接 head（會 BrokenPipe 中斷寫檔）**。
- 翻譯原則：同其他語言，以最常用意思為主，對齊 zh-TW 的詞義；泰文多義用「, 」分隔，阿拉伯文用「، 」分隔；阿拉伯文用標準阿拉伯文（MSA），少加母音符號。
- 取下一批：`sed -n <起>,<迄>p tools/translations/wordlist.tsv | cut -f2,3`（行號＝序號+1）。
- **進度：batch_001～020 全部完成（2026-09-28）**：NGSL 2809/2809、Spoken 720/720、PHRASE 506/506、PhaVE 150/150 皆有 th、ar。`assets/data/manifest.json` version 已改為 3。
- **商店文案與版本資訊已完成（2026-09-28）**：`store_assets/store_listing_th_ar.md`（泰：名稱21/簡短75/完整2109；阿：名稱26/簡短71/完整2167，架構同西/葡版，強調 20/80、92%、背景朗讀、以母語學習、TTS 需安裝該語言語音）；`store_assets/release_notes_v11.md`（10 語，皆 <500 字元）。
- **泰/阿商店截圖＋主題圖已完成（2026-09-28）**：`store_assets/localized/th/`、`store_assets/localized/ar/`（1_home、2_intro、3_stats、4_paywall、feature_graphic，規格同其他語言）。`generate_localized_assets.py` 改動：
  - 字型：Noto Sans Thai/Arabic＋Noto Sans（拉丁數字）＋Noto Sans Symbols 2（✓▶☆★）用 fontTools 合併，首次執行自動從 GitHub notofonts 下載合併到 `store_assets/.fontcache/`（已 gitignore，不進 repo）；泰/阿用 `ImageFont.Layout.RAQM`（容器 Pillow 12 已含 raqm）。
  - 泰文斷行用 pythainlp（`pip install pythainlp --break-system-packages`；泰文詞間無空格）。
  - 阿拉伯文整頁鏡像：`MDraw` 代理把 x 座標鏡像、文字錨點 l↔r、direction=rtl；打勾圖示與導覽頁上升趨勢圖示刻意**不鏡像**（鏡像後趨勢圖會像下降）；▶ 是文字所以不翻。
  - 可指定語言：`python3 store_assets/generate_localized_assets.py th ar`；已驗證既有 8 語輸出逐像素不變。
- **商店完整說明加強「自訂教材可學 14 種語言」（2026-09-28，Lawrence 決定）**：10 語「📥 匯入自己的教材」段落改寫（內建教材仍是英文，匯入功能當次要特色，名稱／簡短說明不動以免誤導）；各語言來源檔已同步、字數標註已更新；可直接複製貼上的彙整版在 `store_assets/store_listing_v11_full_descriptions.md`。
- **功能介紹頁修正（2026-09-28，原排第十二版，Lawrence 決定併入第十一版）**：
  - 第 5 頁 `introTitle5`/`introBody5`（11 份 arb 含 en）改寫為「匯入自己的教材，14 種語言都能聽」，口徑同商店說明（內建教材仍英文；舉日韓法德西泰阿等；部分語言需下載語音）。
  - 橫向時功能介紹頁原本只看得到圖示（圖示在上＋大量留白約 240dp，橫向可用高度約 200dp）→ `onboarding_screen.dart` 以 `MediaQuery.orientationOf` 判斷，橫向改左右排版（圖示 88、標題 titleLarge、文字靠起始側，RTL 自動換邊），底部按鈕縮小間距。**只修功能介紹頁**：其他頁橫向仍看得到文字、使用者會直覺往下滑，Lawrence 確認不改、也不鎖直向。
- **下一步**：確認 CI 建置成功→實機測試（見下方清單）→上傳 0.1.8+11、Play Console 新增 th、ar 商店資訊（文案 `store_listing_th_ar.md`、截圖/主題圖 `localized/th`、`localized/ar`、版本資訊 `release_notes_v11.md`）。

### 待實機確認（第十一版上傳前）
- 手機語言改泰文、阿拉伯文：介面、鎖屏、通知；阿拉伯文右到左排版（首頁、設定、匯入頁、導覽頁）。
- 匯入阿拉伯文 CSV（含 `؛` 或 `;` 分隔的檔案）、泰文 CSV，朗讀語音正確。


---

## 15. iOS 版規劃（2026-09-28 討論）

- **不開新專案**：Flutter 同一份程式碼、同一個 repo，只是多一個 iOS 建置 workflow（GitHub Actions `macos-latest`，公開 repo 免費）。
- Apple Developer Program 是**年費 US$99**（不是月費）。Lawrence 傾向：Android 正式上架、看使用數據後再決定是否付費上架 iOS。
- 付費前自用：iOS 沒有 APK，安裝檔是 IPA；可用 CI 建置未簽署 IPA，再用 Sideloadly（Windows/Mac）以免費 Apple ID 簽署安裝到自己的 iPhone。限制：**每 7 天要重新簽署一次**、免費帳號最多 3 個自簽 App、不能用 App 內購買（用個人全解鎖版 FORCE_PREMIUM）。
- 改程式要注意的 Android 專屬部分：`in_app_update`、`android_intent_plus`（小米/電池設定按鈕）、Android 精準鬧鐘權限與通知診斷裡的 Android 項目 → 需加 `Platform.isAndroid` 判斷。
- iOS 設定需要：Firebase 新增 iOS App 取得 `GoogleService-Info.plist`（存 GitHub Secret）、Info.plist 加 `UIBackgroundModes: audio`（背景朗讀）、`GADApplicationIdentifier`（AdMob，沒有會閃退；個人版可用測試 ID）、檔案選取與通知權限說明文字、iOS 最低版本（Firebase 需 iOS 13+）。
- Lawrence 的設備（2026-09-28）：MacBook Air 2017（macOS 最高 Monterey，裝不了新版 Xcode → **一律用 CI 建置 IPA，Mac 只負責簽署安裝**；僅晚上 7 點後在家可用）、公司 Windows 無管理員權限（只能用網頁，不能裝 Sideloadly/iTunes）。
- 7 天限制是 Apple 對免費帳號的規定，無法避開；建議用 AltStore（Mac 裝 AltServer，iPhone 與 Mac 同 Wi-Fi 時自動續簽）減少手動重裝。付 US$99 年費後改為一年一次。
- Android 個人全解鎖版：`build_personal.yml` 手動觸發即是當時 main 的內容。2026-09-28 以第十一版（d4d06d6）建置成功（build_personal #4）。與 Play 版同套件名稱、同簽署金鑰 → 安裝會取代 Play 測試版（資料保留）；之後 Play 推送更高版本代碼時會被覆蓋回一般版，需再手動建置一次。權杖需 Actions 寫入權限才能用 API 觸發（目前權杖可以）。
- **2026-09-28 iOS 自用版建置成功**（commit c71d907，`build_ios_personal.yml` 第一次即成功，約 25 分鐘；同 commit 的 Android 建置也成功）：
  - `build_ios_personal.yml`：手動觸發、macos-latest；flutter create ios → pub get → `flutter build ios --config-only`（產生 Podfile）→ `scripts/patch_ios.sh` → `flutter build ios --release --no-codesign --dart-define=FORCE_PREMIUM=true` → 打包 Payload/Runner.app 成未簽署 IPA（artifact `english-learning-app-personal-ios-ipa`）。沒傳 RevenueCat 金鑰（`SubscriptionService.initialize` 空字串略過）。
  - `patch_ios.sh`：Secret `FIREBASE_GOOGLE_SERVICE_INFO_PLIST`（plist 原文，Firebase 同一專案新增的 iOS App，Bundle ID `tw.bcc.englishapp`）寫入 ios/Runner 並用 xcodeproj gem 加入 Runner 資源；Bundle ID、最低 iOS 15.0；Info.plist：顯示名稱「智慧聽覺巡航」、UIBackgroundModes audio、GADApplicationIdentifier（預設 Google 測試 ID，正式上架改 Secret `ADMOB_IOS_APP_ID`）、CFBundleLocalizations 11 語、ITSAppUsesNonExemptEncryption=false。
  - Dart：`UpdateService`、電池最佳化、小米自啟動在非 Android 直接略過；統計頁這兩個按鈕只在 Android 顯示；通知加 Darwin 初始化（啟動不要權限）與 iOS 權限請求、iOS 通知樣式；TTS 在 iOS 設 sharedInstance＋playback 音訊類別（spokenAudio、藍牙、duckOthers）。
  - 尚未處理：AppDelegate 的 UNUserNotificationCenter delegate（只影響 App 在前景時通知是否顯示）；正式上架需另做簽署、RevenueCat iOS、AdMob iOS 廣告單元、App Store 截圖/隱私標籤。
  - **待 Lawrence 實機確認**：背景/鎖屏連續朗讀（iOS 在字與字之間的靜音空檔可能暫停 App，最需要驗證）、鎖屏播放控制、每日提醒、11 語介面、匯入 CSV。
- 2026-09-28 第一次用 Sideloadly v0.60 安裝失敗：密碼驗證通過後報 `Install failed: Guru Meditation … Invalid file`（iPhone 為 iOS 27.0；Mac 已裝 Apple 裝置支援元件）。已請 Lawrence 試：IPA 移到桌面、給 Sideloadly 完全取用磁碟、更新 Sideloadly。四步都做了仍失敗。**查到原因：Sideloadly 本身的已知問題**（SideloadlyiOS/Sideloadly-Download issue #17，iOS 27 普遍發生，其他 App 也一樣，不是我們 IPA 的問題；改圖示後的 IPA Sideloadly 能正常讀出名稱/版本/圖示）。社群暫時解法：改用開源的 **Impactor**（claration/Impactor，前身 PlumeImpactor，支援 macOS，也有自動續簽）。
- Impactor v2.6.5（macOS universal）用測試帳號登入時，簡訊雙重認證失敗（`Authentication SRP error 500: Failed to send SMS 2FA to devices`，Impactor 已知問題 #76/#128；該帳號未登入任何 Apple 裝置，只能走簡訊）。**改用 iPhone 本身登入的 Apple ID（驗證碼跳在 iPhone 上）→ 2026-09-28 17:43 安裝成功**。已勾 Auto Refresh [BETA]。以後固定用 Impactor＋主帳號，不要換工具（識別碼可能不同，會變成另一個 App、資料不共用）。Sideloadly 已不用。
- 狀態：已安裝，等 Lawrence 實機測試回報（背景朗讀最重要）。

## 16. App 桌面圖示（2026-09-28 發現並修正）

- **第十一版以前，Android 與 iOS 安裝後的桌面圖示都是 Flutter 預設藍色圖案**（CI 從沒替換過 mipmap；商店圖示 store_assets/icon.png 只用在 Play 商店頁）。Lawrence 確認紅米上是 Flutter 圖案。
- 修法：`tools/icons/generate_launcher_icons.py`（圖案同 generate_assets.py 的商店圖示，分層高解析度重畫）產生 `tools/icons/out/`：Android 各密度 `ic_launcher.png`＋自適應圖示（`mipmap-anydpi-v26/ic_launcher.xml`，背景漸層層＋前景白色圖案層，圖案縮到 0.72 倍落在 66dp 安全區內）；iOS `icon_1024.png`（不透明）。
- `scripts/patch_android_icons.sh` 在 flutter create 後把 out/android 複製進 res/（build_android.yml、build_personal.yml 都有這步）；`patch_ios.sh` 用 icon_1024.png 以 sips 覆蓋 AppIcon.appiconset 每張圖。
- 改圖示時：改 generate_launcher_icons.py → 重跑 → commit out/。
- **桌面 App 名稱同樣從沒設定過**（2026-09-28 Lawrence 在個人版發現）：Android 一直顯示 flutter create 預設的 `english_learning_app`。修法 `scripts/patch_android_label.sh`（兩個 Android workflow 都在圖示之後執行）：依各語言 ARB 的 `appTitle` 產生 `res/values-*/strings.xml` 的 `app_name`（values＝英文預設；zh/zh-rTW/HK/MO 繁中；zh-rCN/SG/b+zh+Hans 簡中；印尼文 values-in＋values-id），manifest `android:label` 改 `@string/app_name`。改 appTitle 就會同步。一樣要第十二版才會在 Play 版生效。
- iOS 目前 CFBundleDisplayName 固定「智慧聽覺巡航」（patch_ios.sh）；若日後 iOS 正式上架要做各語言名稱（各 .lproj 的 InfoPlist.strings，需用 xcodeproj 加成 variant group）。
- **Play 版要到下一次上傳（版本代碼 12 以上）才會換圖示**；個人版 APK 重新手動建置即可先看到。

---

## 17. Android 後續事項總整理（2026-09-28，新對話從這裡開始）

### A. 等待期間（現在可做）
1. **Play Console「正式發布前測試報告」**（測試及發布 → 測試 → 正式發布前測試報告）：到第十一版為止**一份都沒有產生**。2026-09-29 已在「設定」選好測試語言（繁中、阿拉伯文、泰文、日文、英文）、不提供憑證、深層連結留空並儲存；**第十二版上傳後檢查報告**（總覽／詳細資訊），有問題截圖給 Claude。
2. **收集 TestersCommunity 回饋**：整理回報，決定哪些併入第十二版。
3. **正式版存取權問卷草稿**：`store_assets/launch_prep.md` 第二節，✅ 2026-09-29 已依第 4～12 版修正紀錄改寫；期滿時補上【 】處（TestersCommunity 實際回饋、Crashlytics、正式發布前測試報告結果、預估安裝數）即可送出。

### B. 第十二版（0.1.9+12）—— **2026-09-29 已以 Actions #165 AAB 上傳封閉測試（未先實機測試）**；上傳後待辦：Play 更新後在紅米確認圖示/名稱/電池與小米按鈕/每日提醒，並重新手動建置個人版
- **App 桌面圖示與桌面名稱**（§16）：Play 版目前還是 Flutter 預設圖案、名稱顯示 `english_learning_app`，要上傳第十二版才會換（名稱依手機語言顯示 10 語 appTitle）。
- **桌面 App 名稱**（2026-09-28 Lawrence 發現）：Android 安裝後名稱一直是 `english_learning_app`（flutter create 預設，從沒改過，Play 版也一樣）。`scripts/patch_android_label.sh` 用各語 ARB 的 `appTitle` 產生 `res/values-*/strings.xml` 的 app_name（values 預設英文；繁中 values-zh/zh-rTW/HK/MO/b+zh+Hant；簡中 zh-rCN/SG/b+zh+Hans；印尼 values-in 與 values-id），並把 manifest 的 android:label 改成 `@string/app_name`。兩個 Android workflow 在套圖示後執行。iOS 名稱目前固定「智慧聽覺巡航」（patch_ios.sh 的 CFBundleDisplayName），正式上架 iOS 前再做多語 InfoPlist.strings。
- iOS 相容的平台判斷（§15）：`UpdateService`、電池/小米按鈕、通知權限在 Android 行為應不變 → **上傳前在紅米實機確認**：統計頁電池與小米按鈕仍在、每日提醒照常、App 內更新提示照常。
- ✅ 2026-09-29：版本號已改 0.1.9+12；10 語版本資訊 `store_assets/release_notes_v12.md`（只寫新圖示＋桌面名稱兩點，沒有寫「穩定性改善」——這版對 Android 使用者沒有其他實質修正，不寫不實內容）。
- **上傳步驟**：CI 成功 → 下載 AAB artifact → 紅米先裝 APK 確認（桌面圖示、名稱依語言、電池/小米按鈕、每日提醒、App 內更新）→ Play Console 封閉測試建立新版本、上傳 AAB、貼 10 語版本資訊 → 送審 → 通過後檢查「正式發布前測試報告」（A-1）。
- 時機（2026-09-29 決定）：**第十二版先做**（圖示＋名稱＋版本資訊），不等測試回饋；上傳新版不影響封閉測試天數，還能產生第一份正式發布前測試報告。測試回饋的修正放第十三版。

### C. 測試期滿後（預計 2026-10 上旬，2026-09-24 起算 TestersCommunity 16 天）
1. Play Console 申請正式版存取權（用 A-3 的問卷）。
2. 核准後建立正式版，推第十二版（或當時最新版）。
3. 正式版上線後：AdMob 連結 App（正式版前平台不允許）、確認廣告出現在免費版。

### D. 正式版上架後
1. 小預算驗證（NT$1～3 萬、2～3 個市場投 Google App 廣告），看 Analytics D1/D7 留存與付費轉換。
2. 依數據再決定：各國訂閱價格個別調整、土耳其文、iOS 是否付費上架（US$99/年）。

### E. 個人版提醒
- Android 個人全解鎖版（含新圖示）已建置：build_personal 以 30ce8fd 建置成功。Play 推第十二版後會被覆蓋回一般版，需再手動建置。
- iOS 自用版：Impactor＋主帳號、自動重新整理已勾、開機自動啟動已勾；每 7 天續簽（Mac 開著 Impactor＋同一個非訪客 Wi-Fi，或每週接線手動重裝）。
