# 智慧聽覺巡航 V2：Phase 6 核准前檢查、環境盤點與產品發展規劃

- 撰寫日期：2026-10-09
- 分支：`feature/practical-english-v2`
- 檢查基準 commit：`1d1777b`

本次只做檢查與報告：沒有修改程式碼、SPEC、測試或設定，沒有動句庫，沒有開始 Phase 7，沒有 merge 或開 PR。唯一新增的檔案就是本報告。

證據等級（全文統一使用）：

| 標記 | 意思 |
|---|---|
| **【實測】** | 本次在 Claude 雲端環境實際執行命令或測試得到的結果 |
| **【程式碼】** | 讀實際程式碼得到的結論，沒有執行 |
| **【文件】** | 只有文件、記憶或先前回報，本次未重新驗證 |
| **【未驗證】** | 能做但還沒做 |
| **【無法】** | 目前環境無法驗證 |

---

## 1. 執行摘要

- **Phase 6 建議：建議核准（限程式與 widget 測試層級）。** 實機驗收併入 Phase 7 前置工作。
  - What's New 的 10 個檢查項目中：7 項通過、2 項部分通過、1 項只在程式層通過，沒有發現缺陷。
  - 本次重跑 96 個測試全部通過；flutter analyze 沒有新問題。
- **Phase 4 三個問題都還在。** 都不是缺陷，是待確認的設計取捨。
- **免費解鎖規則必須在句庫上線前決定。** 用實際教材計算 NGSL 前 1,000 字（每句一個目標字、連結所有同字形 ref）的結果：
  - 現行規則：免費可學 531 句、鎖住 469 句。
  - 方案 A：免費 939 句、鎖住 61 句。
  - 建議採方案 A，但只在內建教材之間互通，自訂教材不參與（理由見 §4）。
- **新發現**：同一個字出現在多份 V1 清單時，V2 的句子會顯示多個同名單字標籤，各自的狀態可能不同，分數也會重複計算。這不是資料錯誤，但使用者會覺得奇怪，需要產品決定（§4.5）。
- **環境**：
  - Claude 環境可以跑 unit 和 widget 測試、analyze。
  - 不能建置 APK／AAB，也沒有模擬器或實機：沒有 Android SDK、dl.google.com 被網路政策擋、沒有 KVM。
  - CI（GitHub Actions）能建置 APK／AAB，但不跑任何測試，而且 Flutter 版本沒有固定。
- **推薦路線**：先走路線 A（穩定上架），完成後接路線 B 的離線學習功能；路線 C 往後放。

---

## 2. Phase 6 核准前檢查

### 2.1 Git 狀態【實測】

**報告撰寫前**

| 項目 | 結果 |
|---|---|
| 分支 | `feature/practical-english-v2`，與 `origin/feature/practical-english-v2` 同步 |
| 工作目錄 | 乾淨（`git status`：nothing to commit, working tree clean） |
| 最新 commit | `1d1777b`，2026-10-09 04:22:37 UTC，"V2 Phase 6: What's New for upgrading V1 users" |

Phase 1～6 都可以追溯：

| Phase | Commit | 時間（UTC） |
|---|---|---|
| SPEC 定稿 | `87dd7a8` | 2026-10-08 12:08 |
| Phase 1 | `6c8e538` | 2026-10-08 12:23 |
| Phase 2 | `9473619` | 2026-10-08 13:08 |
| Phase 3 | `08b8311` | 2026-10-08 14:02 |
| Phase 4 | `20e46d8` | 2026-10-08 19:03 |
| Phase 5 | `c94fc26` | 2026-10-09 04:06 |
| Phase 6 | `1d1777b` | 2026-10-09 04:22 |

**與其他分支的差異**

- **main**：V2 分支有 7 個 commit 不在 main（SPEC ＋ 6 個 Phase）。main 有 6 個新 commit 不在 V2 分支：商店截圖、HANDOFF 和問卷文件，最新是 `84f4184`。
  - 兩邊修改的檔案沒有重疊（`comm` 比對結果為空），預期 merge 不會衝突。這只是推論，沒有實際 merge。
- **句庫分支** `claude/v2-sentence-library-iagowl`：改了 `V2_HANDOFF.md`、`tools/practical_english/*`、`pe_core.json`（目前已還原成空清單）。日後合回 V2 分支時，`V2_HANDOFF.md` 會衝突，需要人工合併。

### 2.2 What's New 實作核查

實作位置【程式碼】：

- `lib/practical_english/data/whats_new_service.dart`：`WhatsNewService.prepareOnLaunch()`、`markSeen()`
- `lib/practical_english/presentation/screens/whats_new_screen.dart`：`WhatsNewScreen.showOnLaunch()`、`showOnce()`、`open()`、`build()`
- `lib/presentation/screens/home_screen.dart`：`HomeScreenState._showIntroductions()`，以及選單項目 `'whatsNew'`

測試檔：`test/practical_english/whats_new_test.dart`（11 個）。

