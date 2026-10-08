# 智慧聽覺巡航：正式上架前準備

---

## 一、各國訂閱價格（2026-09-29 已在 Play Console 手動設定，第二版）

**定價方法**（2026-09-29 定案）：以各國 **Duolingo Super 當地價格** 為錨點，我們定在其 **約 55%（容許 50～67%）**；有直接在地競品時以競品為準（日本 mikan、韓國 말해보카）；年繳約為月繳 6.5 倍。
- 不用 Netflix 當基準：Netflix 各國價格受片庫授權、當地語言內容、競爭影響，不純粹反映學語言的付費意願。
- 找不到可靠 Duolingo 資料的市場先維持，不硬套公式。
- **資料可信度（2026-09-29）**：App Store 官方內購清單已核對＝美國、台灣（年 NT$1,530～2,650）、日本（年 ¥9,900～14,200）、巴西、法國/歐元區（年 €94.99～110.99、月 €10.49）、沙烏地、阿聯、新加坡、馬來西亞、哥倫比亞，以及 **2026-09-29 補核對的越南、泰國、印尼、香港、印度、韓國**（見下方「六國核對結果」）；第三方整理的 2026-09 App Store 快照＝墨西哥、埃及、巴基斯坦、土耳其。
- 2026-09-29 補查（App Store 各國 Duolingo 內購清單）：沙烏地、阿聯、新加坡、馬來西亞、哥倫比亞已調整；清單上較低的年繳價視為標準年繳、最高者為定價上限。
- 資料來源與日期不一（部分 2025 年），Duolingo 各平台及促銷價不同，視為區間參考。
- 長期：正式上架有流量後，用 Play Console「價格實驗」實測（先確認是否支援訂閱）。

調整前（Google 自動換算，基準約 US$4.69／31.99）的全部價格見 `current_prices_2026-09-29.csv`。

| 市場 | 月繳 | 年繳 | 參考 |
|---|---|---|---|
| 台灣 | NT$149 | NT$999 | Duolingo 年 NT$1,530 |
| 香港 | HK$42 | HK$258 | Duolingo 年 HK$468～658（App Store）；月 HK$78（未在清單） |
| 日本 | ¥800 | ¥5,800 | Duolingo ¥2,190／11,900；mikan Premium 月 ¥1,000 |
| 韓國 | ₩8,900 | ₩59,000 | Duolingo 年 ₩100,000～125,000（App Store）；말해보카 ₩19,500／119,000 |
| 新加坡 | S$8.98 | S$54.98 | Duolingo 年 S$84.98～122.98（App Store） |
| 馬來西亞 | RM16.90 | RM109.90 | Duolingo 年 RM167.90～244.90（App Store） |
| 越南 | ₫55,000 | ₫349,000 | Duolingo 年 ₫599,000～860,000（App Store）；月 ₫99,000（2025，未在清單） |
| 印尼 | Rp35,000 | Rp249,000 | Duolingo 年 Rp419,000～600,000（App Store）；月 Rp65,000（二手） |
| 泰國 | ฿99 | ฿590 | Duolingo 年 ฿949～1,370（App Store）；月 ฿169（2025，未在清單） |
| 巴西 | R$16.90 | R$99.90 | Duolingo R$31.90／179.90 |
| 墨西哥 | MX$89 | MX$549 | Duolingo 月 MX$161 |
| 哥倫比亞 | COP 15,900 | COP 99,900 | Duolingo 月 COP 27,900～30,000／年 189,900～274,900 |
| 美國 | US$6.99 | US$44.99 | Duolingo $12.99／約 $84～96 |
| 歐元區 | 未變（€4.89～4.99） | 未變（€32.99～34.99） | 刻意例外：多數為英文介面、需求較低 |
| 沙烏地 | SAR 24.99 | SAR 149.99 | Duolingo 月 SAR 49.99／年 209.99～299.99 |
| 阿聯 | AED 24.99 | AED 149.99 | Duolingo 月 AED 49.99／年 199.99～289 |
| 埃及 | EGP 39 | EGP 249 | Duolingo 月 EGP 64.99 |
| 印度 | ₹109 | ₹699 | Duolingo 月 ₹199～215／年 ₹1,199～1,749（App Store） |
| 巴基斯坦 | PKR 399 | PKR 2,490 | Duolingo 月 Rs749 |
| 奈及利亞 | NGN 1,990 | NGN 12,990 | 英語國家，需求低 |
| 土耳其 | TRY 179.99 | TRY 1,099.99 | Duolingo 月 ₺329.99 |
| 菲律賓 | ₱149 | ₱990 | 未查到（英語普及、英文介面，優先度低） |
| 肯亞 | KES 249 | KES 1,690 | 未查到（優先度低） |
| 孟加拉 | BDT 299 | BDT 1,990 | 未查到（優先度低） |

