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

封閉測試期滿後，Play Console 會出現「申請正式版存取權」，需要回答測試過程的問題。Google 審核人員看的是英文，建議用英文回答。以下草稿中 **【 】的部分要換成實際情況**，尤其是測試回饋，一定要依照真實收到的內容填寫，不要誇大。

### 第 1 部分：封閉測試

**How easy was it to recruit testers for your app?**
> It was moderately difficult to recruit enough testers on my own as an individual developer, so I used a tester community service (TestersCommunity) in addition to 【friends and colleagues】. All 15 testers joined through a Google Group and stayed opted in for the full testing period.

**Describe the engagement you received from testers during your closed test.**
> Testers installed the app and used its core features: background audio playback of English vocabulary, bilingual (English + native-language) reading, marking difficult words, learning statistics, daily reminders, and importing custom word lists via CSV. 【Summarize actual engagement, e.g., how many testers submitted reports or feedback.】

**Provide a summary of the feedback you received from testers. Include how you collected the feedback.**
> Feedback was collected through the tester community's reports, the in-app feedback form (stored in Firebase Firestore), and 【direct messages from friends】. Main feedback: 【fill in from the TestersCommunity reports, e.g., UI text cut off in some languages, translations not following device language, suggestions on playback settings】.

### 第 2 部分：關於你的 App

**Who is the intended audience of your app?**
> Adults who have studied English many times without success, especially busy learners and older learners with little English exposure in daily life. The app is available in Traditional and Simplified Chinese, Japanese, Korean, Vietnamese, Indonesian, Spanish, and Portuguese.

**Describe how your app provides value to users.**
> The app focuses on high-frequency core vocabulary based on published academic research (NGSL 2809, NGSL-Spoken 720, PHRASE List, PhaVE List). Mastering the NGSL core words covers about 92% of everyday English text. Users can learn by listening in the background while commuting, walking, or doing chores, with bilingual audio (English followed by the meaning in their native language), a difficult-word review list, learning statistics, and daily reminders. Users can also import their own study materials.

**How many installs do you expect your app to have in your first year?**
> 【建議選較保守的區間，例如 1,000–10,000】

### 第 3 部分：正式版準備程度

**What changes did you make to your app based on what you learned during closed testing?**
> During the testing period I released several updates:
> - Added custom study material import (CSV) with clear error messages
> - Added interface and content translations for 8 languages, and fixed an issue where built-in translations and audio did not follow the device language
> - Fixed layout issues so long app titles display fully, and added edge-to-edge support for Android 15
> - Added in-app update prompts and clearer subscription terms with a "manage/cancel subscription" link
> - 【Add changes made in response to actual tester reports】

**How did you decide that your app is ready for production?**
> All core features worked reliably across testers' devices, background playback and notifications were stable, crash reports in Firebase Crashlytics showed 【no major crashes】, and all issues found during testing were fixed in the latest version.

---

## 三、各語言商店截圖清單

**要準備的語言**：繁中、簡中、日、韓、越、印尼、西、葡（共 8 種）。每種語言截 4 張，同一組畫面。

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