| # | 檢查項目 | 程式碼依據 | 測試名稱 | 結果 |
|---|---|---|---|---|
| 1 | V1 舊使用者只在升級後第一次看到 | `prepareOnLaunch`：沒有 `app_schema_version` 且有 V1 證據 key → 不寫已看過紀錄、回傳 true；`showOnce` 先 `markSeen` 再顯示 | "V1 user (onboarding seen) upgrading…"、"V1 upgrade: What's New once, onboarding not repeated"、"shown once: after markSeen…" | **通過**【實測，widget】；實機【無法】 |
| 2 | 全新安裝不會被誤判 | 沒有任何 V1 key → 直接寫入 `pe_2_0` | "fresh install: not shown…"、"fresh install: onboarding, no What's New"（含重啟） | **通過**【實測】 |
| 3 | `onboarding_seen_v1` 判斷順序 | `showOnLaunch`：先 `prepareOnLaunch()` → 再 `showOnboarding()` → 最後 `showOnce()`。測試用的是真的 `OnboardingScreen.showIfFirstTime` | "fresh install: onboarding, no What's New"：確認功能介紹寫入 key 之後，下次啟動仍不顯示 | **通過**【實測】 |
| 4 | 正確記錄已讀 | `markSeen()` 寫入 `last_seen_whats_new_version = pe_2_0`，在顯示之前寫 | "shown once…" | **通過**【實測】 |
| 5 | 首頁「新功能」可以重開 | `home_screen.dart` 的選單 `'whatsNew'` → `WhatsNewScreen.open` | "home ⋮ menu has 新功能 and opens What's New"（真的 HomeScreen，previewMode）、"can be reopened from the menu any time" | **通過**【實測，widget】 |
| 6 | 重啟後保留已讀 | SharedPreferences | 同 #1、#2 的重啟段落；測試用 SharedPreferences mock，同一個 process 內重建畫面 | **部分通過**：邏輯【實測】，真的 process 重啟與磁碟持久化【無法】 |
| 7 | 三個值各自負責 | `app_schema_version`＝資料模型版本（int 2）；`last_seen_whats_new_version`＝已看過的介紹；內容 ID＝`currentWhatsNew = 'pe_2_0'`。三者都和 pubspec 版本號無關 | "an older What's New id is replaced by pe_2_0"、"not seen yet on a later launch…" | **通過**【實測】 |
| 8 | 11 種語言都有標題、說明、按鈕和回退 | 11 個 ARB 各 248 個 key，缺漏 0、空值 0【實測，腳本比對】；不支援的手機語言由 `BackgroundL10n.resolve` 回退到英文【程式碼】 | "all 11 languages render the page"：11 種語言都能渲染、沒有例外、4 個項目都在 | **部分通過**：渲染【實測】；回退英文只有【程式碼】；翻譯品質與阿拉伯文 RTL 視覺【未驗證】（需要母語者或實機截圖） |
| 9 | 語言切換、缺翻譯、空值會不會崩潰 | 字串都是 gen-l10n 產生的非空 getter；缺 key 在編譯時就會失敗；畫面沒有任何可能為 null 的資料 | 同 #8 | **通過（程式層）**：沒有崩潰路徑【程式碼＋實測】；執行中切換語言【未驗證】 |
| 10 | 不必要的 V1 寫入、重複彈窗、升級流程 | V1 key 只讀；寫入的只有兩個新 key | V1 升級測試逐一比對 5 個 V1 key 的值都沒變 | **通過**【實測】；邊界情況見下方 |

**#10 邊界情況（理論上可能，沒有重現成缺陷）**【程式碼】

- V1 使用者有 `settings_v1`、但從沒寫入 `onboarding_seen_v1` 時，會依序看到「功能介紹 → What's New」兩個畫面。V1 第一次開 App 就會寫入功能介紹的 key，所以實際上幾乎不會發生。
- V1 使用者兩個證據 key 都沒有（例如從沒改過設定、又在功能介紹出現前就裝了 App），會被當成全新安裝而看不到 What's New。這符合 SPEC 定義。
- 內建句庫目前是 0 句，「立即試試」會進到空的實用英文頁。這是內容進度問題，不是程式缺陷。

### 2.3 重新執行測試【實測，本次】

| 命令 | 結果 |
|---|---|
| `flutter test` | **96 個，通過 96，失敗 0，略過 0**，約 12 秒，exit 0 |
| `flutter test test/practical_english/whats_new_test.dart` | 11 個，通過 11，失敗 0 |
| `flutter analyze` | 3 個問題，都是 V1 原本就有的（見下方）；V2／Phase 6 新增 0 個 |
| `flutter doctor -v` | 見 §5 |

各檔測試數（逐檔計數，加總 96）：

| 測試檔 | 數量 |
|---|---|
| `fit_word_area_test.dart`（V1） | 1 |
| `foundation_test.dart` | 20 |
| `v1_compatibility_test.dart` | 13 |
| `csv_import_test.dart` | 9 |
| `learning_test.dart` | 23 |
| `playback_test.dart` | 19 |
| `whats_new_test.dart` | 11 |

`flutter analyze` 的 3 個既有問題：

- `lib/data/repositories/stats_repository.dart:1`：unused_import（warning）
- `lib/data/sources/ads_service.dart:3`：unnecessary_import（info）
- `lib/data/sources/subscription_service.dart:44`：`purchasePackage` deprecated（info）

`flutter test` 會自動執行 pub get，沒有改到 `pubspec.lock`；測試後 `git status` 仍然乾淨。

### 2.4 Phase 6 判定

**建議核准（程式與 widget 測試層級）。**

理由：

- SPEC §11 每一條都有對應的程式碼和自動化測試。
- 用真的 V1 功能介紹和真的首頁選單驗證過判斷順序。
- V1 key 只讀，已有測試確認。
- 本次重跑全部通過。

尚未排除的風險：

1. 沒有實機或模擬器驗證：真的 App 重啟、真的 SharedPreferences 持久化、從 v19 升級。
2. 翻譯品質、阿拉伯文 RTL 視覺、不支援語言的回退沒有實測。
3. 句庫是空的，What's New 會把升級使用者帶到空頁面。建議 V2 上架前確保有內容。

---

## 3. Phase 4 三個未解問題

原始出處：`/mnt/project-files/v2/v2_phase4_report.md` 第 15 點，以及 `V2_HANDOFF.md` 的 Phase 4 備註。原報告其實列了 4 點；第 4 點「播放搶占」已由 Phase 5 處理，所以下表的「三個問題」是指第 1～3 點。

| # | 原始問題 | 涉及檔案 | 後續處理 | 現況 | 影響與建議 |
|---|---|---|---|---|---|
| 1 | SPEC §3 寫 PracticalEnglishState「註冊在 MultiProvider」，實作改成跟著頁面建立 | `practical_english_screen.dart`（`ChangeNotifierProvider(create: …)`）、`main.dart`（沒改） | 沒有 commit 變更。Phase 5 把 coordinator 放在 AppState，PE 頁面進出時登記和取消，生命週期一致 | **仍存在（刻意設計）**。Phase 5 的 dispose 測試證明離開頁面時所有權會正確釋放 | 低。好處是 V1 啟動完全不受影響。建議在 SPEC §3 補一句註記，確認這個做法 |
| 2 | V1 看獎勵廣告在這次開啟期間多解鎖 20 字，PE 句子也跟著解鎖 | `sentence_access.dart`（`_unlockedCountOf` ＝ `AppState.unlockedCount`）、`app_state.dart`（`_sessionExtraUnlocked`） | 沒有 | **仍存在（與 V1 一致）**。沒有專門測試；免費／Premium 測試用的是基本 1/3 規則 | 低。PE 頁面每次進入都重建，所以數字一致。建議維持 |
| 3 | 內建句庫 `pe_core.json` 是 0 句，但選單入口看得到 | `assets/practical_english/pe_core.json` | 由句庫分支負責：草稿 100 句在 `draft_001.tsv`，尚未審核，`pe_core.json` 已還原為空 | **仍存在** | 中（產品面）。V2 上架前一定要有內容，或者把入口和 What's New 一起延後開放。這和 §4 的免費規則綁在一起 |