**六國核對結果（2026-09-29，App Store 各國 Duolingo 內購清單；清單最低年繳視為標準年繳）**：
| 市場 | Duolingo 標準年繳 | 我們年繳 | 比例 | 結論 |
|---|---|---|---|---|
| 越南 | ₫599,000 | ₫349,000（原 ₫399,000） | 58% | 2026-09-29 Lawrence 決定調降並已在 Console 完成：月 ₫55,000（原 ₫59,000）、年 ₫349,000 |
| 泰國 | ฿949 | ฿590 | 62% | 維持 |
| 印尼 | Rp419,000 | Rp249,000 | 59% | 維持 |
| 香港 | HK$468 | HK$258 | 55% | 維持 |
| 印度 | ₹1,199（月 ₹199） | ₹699（月 ₹109） | 58%（月 55%） | 維持 |
| 韓國 | ₩100,000 | ₩59,000 | 59% | 維持 |
- App Store 清單只列前 10 個內購項目，多數國家只看得到年繳（印度例外有月繳）；月繳比例仍以舊資料估算。

其餘國家（含「其他國家/地區」USD／EUR 群組）維持 Google 自動換算價。若 Console 因最低價限制改填了別的數字，以 Console 實際為準。

**注意**：之後若在 Console 改價格，**不要**選「套用到所有國家／依匯率更新所有國家」，會把上表手動價格覆蓋掉；只改要改的國家。

---

## 二、正式版存取權問卷（2026-10-08 定稿草稿，取代 9/29～9/30 舊稿）

用法：英文（EN）貼進 Play Console；中文（中）是對照，不用貼。【 】是送出前要你確認或替換的地方。
來源：HANDOFF.md §6 版本紀錄、§17 B3～B7，以及 store_assets/launch_prep.md 舊草稿（已併入第十六～十九版）。

---

### 第 1 部分：封閉測試

#### 1. How easy was it to recruit testers for your app?
選項建議：**Difficult（困難）**。若有文字欄：

EN:
> As an individual developer it was difficult to find enough testers on my own, so I used a tester community service (TestersCommunity). 15 testers joined through a Google Group and stayed opted in for the whole testing period, and I also tested every build myself on a physical device.

中：個人開發者自己很難找到足夠測試者，所以使用 TestersCommunity 測試者社群服務。15 位測試者透過 Google 群組加入，整個測試期間都維持參與；每個建置我也都在實機上自己測試。

#### 2. Describe the engagement you received from testers during your closed test.

EN:
> Testers installed the app and used its core features: background and lock-screen audio playback of English vocabulary, bilingual reading (English followed by the meaning in their language), marking difficult words, learning statistics, daily reminders, and importing custom word lists via CSV. The tester community returned a written test report covering a variety of devices and Android versions (functionality, usability, responsiveness and store-policy compliance). I tested every build on a physical device (Redmi Note 8, Android 11) and published 9 updates to the closed testing track during the test, from version 0.1.1 to 0.3.1.

