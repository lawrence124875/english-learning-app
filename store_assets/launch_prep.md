# 智慧聽覺巡航：正式上架前準備

---

## 一、各國訂閱價格建議

**基準**：台灣 月繳 NT$149、年繳 NT$999（年繳約等於 6.7 個月，省 44%）。
**原則**：日、韓維持與台灣相近的價位；東南亞與拉美依當地消費水準調低；價格尾數用當地常見的寫法。Google Play 顯示的價格大多已含當地稅，匯率會變動，調整時以 Play Console 當下顯示的換算為參考。

| 國家／地區 | 幣別 | 月繳建議 | 年繳建議 | 說明 |
|---|---|---|---|---|
| 台灣 | TWD | 149 | 999 | 基準 |
| 香港 | HKD | 38 | 248 | 與台灣相近 |
| 日本 | JPY | 650 | 4,800 | 英語學習付費意願高，維持同等價位 |
| 韓國 | KRW | 6,500 | 44,000 | 同上 |
| 新加坡 | SGD | 5.98 | 39.98 | 高所得市場 |
| 馬來西亞 | MYR | 12.90 | 89.90 | 簡中使用者主要市場 |
| 越南 | VND | 59,000 | 399,000 | 約台灣一半價位 |
| 印尼 | IDR | 35,000 | 249,000 | 約台灣一半價位 |
| 巴西 | BRL | 14,90 | 99,90 | 約台灣六成價位 |
| 墨西哥 | MXN | 59 | 399 | 約台灣七成價位 |
| 哥倫比亞 | COP | 12.900 | 89.900 | 拉美其他國家可比照 |
| 西班牙（歐元區） | EUR | 3,99 | 24,99 | 歐洲價位 |
| 美國（其他國家預設） | USD | 3.99 | 24.99 | 未特別設定的國家參考 |

**在 Play Console 調整的位置**：「透過 Google Play 營利」→「產品」→「訂閱」→ 選方案 →「基本方案」→「價格」→ 逐國修改。月繳、年繳兩個基本方案都要調。

**提醒**
- 調降價格對新訂閱者立即生效；已訂閱的人不受影響。
- 之後有了各國的付費數據，再依轉換率微調。

---

## 二、正式版存取權問卷（草稿）

> 2026-09-29 更新：依第 4～12 版實際修正紀錄改寫。**【 】內要換成實際情況**，尤其測試者回饋一定要依真實收到的內容填，不誇大。大部分修正來自開發者自己在紅米實機測試發現（例如提醒提早 8 小時），問卷如實寫「自己測試發現」即可，Google 並不要求每項都來自測試者。Google 審核人員看英文，用英文回答。

### 第 1 部分：封閉測試

**How easy was it to recruit testers for your app?**
> As an individual developer it was difficult to find enough testers on my own, so I used a tester community service (TestersCommunity) 【and friends/colleagues, if any】. The 15 testers joined through a Google Group and stayed opted in for the whole testing period.

**Describe the engagement you received from testers during your closed test.**
> Testers installed the app and used its core features: background and lock-screen audio playback of English vocabulary, bilingual reading (English followed by the meaning in their language), marking difficult words, learning statistics, daily reminders, and importing custom word lists via CSV. I also tested every build myself on a physical device (Redmi Note 8, Android 11) and released 【9】 updates to the closed testing track during the test. 【Add actual engagement from the TestersCommunity report, e.g., number of testers who sent reports.】

**Provide a summary of the feedback you received from testers. Include how you collected the feedback.**
> Feedback was collected through the tester community's reports, the in-app feedback form (stored in Firebase Firestore), Firebase Crashlytics, and my own daily use on a physical device. 【Summarize the real feedback from TestersCommunity here.】 The most important issues found were: built-in translations and audio not following the device language, daily reminders not appearing at the set time, and the home-screen icon and app name not being set.

### 第 2 部分：關於你的 App

**Who is the intended audience of your app?**
> Adults who have studied English many times without success, especially busy and older learners with little English exposure in daily life. The app interface and built-in translations are available in Traditional and Simplified Chinese, Japanese, Korean, Vietnamese, Indonesian, Spanish, Portuguese, Thai, and Arabic, with English as the default for other languages.

**Describe how your app provides value to users.**
> The app focuses on high-frequency core vocabulary from openly licensed academic word lists (NGSL, NGSL-Spoken, PHRASE List, PhaVE List; 4,185 items in total). The NGSL core words cover about 92% of everyday English text. Users learn by listening in the background while commuting, walking, or doing chores, with bilingual audio, a difficult-word review list, learning statistics, and daily reminders. Users can also import their own study lists in 14 languages.

**How many installs do you expect your app to have in your first year?**
> 【建議選保守區間，例如 1,000–10,000】

### 第 3 部分：正式版準備程度

**What changes did you make to your app based on what you learned during closed testing?**
> During the testing period I released several updates to the closed testing track:
> - Fixed built-in translations and audio not following the device language.
> - Fixed daily reminders: added missing notification receivers, corrected a time-zone calculation that made reminders fire 8 hours early, and used exact alarms with a high-priority channel. Verified on a physical device.
> - Ads: interstitial ads are shown only when the app is in the foreground, with frequency limits between full-screen ads.
> - English is now the default interface for unsupported device languages (previously Chinese).
> - Custom CSV import: users can choose the language of each column (14 languages), headers and different separators are detected, and the app tells users when a text-to-speech voice for that language needs to be installed.
> - Added Thai and Arabic (right-to-left layout), including translations of all 4,185 built-in items.
> - Added an in-app feature tour, with a side-by-side layout in landscape.
> - Added the proper home-screen icon and a localized app name.
> - Earlier updates: in-app update prompts, clearer subscription terms with a "manage subscription" link, and edge-to-edge support.
> - 【Add any changes made in response to TestersCommunity reports.】

**How did you decide that your app is ready for production?**
> Core features (background playback, bilingual reading, reminders, CSV import, subscriptions) work reliably on tested devices, the reminder issue was confirmed fixed on a physical device, Firebase Crashlytics shows 【no major crashes】, the Play pre-launch report shows 【no critical issues】, and all known issues were fixed in the latest version.

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