---

## 4. 免費版／Premium 解鎖規則核查

### 4.1 正式規則（SPEC）【文件】

SPEC §12 與 2026-10-08 Lawrence 確認的規則：句子裡**所有** target words 都在 V1 免費已解鎖範圍內，才可以顯示和學習；Premium 全部開放。

### 4.2 實際程式碼【程式碼】

`lib/practical_english/domain/services/sentence_access.dart` 的 `SentenceAccess`：

- `isAccessible`：`wordIds` 不可為空，而且每個 WordRef 都要通過 `isWordUnlocked`。
- `isWordUnlocked`：找到該 ref 所在的教材和 index，判斷 `index < AppState.unlockedCount(該教材)`。
- `isResolvable`：任何一個 ref 找不到時，句子不顯示、也不計入鎖住數。

這是**逐 ref** 判斷。同一個字在 NGSL 已解鎖、但在口語清單沒解鎖時，含這兩個 ref 的句子會被鎖住。

### 4.3 測試驗證的規則【實測】

`learning_test.dart` 的測試 11～13，驗證的是現行「逐 ref 全部解鎖」規則。測試資料裡沒有跨清單同字形的 ref，所以 §4.4 的問題沒有被測到。

### 4.4 各清單的免費範圍與實際影響【實測，以 assets 資料計算】

免費解鎖範圍是各清單 `floor(長度 / 3)`：

| 清單 | 長度 | 免費解鎖 |
|---|---|---|
| NGSL 2809 | 2,809 | index 0–935 |
| 口語 720 | 720 | index 0–239 |
| 語塊 506 | 506 | index 0–167 |
| 片語動詞 150 | 150 | index 0–49 |

- 4,185 個項目共 3,439 種字形，其中 746 種出現在不只一份清單。
- NGSL 前 1,000 字裡有 642 個字在其他清單也有。

假設句庫第一批是「每句一個 NGSL 字、`wordIds` 連結所有同字形 ref」（句庫分支的做法）：

| 規則 | 免費可學 | 鎖住 |
|---|---|---|
| 現行（每個 ref 都要解鎖） | 531 | **469** |
| 方案 A（任一份清單解鎖即可） | 939 | 61 |
| 只連 NGSL 的 ref | 936 | 64 |

**各種情況的結果**【程式碼】

| 情況 | 現行規則 | 方案 A |
|---|---|---|
| 多個目標字 | 每個都要解鎖 | 每個字（以字形計）有任一清單解鎖即可 |
| 重複 ref | `toSet` 去重，不受影響 | 同左 |
| 找不到的 ref | 句子隱藏（兩種規則相同） | 同左 |
| 使用者匯入的自訂字 | 依該自訂教材的 1/3 | 如果自訂教材也參與「任一清單」，使用者可以自建一份清單，把 Premium 字放在前 1/3，免費解鎖句子 |

**建議方案 A′**：方案 A 只在 4 份內建清單之間互通；自訂教材的 ref 仍依該教材自己的 1/3 判斷。

**Premium**【程式碼】

- `SubscriptionService.isPremium()` 出錯時回傳 false，屬於 fail-closed：不會錯誤授權，但離線或 RevenueCat 出錯時，Premium 使用者可能暫時被當成免費。這是 V1 原有行為。
- PE 會監聽 AppState，isPremium 改變時立即重算（測試 13 驗證過）。
- `FORCE_PREMIUM` 只用在個人版 CI 建置。

**UI 數字是否一致**【實測＋程式碼】

- 進度卡的「可學句子 a／b」、鎖住提示的數量、列表內容，都用同一個 `SentenceAccess` 計算。
- 「全部」模式下，列表筆數等於 a（測試 19：3／6，列表 3 句）。「只練不熟悉」模式本來就是子集合。
- 可學的句子都能播放（播放沒有另外做權限判斷）。

### 4.5 同一個字在不同清單的狀態不一致【程式碼，新發現】

- V1 的 ★ 是「每份清單、每個 index」分開記錄；V2 的 weak／mastered 是每個 WordRef 分開記錄（SPEC 定義）。
- 句子連結 `the`（NGSL）和 `the`（口語）兩個 ref 時：
  - 列表和句子頁會出現兩個 `the · 狀態` 標籤，狀態可能不同。
  - 按「我會了」只影響其中一個 ref，也只移除那一份清單的 ★。
  - 排序分數兩個 ref 各算一次，跨清單的常用字會被排得比較前面。
  - 進度卡的「全部單字數」以 ref 計算（4,185），不是以字形計算（3,439）。
- **影響**：使用者困惑，不會造成資料錯誤。V1 原本就有「同一個字在不同清單分開打 ★」的情況。
- **需要決定**：
  1. 維持以 ref 為單位，只在 UI 合併同字形的標籤，按鈕一次套用到所有同字形 ref。
  2. 句庫只連主要清單的 ref。
  
  建議選 1，搭配方案 A′。

---

## 5. 開發與測試環境盤點

### 5.1 Claude 雲端環境【實測】