中：測試者安裝並使用核心功能：背景／鎖屏英文單字朗讀、雙語朗讀、標記不熟悉單字、學習統計、每日提醒、CSV 匯入自訂單字表。TestersCommunity 提供書面測試報告，涵蓋多種裝置與 Android 版本（功能、易用性、反應速度、商店政策）。我每個建置都在紅米 Note 8（Android 11）實機測試，測試期間共發布 9 次更新到封閉測試軌道（0.1.1 到 0.3.1）。

#### 3. Provide a summary of the feedback you received from testers. Include how you collected the feedback.

EN:
> I collected feedback through the tester community's written report, the in-app feedback form, Firebase Crashlytics, and my own daily use on a physical device. The tester report found no crashes or functional bugs on the devices and Android versions tested. Its two main suggestions were: (1) store optimization, because the app had no English store listing and too few keywords, and (2) a "Share app" option so users can recommend it to friends. Other suggestions (onboarding, in-app feedback, localization) were already in the app. Crashlytics reported one startup crash related to the notification permission request. My own device testing found several issues: daily reminders firing at the wrong time, the app freezing when opened from a reminder, missing pause/play buttons on the lock-screen media card, audio getting out of sync when tapping next/previous quickly, the media card staying visible after closing the app, and long phrases overlapping the buttons in the new large word size.

中：回饋來源：TestersCommunity 書面報告、App 內意見回饋表單、Firebase Crashlytics、我自己每天實機使用。報告結論：測試的裝置與 Android 版本都沒有當機或功能錯誤。兩項主要建議：①商店最佳化（沒有英文商店資訊、關鍵字太少）②加「分享 App」。其他建議（導覽、App 內回饋、多語）App 原本就有。Crashlytics 回報一個與通知權限請求有關的啟動當機。我自己實機測試發現：每日提醒時間錯誤、從提醒回 App 畫面停住、鎖屏媒體卡片沒有暫停／播放鍵、快速按上一個／下一個聲音不同步、關閉 App 後卡片殘留、新的大字模式長片語蓋到按鈕。

---

### 第 2 部分：關於你的 App

#### 4. Who is the intended audience of your app?

EN:
> Adults who have studied English many times without success, especially busy and older learners who have little English in their daily lives. The interface and built-in translations are available in Traditional and Simplified Chinese, Japanese, Korean, Vietnamese, Indonesian, Spanish, Portuguese, Thai and Arabic, with English for all other languages. The app is not designed for children under 13.

中：學了很多次英文卻沒學好的成人，特別是忙碌、年紀漸長、生活中很少接觸英文的人。介面與內建翻譯支援繁中、簡中、日、韓、越、印尼、西、葡、泰、阿，其他語言顯示英文。App 不是為 13 歲以下兒童設計（與隱私權政策一致）。

（2026-10-08 確認：Play Console 目標對象為 16～17 歲與 18 歲以上，與此句一致。）

#### 5. Describe how your app provides value to users.

EN:
> The app teaches high-frequency core vocabulary from openly licensed academic word lists (NGSL, NGSL-Spoken, PHRASE List and PhaVE List; 4,185 items). The NGSL core words cover about 92% of everyday English text. Users learn by listening in the background while commuting, walking or doing chores, with bilingual audio, a difficult-word review list, learning statistics and daily reminders. It works from the lock screen, offers light and dark themes and an adjustable word size, and lets users import their own word lists in 14 languages. All core features work offline and for free; an optional subscription unlocks all words and removes ads.

中：教授高頻核心字彙，來源是公開授權的學術字表（NGSL、NGSL-Spoken、PHRASE List、PhaVE List，共 4,185 項），NGSL 核心字涵蓋日常英文約 92%。使用者在通勤、散步、做家事時背景聆聽學習，有雙語朗讀、不熟悉單字庫、學習統計、每日提醒；可在鎖屏操作，有淺色／深色主題與可調單字大小，可匯入 14 種語言的自訂單字表。核心功能可離線免費使用；訂閱可選，解鎖全部單字並移除廣告。

