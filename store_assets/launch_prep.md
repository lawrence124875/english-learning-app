# 智慧聽覺巡航：正式上架前準備

---

## 一、各國訂閱價格（2026-09-29 已在 Play Console 手動設定）

依據：各國 Netflix 標準方案月費、Duolingo 與在地單字 App 價格比較（對話 2026-09-29）。調整前的全部價格見 `current_prices_2026-09-29.csv`（Google 自動換算，基準約 US$4.69／31.99）。

| 市場 | 月繳 | 年繳 | 調整前（月／年） |
|---|---|---|---|
| 台灣 | NT$149 | NT$999 | 160／1,050 |
| 香港 | HK$38 | HK$248 | 未變 |
| 日本 | ¥650 | ¥4,800 | 820／5,500 |
| 韓國 | ₩6,500 | ₩44,000 | 7,000／47,000 |
| 新加坡 | S$6.49 | S$43.98 | 未變 |
| 馬來西亞 | RM12.90 | RM89.90 | 20.99／139.99 |
| 越南 | ₫59,000 | ₫399,000 | 122,000／820,000 |
| 印尼 | Rp35,000 | Rp249,000 | 84,000／590,000 |
| 泰國 | ฿99 | ฿690 | 175／1,125 |
| 巴西 | R$14.90 | R$99.90 | 23.99／159.99 |
| 墨西哥 | MX$69 | MX$469 | 95／629 |
| 哥倫比亞 | COP 9,900 | COP 69,900 | 15,000／101,000 |
| 美國 | US$4.99 | US$34.99 | 4.69／31.99 |
| 歐元區 | 未變（€4.89～4.99） | 未變（€32.99～34.99） | |
| 沙烏地 | SAR 14.99 | SAR 99.99 | 19.99／134.99 |
| 阿聯 | AED 14.99 | AED 99.99 | 17.99／119.99 |
| 埃及 | EGP 59 | EGP 399 | 279.99／1,849.99 |
| 印度 | ₹149 | ₹999 | 520／3,550 |
| 巴基斯坦 | PKR 299 | PKR 1,990 | 1,300／8,700 |
| 奈及利亞 | NGN 1,990 | NGN 12,990 | 6,710／45,000 |
| 土耳其 | TRY 89.99 | TRY 599.99 | 274.99／1,849.99 |
| 菲律賓 | ₱149 | ₱990 | 330／2,200 |
| 肯亞 | KES 249 | KES 1,690 | 700／4,700 |
| 孟加拉 | BDT 299 | BDT 1,990 | 650／4,500 |

其餘國家（含「其他國家/地區」USD／EUR 群組）維持 Google 自動換算價，等有各國付費數據再調。若 Console 因最低價限制改填了別的數字，以 Console 實際為準。

**注意**：之後若在 Console 改價格，**不要**選「套用到所有國家／依匯率更新所有國家」，會把上表手動價格覆蓋掉；只改要改的國家。

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