| 項目 | 實際檢查結果 | 證據／命令 | 狀態 | 限制 | 建議 |
|---|---|---|---|---|---|
| 作業系統 | Ubuntu 24.04.5 LTS，x86_64 | `flutter doctor -v`、`uname -a` | 已確認可用 | 雲端容器，閒置後會回收 | — |
| Flutter／Dart | Flutter 3.47.6 stable，Dart 3.13.5 | `flutter doctor -v` | 已確認可用 | 放在 `/tmp/flutter`，容器回收後要重新下載 | CI 也應固定同一版本 |
| Android SDK／Build Tools | 找不到 | doctor：「Unable to locate Android SDK」 | 已確認不可用 | dl.google.com 回 403（網路政策） | 無法在本環境補上 |
| Java | OpenJDK 21.0.12 | `java -version` | 已確認可用 | 沒有 SDK，用不上 | — |
| Gradle | 8.14.3（系統安裝） | `gradle --version` | 部分可用 | repo 沒有 `android/`，由 CI 執行 `flutter create` 產生 | — |
| AGP 版本 | 無法得知 | repo 沒有 `android/` 資料夾 | 無法直接檢查 | 由 CI 執行時的 `flutter create` 決定 | 固定 Flutter 版本，間接固定 AGP |
| Xcode／iOS SDK | 沒有 | Linux 環境 | 已確認不可用 | — | iOS 用 CI 的 macos runner（`build_ios_personal.yml`） |
| Git／GitHub | git 2.43.0；可以 push V2 分支、fetch 所有分支 | `git push`、`git fetch` | 已確認可用 | 只能用 GitHub MCP 工具，沒有 gh CLI；範圍限 3 個 repo | — |
| 網路 | pub.dev 可以；dl.google.com 不行 | `flutter pub get` 成功；curl 回 403 | 部分可用 | 由環境設定的網路政策決定 | 需要的話由 Lawrence 在環境設定開放 |
| flutter doctor／pub get／analyze／test | 都可以執行 | 見 §2.3 | 已確認可用 | — | — |
| 建置 APK／AAB | 不行 | 沒有 SDK | 已確認不可用 | — | 用 CI 建置 |
| 建置 iOS | 不行 | — | 已確認不可用 | — | CI（macos） |
| Emulator／AVD／ADB | 沒有；也沒有 `/dev/kvm` | `which adb emulator`、`ls /dev/kvm` | 已確認不可用 | 沒有硬體虛擬化，模擬器無法執行 | Lawrence 用實機，或 Firebase Test Lab（付費／額度） |
| 實體裝置、Logcat | 沒有 | — | 已確認不可用 | — | Lawrence 的手機＋電腦 adb |
| Chrome／Linux desktop | 沒有 Chrome；GTK 缺 | doctor | 已確認不可用 | — | 不需要 |

### 5.2 GitHub Actions【程式碼，讀 workflow 檔】

| Workflow | 觸發方式 | 做什麼 | 狀態 |
|---|---|---|---|
| `build_android.yml` | push 到 main（排除 md、docs、store_assets）或手動觸發 | `flutter create` → 一系列 patch 腳本 → release 簽章 → 建置 APK＋AAB → 發佈到私人 repo `english-app-builds` 的 Release | 【文件】run219 成功建置 v19；本次【未驗證】 |
| `build_personal.yml` | 只能手動觸發 | 同上，加 `FORCE_PREMIUM=true`（全解鎖、不顯示廣告），發佈到私人 Release | 【未驗證】 |
| `build_ios_personal.yml` | 只能手動觸發，macos | iOS 個人版 | 【未驗證】 |
| `update_release_notes.yml` | 手動 | 更新 Release 說明 | — |

重要事實：

- **CI 不跑 `flutter test` 和 `flutter analyze`**（grep 沒有結果）。
- **Flutter 版本沒固定**（`channel: 'stable'`），每次建置可能拿到不同版本。
- 兩個 Android workflow 用同一個簽章和 package，所以 CI 建出的 V2 APK 可以覆蓋安裝 CI 建出的 V1 APK。但**不能覆蓋從 Play 安裝的版本**（Play 用的是 App Signing 金鑰），從 Play 版升級的測試要走 Play 測試軌道。
- 這些 Secrets 只在 workflow 裡引用，本報告不列出、也沒有讀取。

### 5.3 Lawrence 的電腦和手機

【無法直接檢查】【文件】：

- Play 封閉測試（v19）已上傳。
- 訂閱已在實機測試通過（main `84f4184`）。

### 5.4 測試能力分類

| # | 測試 | 可執行？ | 已驗證？ | 需要什麼 | 主要限制 | 建議方式 |
|---|---|---|---|---|---|---|
| 1 | Unit | 是 | 已驗證（96 個中多數） | — | — | 繼續 |
| 2 | Widget | 是 | 已驗證（V2 畫面、What's New、首頁選單） | — | 不是真的引擎渲染、不是真的外掛 | 繼續 |
| 3 | Integration（integration_test） | 否 | 否 | 裝置或模擬器 | 本環境沒有 | Lawrence 的手機或 Test Lab |
| 4 | Golden | 理論上可以 | 否 | 字型、固定版本 | 跨平台差異大 | 暫不需要 |
| 5 | APK 安裝與啟動 | 否 | 否 | CI 建置＋手機 | — | CI 手動觸發＋Lawrence 安裝 |
| 6 | 真實 Android 裝置 | 否 | 否（V2） | 手機 | — | Lawrence |
| 7 | TTS 語音 | 只有 fake | 只驗證邏輯 | 真的 TTS 引擎 | — | 實機 |
| 8 | 背景播放、鎖屏 | 否 | 否 | 實機 | — | 實機清單 |
| 9 | 來電、耳機、音訊焦點 | 否 | 否 | 實機 | V1 也沒有自動化測試 | 實機 |
| 10 | CSV 匯入、大型檔案 | 部分 | 正確性已驗證；大型檔案未驗證 | — | 沒有效能測試 | 加 1 萬列的 unit 測試＋實機計時 |
| 11 | 中斷寫入、損毀復原 | 部分 | 損毀＋.bak 復原已有 unit 測試【文件：Phase 1】 | — | 真的斷電無法模擬 | 維持 unit＋實機強制關閉 |
| 12 | 11 種語言、字型 | 部分 | key 完整性與渲染已驗證 | — | 字型、RTL 視覺 | 實機截圖 |
| 13 | Premium 購買與恢復 | 否 | 【文件】V1 實機通過 | Play 測試帳號 | — | Lawrence |
| 14 | AdMob | 否 | 否 | 實機＋測試廣告 | — | Lawrence |
| 15 | Firebase、Crashlytics | 否 | 【文件】V1 已驗證 | Firebase Console | — | Lawrence 看後台 |
| 16 | Play Internal／Closed | 否 | 【文件】v19 封閉測試 | Play Console | — | Lawrence |
| 17 | AAB 上傳與發佈前檢查 | 否 | 【文件】 | Play Console | — | Lawrence |
| 18 | 多版本、多尺寸、低記憶體 | 否 | 否 | 多台裝置或 Test Lab | — | Test Lab 或 Play 預發布報告 |
| 19 | 離線與重新連線 | 部分 | V2 不連網（程式碼）；V1 內容更新失敗會靜默略過（程式碼） | 實機飛航模式 | — | 實機 |
| 20 | 長時間播放、耗電 | 否 | 否 | 實機 | — | Lawrence 實測 1 小時 |