【確認：「離線」— 內建教材與手機 TTS 可離線朗讀；若你不確定就刪掉 "offline and"。】

#### 6. How many installs do you expect your app to have in your first year?
建議選**最小的區間（0–10,000）**：個人開發、初期只打算小預算投廣告，保守較可信。

---

### 第 3 部分：正式版準備程度

#### 7. What changes did you make to your app based on what you learned during closed testing?

EN:
> I released 9 updates to the closed testing track during the test:
> - Based on tester feedback: added a "Share with friends" option (system share sheet with a localized message and the Play Store link), and added a full English store listing with keywords and English screenshots. I also updated the store names in several languages to include search keywords, so the tester report may still show the earlier name; the package name is unchanged.
> - Fixed a startup crash reported by Crashlytics when the notification permission request failed; permission is now requested only when the user turns on reminders.
> - Daily reminders: added missing notification receivers, fixed a time-zone error that made reminders fire 8 hours early, and fixed the app freezing when opened from a reminder.
> - Lock-screen and notification media card: restored the pause/play/stop buttons (removed by resource shrinking), and the card now disappears when the app is closed.
> - Audio and screen now stay in sync when tapping next/previous quickly.
> - Added the Google consent form for users in the EEA, UK and Switzerland, an "Ad privacy settings" menu item, and an updated bilingual privacy policy.
> - Redesigned the interface (0.3.x): light and dark themes that follow the system, a cleaner home screen focused on the word, adjustable word size, automatic text fitting so long phrases never overlap the buttons, and a clearer daily reminder with "Start listening" and "Remind me later" actions.
> - Added Thai and Arabic (right-to-left), English as the default for unsupported languages, built-in translations that follow the device language, better CSV import, a feature tour, and the final app icon.

中：測試期間發布 9 次更新：
- 依測試者回饋：新增「分享給朋友」（系統分享、在地化訊息＋Play 連結）；新增完整英文商店資訊（關鍵字、英文截圖）；多語商店名稱加入搜尋關鍵字，所以測試報告可能顯示舊名，套件名稱不變。
- 修正 Crashlytics 回報的啟動當機（通知權限請求失敗）；改為使用者開啟提醒時才請求權限。
- 每日提醒：補上通知接收器、修正時區造成提早 8 小時、修正從提醒開 App 畫面停住。
- 鎖屏／通知媒體卡片：恢復暫停／播放／停止按鈕（被資源壓縮移除），關閉 App 後卡片會消失。
- 快速按上一個／下一個時聲音與畫面保持同步。
- 歐洲經濟區、英國、瑞士使用者的 Google 同意表單，「廣告隱私設定」選單，隱私權政策更新為中英雙語。
- 介面改版（0.3.x）：淺色／深色跟隨系統、以單字為主的首頁、單字大小可調、長片語自動縮字不蓋按鈕、每日提醒加「開始朗讀」「稍後提醒」。
- 新增泰文、阿拉伯文（右到左）、不支援語言預設英文、內建翻譯跟隨裝置語言、改善 CSV 匯入、功能導覽、正式圖示。

#### 8. How did you decide that your app is ready for production?

EN:
> All issues found by testers, Crashlytics and my own testing are fixed in the current version (0.3.1), and each fix was verified on a physical device before release. The tester report found no crashes or functional bugs. Firebase Crashlytics shows no crashes in the last 7 days. Core features (background playback, bilingual reading, reminders, CSV import, ads and the subscription) work reliably on the tested devices. The store listing is complete in 11 languages, the privacy policy and data safety form are up to date, and the EU ad consent form is in place.

