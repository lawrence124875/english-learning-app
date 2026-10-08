# V2 Practical English 交接

V2 的進度與固定規則只寫在這個檔案；V1 的紀錄在 HANDOFF.md（V2 不改 V1 段落）。

## 固定規則

- 規格：`docs/PRACTICAL_ENGLISH_SPEC_V2_REVIEWED.md`（2026-10-08 定稿，Lawrence：SPEC = GO）。
- 分支：`feature/practical-english-v2`（從 V1 main 建立）。V2 commit 只推這裡；不改 main、不自行 merge、不自行開 PR。
- V1 是 Stable Baseline：只允許 V2 必要的最小相容修改（SPEC §3 列的三個掛勾），不順便重構。
- 不碰 Firebase、RevenueCat、AdMob、Play、GitHub Actions、Application ID。
- 依 Phase 1→7 逐段完成，每段回報：完成內容、修改檔案、測試結果、對 V1 影響、新的架構問題。SPEC 沒定義的重大架構問題先停下來問。
- 免費版規則（2026-10-08 正式）：句子中所有 target words 都在 V1 免費版已解鎖範圍內才可顯示／學習；Premium 全開。
- 本機測試：`flutter test`（CI 不跑測試）。

## 進度

| Phase | 內容 | 狀態 |
|---|---|---|
| 1 | Foundation：模組結構、Sentence、WordRef、SentenceIdFactory、JsonFileStore、SentenceRepository、反向索引 | ✅ 2026-10-08 |
| 2 | V1 相容：Migration Layer、fingerprint／reconciliation、★ ↔ Weak | ✅ 2026-10-08 |
| 3 | CSV Format B 匯入 | ✅ 2026-10-08 |
| 4 | Learning：PracticalEnglishState、清單／詳細頁、弱字優先、Coverage、我會了、免費／Premium 過濾、匯入畫面 | ✅ 2026-10-08 |
| 5 | PlaybackCoordinator | ○ |
| 6 | What's New | ○ |
| 7 | 整體測試 | ○ |

## Phase 1 備註

- `assets/practical_english/pe_core.json` 目前是空清單，第一批內容（NGSL 前 1,000 字）另外製作。
- 正規化不做 Unicode NFC（Dart 沒有內建，V2.0 不加套件）；SPEC §6.2 已註記，Lawrence 2026-10-08 確認。
- V2 程式不接 `main.dart`；Phase 4 只在首頁選單加一個入口。

## Phase 2 備註

- 入口：`LegacyMigration.run(datasets)`，每次進入 Practical English 呼叫（Phase 4 接上）。
- V1 ★ 讀寫一律經 `V1LegacyGateway`；正式版 `AppStateV1Gateway` 走 AppState 新增的兩個方法（`starredIndexesFor`、`replaceStarredFromPracticalEnglish`），同步更新 V1 記憶體、存檔與「僅不熟悉」播放清單。
- 相容判斷：教材前 count 筆的 fingerprint 與上次相同（未變更或只在尾端新增）→ V1 ★ 為準；否則視為重排 → 保留 V2 weak、修復 V1 ★。SPEC §5.3 已補充這條。
- 初次 migration（`pe_migration_version` 未設定）不寫任何 V1 資料。

## Phase 3 備註

- `SentenceCsvImporter.importCsv(csv, translationLocale:)`：先在記憶體驗證與合併，有變更才一次原子寫入。匯入畫面在 Phase 4 做。
- 計數以「列」為單位，每個非空白列剛好屬於 Added／Updated／Duplicate／Invalid Word ID／Invalid Row 其中一類。
- 欄位依表頭名稱對應（不分大小寫、順序不限）；`word_id` 可用 `|` 放多個；自訂單字必須寫 `datasetId/wordId`。

## Phase 4 備註

- 入口：首頁「⋮」選單「實用英文」（`home_screen.dart` 唯一 V1 修改：+13 行）。`PracticalEnglishState` 隨這個 route 建立、離開時 dispose＋flush，沒有註冊在 main.dart 的 MultiProvider（與 SPEC §3 字面不同，避免改 main.dart）。
- 每次進入：句子載入 → `LegacyMigration.run` → word_state 載入 → 建索引。之後只在 AppState 的 isPremium 或教材數量改變時重算。
- 排序：`SentenceSelector`，分數＝3×弱字＋1×（未學／看過／學習中），已學會 0；同分→句子最近練習時間較舊者→ID。「全部」模式用原始順序。
- 權限：`SentenceAccess`，句中每個字 index < `AppState.unlockedCount(dataset)` 才可學（含看廣告暫時解鎖的範圍）。
- 進入句子頁就算練習一次（句中每字 peExposureCount+1，同一字只算一次）。
- 播放：暫用既有介面（V1 巡航中先 `stopCruise()`，再用同一個 TTS 朗讀）。V1 播放搶回、鎖屏等交給 Phase 5 PlaybackCoordinator。
- 字串：42 個 `pe*` key，11 語系都有。
- 測試：`test/practical_english/learning_test.dart`（23 個，含 widget test；I/O 用 `tester.runAsync`）。