### 5.5 外部服務

| 服務 | 程式碼整合 | 測試模式 | 真實帳號已驗證 | 本次 |
|---|---|---|---|---|
| Firebase Core／Analytics | 有（`analytics_service.dart`） | — | 【文件】 | 未驗證 |
| Crashlytics | 有；V2 錯誤也會回報（`PracticalEnglishState._reportToCrashlytics`） | — | 【文件】 | 未驗證 |
| Firestore | 有（意見回饋 `feedback_service.dart`） | — | 【文件】已建立 asia-east1 | 未驗證 |
| Firebase Storage | 有（`remote_word_repository.dart`：可遠端更新單字內容） | — | 【文件】 | 未驗證 |
| AdMob | 有（`ads_service.dart`，Unit ID 由 dart-define 傳入） | — | 【文件】正式 ID | 未驗證 |
| RevenueCat／Play Billing | 有（`subscription_service.dart`，entitlement `premium`） | — | 【文件】實機訂閱通過 | 未驗證 |
| Play In-App Update | 有（`update_service.dart`） | — | — | 未驗證 |
| GitHub Actions | 有 | — | 【文件】run219 | 未觸發 |

---

## 6. V1／V2 實際功能完成度

狀態代號：

- A：程式碼存在，而且有測試驗證
- B：程式碼存在，但測試不足
- C：部分完成
- D：尚未實作
- E：證據不足

### 6.1 V1

| 功能 | 狀態 | 程式碼 | 測試 | 備註、V1 風險 |
|---|---|---|---|---|
| 4,185 詞彙 | B | `assets/data/*.json`（2809＋720＋506＋150，實測加總 4,185）；`RemoteWordRepository` | 沒有專門測試 | 可以從 Firebase Storage 遠端更新內容；**遠端更新只能在尾端新增**，否則 V1 的 ★ 和學過紀錄（以 index 存）會錯位（V2 reconciliation 會修 weak，但 V1 統計不會修） |
| 播放與 TTS | B | `AppState._speakCurrent`、`_speakWord`、`SystemTtsService` | playback_test 有 V1 回歸 1 個（fake TTS） | 實機【文件】 |
| 順序、隨機、僅不熟悉 | B | `ScopeMode`、`PlaylistBuilder` | v1_compatibility 測到「僅不熟悉」播放清單 | — |
| ★ 不熟悉 | A | `toggleStarCurrent`、`ProgressRepository` | v1_compatibility 13 個 | — |
| 學習統計 | B | `StatsRepository.markLearned` | migration 測試只讀 | — |
| 自訂 CSV 匯入 | B | `csv_import_service.dart`、`import_dataset_screen.dart` | 沒有 | — |
| 11 種介面語言 | A（完整性） | `lib/l10n/*.arb`、`BackgroundL10n.resolve` | whats_new_test 渲染 11 語 | 跟隨手機語言，App 內沒有切換開關【程式碼】 |
| 自訂詞彙：學習語言與翻譯語言 | B | `_wordLocaleOptions`（14 種）、`_translationLocaleOptions` | 沒有 | 見下方 |
| 多語言 TTS | B | `speak(languageCode:)` | 沒有 | 只有英文能固定語音；其他語言用系統預設語音 |
| Premium | B | `SubscriptionService` | 只有 FORCE／debugPreview 路徑 | 出錯時 fail-closed |
| AdMob、Firebase、Play | B | 見 §5.5 | 沒有 | 【文件】實機 |
| 本機儲存與升級相容 | B | SharedPreferences `*_v1` | v1_compatibility 驗證格式不變 | — |

**三件不同的事**【程式碼】

1. **介面語言**：11 種（zh、zh_Hans、en、ja、ko、vi、id、es、pt、th、ar）。
2. **自訂教材第一欄（要學的語言、TTS 語言）**：14 種（en-US、zh-TW、zh-CN、ja-JP、ko-KR、vi-VN、id-ID、es-ES、pt-BR、fr-FR、de-DE、it-IT、th-TH、ar-SA）。
3. **自訂教材翻譯欄**：同樣 14 種，可以任意配對（例如西班牙文→泰文、泰文→西班牙文、日文→繁中、韓文→英文，資料格式都支援）。

限制：

- 每個 CSV 只有一個翻譯欄。
- 能否朗讀取決於手機有沒有該語言的 TTS（匯入時會檢查並提醒）。
- 內建教材只有英文。
- **V2 句子目前只有 `targetLanguage`（預設 en-US）加多語翻譯**。Format B 匯入可以指定 `target_language`，但沒有實測非英文句子的完整流程【未驗證】。

### 6.2 V2

| 功能 | 狀態 | 程式碼 | 測試 | 尚存問題 |
|---|---|---|---|---|
| Sentence 模型 | A | `domain/models/sentence.dart` | foundation | — |
| WordRef（內建＋自訂） | A | `word_ref.dart`、`word_ref_index.dart` | foundation、learning 16 | 使用者看不到自訂教材的 WordRef ID，自己製作 CSV 不容易【文件：句庫報告】 |
| Sentence ID 與碰撞 | A | `sentence_id_factory.dart`（FNV-1a 64、`-2` 後綴） | foundation（固定期望值） | 不做 NFC（SPEC 已註記） |
| JSON 原子寫入、損毀復原 | A | `json_file_store.dart` | foundation | 真的斷電無法模擬 |
| SentenceRepository、反向索引 | A | `sentence_repository.dart` | foundation | — |
| ★ ↔ Weak 雙向 | A | `weak_word_sync.dart`、`app_state_v1_gateway.dart` | v1_compat、learning 3–6 | §4.5 同字形跨清單 |
| 詞彙重排、插入、刪除的調和 | A | `legacy_migration.dart`（fingerprint） | v1_compat | — |
| CSV Format B 與 5 種分類 | A | `sentence_csv_importer.dart`、`sentence_import_screen.dart` | csv_import 9、learning 17/18/23 | 大型檔案未測 |
| 三種學習模式 | A | `sentence_selector.dart` | learning 8/9 | 分數受跨清單 ref 影響（§4.5） |
| 句子播放 | A（邏輯） | `PracticalEnglishState.speak` | playback、learning 21 | 真的 TTS【無法】 |
| 我會了、mastered | A | `setMastered` | learning 5/6/22 | — |
| PlaybackCoordinator | A（邏輯） | `playback_coordinator.dart`、`AppState._speakCurrent` | playback 19 個 | 鎖屏、來電【無法】 |
| What's New | A（widget） | §2.2 | whats_new 11 個 | 實機【無法】 |
| 免費／Premium | A（現行規則） | `sentence_access.dart` | learning 11–13 | 規則待決定（§4） |
| 離線 | B | V2 沒有任何網路呼叫【程式碼】 | 沒有專門測試 | — |
| 遷移與 V1 資料保護 | A（unit） | `legacy_migration.dart` | v1_compat、learning 15 | 實機從 v19 升級【無法】 |
| 內建句庫內容 | D | `pe_core.json` 是空的 | — | 句庫分支進行中 |