中：測試者、Crashlytics 與我自己測試發現的問題都已在目前版本（0.3.1）修正，每項修正發布前都在實機確認。測試報告沒有當機或功能錯誤。Firebase Crashlytics 最近 7 天沒有當機。核心功能（背景朗讀、雙語、提醒、CSV 匯入、廣告、訂閱）在測試裝置上穩定運作。11 語商店資訊完整，隱私權政策與資料安全性表單已更新，歐洲廣告同意表單已上線。

【若 Play「正式發布前測試報告」有產生且沒有嚴重問題，可在 Crashlytics 那句後面加：The Play pre-launch report shows no critical issues.】

---

### 送出前你要確認的事

1. ✅ **Crashlytics**：2026-10-08 確認最近 7 天沒有當機。
2. **訂閱實機測試**（HANDOFF §17 A-4）：步驟見 subscription_test_steps.md；通過前不要送出，或先把第 8 題的 "and the subscription" 刪掉。
3. ✅ **目標對象**：16～17 歲、18 歲以上，與第 4 題一致。
4. **安裝數**：第 6 題選最小區間。

### 核准後建立正式版時要確認的事

1. **推哪個版本**：建議第十九版 0.3.1+19（run219）。在封閉測試軌道用「推廣版本 → 正式版」，不必重新上傳；版本資訊沿用 `store_assets/release_notes_v19.md`（11 語，english-app-builds Release run219 頁面可直接複製）。
2. **國家／地區**：建議「所有可用國家／地區」。24 個主要市場的訂閱價格已手動設定，其他自動換算；改價時不要選「套用到所有國家」。
3. **分階段發布**：建議直接 100%（新 App 沒有既有使用者，分階段意義不大）。
4. **控管型發布**：目前關閉，審核通過就自動上線；想自己挑上線時間才需要打開。
5. **上線後**（HANDOFF §17 C-3）：AdMob 連結 Play 商店並看 app-ads.txt 驗證；LC Lab 網站把「即將推出」換成 Play 連結（這個我可以做，上線後說一聲）。

---

## 三、各語言商店截圖清單

**要準備的語言**：繁中、簡中、日、韓、越、印尼、西、葡、泰、阿拉伯（共 10 種；泰、阿為第十一版新增）。每種語言 4 張，同一組畫面。

> 現況：10 語的截圖＋主題圖都已用 `store_assets/generate_localized_assets.py` 產生，在 `store_assets/localized/<lang>/`（泰 `th`、阿拉伯 `ar`，阿拉伯文為右到左鏡像版面），可直接上傳；以下實機截圖流程保留作為日後改用真實畫面時參考。

**截圖前的準備**
1. 手機「設定」→「語言」切換成要截的語言（簡中請選「简体中文（中国）」）。
2. 打開 App，選 **NGSL 2809** 教材，讀取模式設成「雙語」，讓單字下方顯示翻譯。
3. 手機開勿擾模式，讓狀態列乾淨；電量最好是滿的。

**每種語言截這 4 張**
1. **首頁播放中**：正在朗讀一個常見單字（例如 important、remember），畫面有單字、翻譯、播放按鈕。
2. **播放設定展開**：顯示讀取模式、重複次數、速度等設定。
3. **學習統計**：今日學習數、累計、各教材進度（先聽一陣子讓數字不是 0）。
4. **Premium 頁面**：四份教材完整開放、移除廣告等權益。

**上傳位置**：Play Console →「商店資訊」→「主要商店資訊」→ 切換到該語言 → 往下到「圖像」→「手機螢幕截圖」。沒上傳截圖的語言會顯示繁中截圖，所以可以先做使用人數最多的市場（日、韓、越、印尼、西、葡），簡中最後。

**規格**：PNG 或 JPEG，最短邊至少 320px，**長邊不能超過短邊的 2 倍**。注意：小米/Redmi 等較新的手機螢幕是 20:9，直接截圖會超過 2 倍而被拒絕，需要把上下（狀態列、導覽列）裁掉一些，裁成 9:18 或 9:16 即可。
