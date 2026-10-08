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
| 3 | CSV Format B 匯入 | ○ |
| 4 | Learning：PracticalEnglishState、清單／詳細頁、弱字優先、Coverage、我會了、免費／Premium 過濾 | ○ |
| 5 | PlaybackCoordinator | ○ |
| 6 | What's New | ○ |
| 7 | 整體測試 | ○ |

## Phase 1 備註

- `assets/practical_english/pe_core.json` 目前是空清單，第一批內容（NGSL 前 1,000 字）另外製作。
- 正規化不做 Unicode NFC（Dart 沒有內建，V2.0 不加套件）；SPEC §6.2 已註記，Lawrence 2026-10-08 確認。
- V2 程式尚未接到 `main.dart` 或任何 V1 畫面，Phase 4 才接。

## Phase 2 備註

- 入口：`LegacyMigration.run(datasets)`，每次進入 Practical English 呼叫（Phase 4 接上）。
- V1 ★ 讀寫一律經 `V1LegacyGateway`；正式版 `AppStateV1Gateway` 走 AppState 新增的兩個方法（`starredIndexesFor`、`replaceStarredFromPracticalEnglish`），同步更新 V1 記憶體、存檔與「僅不熟悉」播放清單。
- 相容判斷：教材前 count 筆的 fingerprint 與上次相同（未變更或只在尾端新增）→ V1 ★ 為準；否則視為重排 → 保留 V2 weak、修復 V1 ★。SPEC §5.3 已補充這條。
- 初次 migration（`pe_migration_version` 未設定）不寫任何 V1 資料。