---

## 7. 測試檔案與覆蓋缺口

| 檔案 | 目的 | 主要案例 | 本次結果 | 未涵蓋 |
|---|---|---|---|---|
| `test/fit_word_area_test.dart` | V1 單字區字級縮放 | 1 個 | 通過 | V1 其他功能幾乎都沒有自動化測試 |
| `foundation_test.dart` | ID、正規化、JSON store、repository | 20 個 | 通過 | — |
| `v1_compatibility_test.dart` | migration、reconciliation、★ 同步、AppState 整合 | 13 個 | 通過 | — |
| `csv_import_test.dart` | 5 種分類、冪等、合併規則 | 9 個 | 通過 | 大型檔案、BOM 或非 UTF-8（部分） |
| `learning_test.dart` | State、選句、覆蓋率、免費／Premium、資料、UI | 23 個 | 通過 | 跨清單同字形 |
| `playback_test.dart` | coordinator 與 V1／V2 互斥 | 19 個 | 通過 | 真的 TTS 和音訊焦點 |
| `whats_new_test.dart` | 判斷、流程、選單、11 語 | 11 個 | 通過 | 真的重啟 |

結論：

- 測試集中在 unit 和 widget 層。V2 的使用流程（進入 → 列表 → 句子 → 標記 → 回列表）已有 widget 流程測試。
- **沒有任何 integration、實機或 CI 測試**。
- V1 本身的自動化測試很少，V1 穩定性主要依靠先前的實機測試和封閉測試【文件】。

---

## 8. Top 10 風險

### 8.1 已確認的問題（有程式碼證據，不是推測）

1. **§4.5 同字形跨清單**：句子出現多個同名標籤，狀態可能不一致，分數重複計算。屬於 UX 問題，資料本身是正確的。
2. **現行免費規則加上跨清單連結**：句庫上線後，第一批 1,000 句會鎖住 469 句（§4.4 計算結果）。
3. **CI 不跑測試、Flutter 版本沒固定**：建置可能用到和本地測試不同的 Flutter 版本。
4. **句庫是空的**：What's New 和入口會把使用者帶到空頁面。

### 8.2 風險表

| 風險 | 嚴重度 | 可能性 | 證據 | 使用者影響 | 建議驗證／改善 | 優先級 |
|---|---|---|---|---|---|---|
| V1 使用者升級後資料遺失 | 高 | 低 | unit 測試證明 V2 不改 V1 key；實機【無法】 | ★、進度、訂閱全部消失 | CI APK：v19 → V2 覆蓋安裝，照清單逐項比對 | P0 |
| 免費解鎖計數與產品預期不符 | 中 | 高（已確認） | §4.4 | 免費使用者大量句子被鎖，觀感差 | 先決定規則，再改 `SentenceAccess` 並補測試 | P0 |
| 背景播放、鎖屏、TTS 在實機失敗 | 高 | 中 | 只有 fake TTS 測試 | 沒有聲音或兩邊同時說話 | 實機清單（§11） | P0 |
| 遠端單字內容更新造成 index 錯位 | 高 | 低 | `RemoteWordRepository` 可以遠端替換清單 | V1 的 ★ 和統計錯位 | 制定「只能在尾端新增」的規則並寫進 HANDOFF；可加檢查 | P1 |
| ★／Weak 同字形不一致 | 中 | 高（已確認） | §4.5 | 使用者困惑 | 產品決定後合併 UI 顯示 | P1 |
| CI 和本地 Flutter 版本不一致 | 中 | 中 | workflow 用 `channel: stable` | 建置失敗或行為不同 | CI 固定版本並加 test／analyze 步驟（需要核准） | P1 |
| What's New 重複出現或漏出現 | 中 | 低 | widget 測試通過；邊界情況見 §2.2 | 打擾使用者或錯過介紹 | 實機：全新安裝與升級各測一次 | P1 |
| JSON 損毀或寫入失敗 | 中 | 低 | 有 unit 測試；斷電【無法】 | 弱字可能遺失（會從 V1 ★ 補回） | 實機強制關閉測試 | P2 |
| CSV 匯入大型檔案卡頓 | 低 | 中 | 未測 | 匯入時畫面停住 | 1 萬列測試 | P2 |
| 多語文字缺漏或回退錯誤 | 低 | 低 | key 完整性 100%；翻譯品質未審 | 文字不自然 | 母語者或 ChatGPT 抽查、實機截圖 | P2 |

其他已評估、但沒有排進前 10 的項目：

- Premium 錯判：fail-closed，V1 原有行為。
- CSV 重複資料：已測冪等。
- 句子連到錯誤單字：WordRef 驗證已測；內容正確性屬於句庫審核。
- Play 發佈和外部服務：沿用 V1 已驗證的流程。

---

## 9. 產品功能建議（17 項）

優先級定義：

| 等級 | 意思 |
|---|---|
| P0 | V2 上架前必須完成 |
| P1 | 上架後第一輪（1–2 個月）最值得做 |
| P2 | 有價值，但等有使用數據後再決定 |
| P3 | 長期或需要外部服務，暫不做 |

| 功能 | 解決的痛點 | 使用者價值 | 難度 | 需 AI | 需網路 | 離線 | 成本 | V1 影響 | 驗收方式 | 優先級 |
|---|---|---|---|---|---|---|---|---|---|---|
| **A1** CI 建置流程整理（固定 Flutter 版本、加 test／analyze、V2 測試 APK） | 建置不可重現 | 間接（品質） | 低 | 否 | CI | — | 免費額度 | 無（只改 CI） | 綠燈＋APK 可安裝 | P0 |
| **A2** 實機升級與播放驗收 | 單元測試無法涵蓋實機 | 避免災難性問題 | 低（人工） | 否 | 否 | — | 0 | 無 | 清單全部通過 | P0 |
| **A3** 第一批句庫（審核後的 NGSL 1,000 句） | V2 沒有內容 | 核心 | 中（內容） | 製作時用 | 否 | 是 | 審核時間 | 無 | 審核紀錄＋匯入測試 | P0 |
| **A4** 免費規則 A′ ＋ 同字形合併顯示 | 469 句被鎖、標籤重複 | 高 | 低 | 否 | 否 | 是 | 0 | 無 | 補 unit／widget 測試 | P0 |
| **A5** 本機備份與匯出（★、weak、匯入句子、自訂教材打包成檔案） | 換手機時資料遺失 | 高 | 中 | 否 | 否 | 是 | 0 | 小（讀 V1 key） | 匯出 → 刪除 → 匯入，比對資料 | P1 |
| **A6** 無障礙與大字（TalkBack 標籤、字級） | 閱讀困難 | 中 | 低 | 否 | 否 | 是 | 0 | 小 | 無障礙掃描 | P2 |
| **B1** 慢速播放與單句重複次數 | 句子太快聽不清楚 | 高 | 低 | 否 | 否 | 是 | 0 | 無（V2 自己的設定） | widget＋實機 | P1 |
| **B2** 句子連續播放（V2 自己的巡航，前景） | 一句一句按太麻煩 | 高 | 中 | 否 | 否 | 是 | 0 | 中（要經 coordinator） | playback 測試 | P1 |
| **B3** 每日目標與連續天數 | 缺少動機、流失 | 中高 | 低 | 否 | 否 | 是 | 0 | 無 | unit | P1 |
| **B4** 跟讀模式（播放 → 停頓 → 再播放，不評分） | 只聽不說 | 中 | 低 | 否 | 否 | 是 | 0 | 無 | 實機 | P2 |
| **B5** 輕量間隔複習（依練習時間和弱字提醒到期句子，不做完整 SRS） | 學了就忘 | 中高 | 中 | 否 | 否 | 是 | 0 | 無 | unit | P2 |
| **B6** 從單字跳到例句（V1 首頁顯示「例句」按鈕） | V1 和 V2 是兩個孤島 | 高 | 低 | 否 | 否 | 是 | 0 | **有**（改 V1 首頁） | widget | P1 |
| **B7** 學習回顧頁（每週練習數、弱字變化） | 看不到進步 | 中 | 低 | 否 | 否 | 是 | 0 | 無 | unit | P2 |
| **C1** 情境分類與學習路徑（旅遊、職場、業務；`category` 欄位已存在） | 不知道學什麼 | 高 | 中 | 否 | 否 | 是 | 內容成本 | 無 | 篩選測試 | P2 |
| **C2** 多語言句子（非英文 targetLanguage 的完整流程、使用者看得到自訂 WordRef） | 定位成多語工具 | 中高 | 中 | 否 | 否 | 是 | 0 | 小 | 西→泰、泰→西實機 | P2 |
| **C3** 可擴充內容包（離線下載主題句庫） | 內容成長 | 中 | 中 | 否 | 下載時需要 | 是 | Storage 流量 | 無 | 下載與驗證 | P3 |
| **D1** AI 情境對話、句子生成、發音評分、雲端同步 | 進階練習 | 中 | 高 | 是 | 是 | 否 | API 與伺服器費用、隱私 | — | — | P3 |

只要不用 AI、可以離線就能提升學習成效的項目：B1、B2、B3、B5、B6、C1。其中 B1、B6 成本最低、效果最直接。

**定位建議**：「用自己的單字清單，聽懂和用上真實句子的離線多語學習工具」。

- 差異點是 V1 已有的 14×14 自訂語言配對，加上 V2 的句子和弱字連動。
- 不追 AI 對話這類需要伺服器的競爭。

---

## 10. 三種產品路線比較（3–6 個月）

以下是產品規劃推測，不是已證實的結果。

| 項目 | A 穩定上架 | B 學習成效 | C 差異化 |
|---|---|---|---|
| 主要內容 | A1–A4、A5 | A3、A4 ＋ B1、B2、B3、B6、B5 | C1、C2、C3、D1 |
| 開發時間 | 短（約 3–6 週，大部分是人工驗收） | 中（2–3 個月） | 長（3–6 個月以上） |
| 技術難度 | 低 | 中 | 高（D1 需要後端） |
| 測試與維護 | 低 | 中 | 高 |
| V1 影響 | 最低 | 低（B6 碰首頁） | 中 |
| 學習成效 | 中（有內容就有價值） | 高 | 不確定 |
| 留存 | 中 | 高（每日目標、連續播放） | 不確定 |
| 商業化 | 沿用現有 Premium | Premium 價值提高 | 可能有新收費點，但成本也高 |
| 外部依賴 | 低 | 低 | 高（AI API、伺服器） |
| 最大風險 | 功能少，吸引力有限 | 範圍蔓延 | 成本與隱私，偏離離線定位 |
| 先做 | A2、A4、A3 | B1、B6 | C1 |

**推薦：先 A 後 B。**

- V2 目前的瓶頸不是功能，而是**內容、免費規則和實機驗證**；這些沒完成，任何新功能都無法上架。
- 完成 A 後，用 B1、B6、B2、B3 讓 V2 真正每天被使用，這些都不需要 AI、可以離線、成本低。
- C 等有使用數據再評估。

---

## 11. Phase 7 前置工作與驗收規劃（只是規劃）

建議依序進行，一次只做一件事：

1. **Phase 6 最後驗收**：Lawrence 和 ChatGPT 審閱本報告，接受「widget 層級通過、實機驗收併入第 6 步」，就核准 Phase 6。
2. **Phase 4 三項**：
   - 第 1 項：在 SPEC §3 補註記。
   - 第 2 項：維持。
   - 第 3 項：跟第 4 步的句庫進度綁定。
3. **產品決策**（Lawrence）：
   - 免費規則：A′（建議）、A，或維持現行。
   - 同字形顯示：合併顯示（建議），或只連主要清單。
   - 句庫只有 0 句時，V2 入口和 What's New 要不要先隱藏。
4. **句庫**：句庫分支完成 ChatGPT／Gemini 審核 → 轉成 Format B → 合回 V2 分支，需要人工處理 `V2_HANDOFF.md` 的衝突。
5. **建置流程**：建議用既有的 `build_android.yml`，在 GitHub 網頁對 V2 分支手動觸發。
   - 最低必要修改（需要另外核准）：
     - 固定 `flutter-version: 3.47.6`。
     - 建置前加 `flutter analyze` 和 `flutter test`。
     - V2 分支的 Release 標成 prerelease，避免和正式版混在一起。
   - 本次沒有建立、修改或觸發任何 CI。
6. **實機測試（Lawrence 的 Android 手機）**：
   - 先從 `english-app-builds` 安裝 run219（v19）APK，正常使用並打幾個 ★。
   - 覆蓋安裝 V2 APK（同一個簽章）。
   - 逐項確認：
     - ★、學過統計、播放位置、設定、自訂教材、提醒、Premium 都還在。
     - What's New 出現一次，重啟後不再出現。
     - 全新安裝（先解除安裝）時不出現 What's New。
     - V1 巡航中播放句子會停止 V1；鎖屏按 ▶ 會停止 V2。
     - 來電、拔耳機、App 進背景時 V2 停止。
     - 11 種語言切換後的畫面截圖。
   - 從 Play 版升級要走 Play 內部測試軌道（簽章不同）。
7. **多語言**：用西→泰、泰→西各匯入一份 V1 自訂教材，確認朗讀；V2 用 Format B 匯入一份 `target_language=es-ES` 的句子（目前未驗證）。
8. **句庫品質**：照 Lawrence 定的流程：Claude 起草 → ChatGPT 審 → Gemini 交叉檢查 → ChatGPT 合併。句庫分支負責。

**分工**

| 誰 | 做什麼 |
|---|---|
| Claude | 修改程式碼和測試、句庫工具、寫報告、分析 CI 建置紀錄 |
| Lawrence | 觸發 CI、在手機安裝和測試、Play Console、RevenueCat、AdMob、Firebase 後台、最後的產品決策 |
| 外部 | Play 測試軌道、測試者；選用 Firebase Test Lab（額度或付費） |

**Phase 7 建議範圍**：以 SPEC 的「整體測試」為主，加上第 3 步決策落地的小修改（A′ 和合併顯示）。

- 驗收條件：
  - SPEC §16 的全部驗收項目。
  - 第 6 步的實機清單全部通過。
  - CI 綠燈並產出 APK。
- 回報格式：沿用 Phase 6，加上實機截圖或錄影清單。

---

## 12. 需要 Lawrence／ChatGPT 決定的事項

1. **是否核准 Phase 6**（建議核准，實機驗收併入 Phase 7）。
2. **免費解鎖規則**（建議 A′：4 份內建清單任一份已解鎖就算解鎖，自訂教材獨立判斷）。
3. **同字形跨清單的顯示與按鈕**（建議 UI 合併顯示，按鈕一次套用到所有同字形 ref）。
4. **句庫還沒有內容時，入口和 What's New 要不要先隱藏**（建議等第一批內容到位後再一起開放）。
5. **是否允許修改 CI**（固定 Flutter 版本、加測試步驟、V2 測試版 APK）。
6. **推薦路線**：先 A 後 B，是否同意。

---

## 13. 實際執行過的命令與結果（本次）

| 命令 | 結果 |
|---|---|
| `git status`／`git log`／`git fetch`／`git branch -a`／`git rev-list --left-right --count origin/main...HEAD` | 見 §2.1（main 6 個新 commit、V2 7 個） |
| `git diff --name-only`（與 main、句庫分支比對） | 與 main 沒有重疊；與句庫分支重疊 `V2_HANDOFF.md` |
| `flutter test` | 96／96 通過，exit 0 |
| `flutter test test/practical_english/whats_new_test.dart` | 11／11 通過 |
| `flutter analyze` | 3 個既有問題，0 個新問題 |
| `flutter doctor -v` | Flutter ✓；Android toolchain ✗；Chrome ✗；Linux toolchain ✗（GTK） |
| `java -version`／`gradle --version`／`git --version`／`uname -a` | OpenJDK 21.0.12／Gradle 8.14.3／git 2.43.0／x86_64 |
| `curl https://dl.google.com/...` | 403（proxy tunnel 被拒） |
| `ls /dev/kvm`、`which adb emulator` | 都不存在 |
| Python：ARB key 比對 | 11 檔各 248 個 key，缺漏 0、空值 0 |
| Python：免費規則計算（讀 `assets/data/*.json`） | 見 §4.4 |
| grep：`.github/workflows` | CI 沒有 test／analyze；Flutter channel 為 stable |

---

## 14. 證據不足、無法驗證或需要外部環境的項目

- **環境限制，無法驗證**：
  - APK／AAB 建置、模擬器、實機。
  - 鎖屏、通知、來電、耳機、音訊焦點。
  - 真的 TTS。
  - Premium 購買、AdMob、Firebase 後台。
  - Play 發佈、長時間播放與耗電、多裝置。
- **無法直接檢查**：
  - AGP 版本（repo 沒有 `android/`）。
  - CI 實際使用的 Flutter 版本（沒固定）。
  - Lawrence 的裝置與帳號狀態。
- **只有文件或先前回報**：
  - V1 實機訂閱、Crashlytics、Vitals 驗證。
  - run219 建置。
  - 封閉測試狀態。
- **未驗證，但可以補自動化測試**：
  - 大型 CSV。
  - 非英文 `targetLanguage` 的句子流程。
  - 不支援語言回退英文。
  - 跨清單同字形的句子行為。
- 本報告放在 `docs/`，而 `docs/` 會透過公開的 GitHub Pages 發佈。報告內容不含任何機密，repo 本身也是公開的。

---

## 15. Git 狀態證明

- **撰寫前**：分支 `feature/practical-english-v2`，HEAD `1d1777b`，工作目錄乾淨，與 origin 同步。
- **撰寫後**：只新增 `docs/V2_PHASE7_READINESS_AND_PRODUCT_ROADMAP.md` 一個檔案，單獨提交並推送。commit 內容可以用 `git show --stat HEAD` 確認只有這一個檔案。
- 測試執行後 `git status` 仍然乾淨：`pubspec.lock` 和產生的 l10n 檔案都沒有變動，l10n 產生檔本來就不在版控內。
