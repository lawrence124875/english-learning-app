# 英文（en-US）商店資訊（2026-09-30，依 TestersCommunity 回饋新增）

TestersCommunity 回饋「商店說明文字與關鍵字不足」：原因是一直沒有英文商店資訊，測試者與 Google 審核人員看到的是繁中預設頁或機器翻譯。

**新增方式**：Play Console →「發布」→「商店資訊」→「主要商店資訊」→ 右上「管理翻譯」→「新增自己的翻譯」→ 勾選 **English (United States) – en-US** → 在語言選單切到 en-US，貼上下方內容、上傳 `store_assets/localized/en/` 的截圖與主題圖 → 儲存 → 送審。

注意：英文商店資訊寫明「10 種語言可雙語朗讀，其他語言只念英文」，與 App 行為一致（英文介面不顯示內建教材翻譯），不誇大。

## App 名稱（26/30）

```
Smart English Audio Cruise
```

## 簡短說明（76/80）

```
Learn core English vocabulary by listening: 92% of daily English, hands-free
```

## 完整說明（3360/4000）

```
Smart English Audio Cruise is for everyone who has studied English many times but never quite made it stick.

If you have bought course after course and downloaded app after app, only to give up halfway, the problem may not be you. It may be that your study time was never spent on the words that really matter.

📐 The 80/20 rule: learn the words that do most of the work
Research on word frequency shows that a small group of core, high-frequency words makes up most of the English we meet every day. The 2,809 words of the NGSL (New General Service List) cover about 92% of everyday English text. You don't need to memorize tens of thousands of words: focus on the core vocabulary that keeps coming back, and you get most of the understanding.

🎯 Made for learners like you
• Busy adults who have no time to waste on rare words they will never use
• Older learners who find memorizing harder than it used to be
• People with no English around them in daily life, who need repeated listening to build familiarity
• Anyone who has tried many methods and wants a simple way to start again

🎧 Hands-free background listening
No need to stare at the screen. Listen while you commute, walk, cook, clean, or work out. Playback continues with the screen locked or while you use other apps, and the notification shows the current word. Adjust repetitions, speaking speed, and the pause between words to suit your level.

🌏 Bilingual listening in 10 languages
If your phone is set to Traditional or Simplified Chinese, Japanese, Korean, Vietnamese, Indonesian, Spanish, Portuguese, Thai, or Arabic, the app can read each English word followed by its meaning in your language. In other languages, the interface is in English and the built-in lists are read in English only.

⭐ Review the words you don't know yet
Hearing a word once is not enough. Mark unfamiliar words with a star and replay just those, again and again, until they move into long-term memory.

📚 Four research-based word lists (4,185 items)
★ NGSL 2809 – core vocabulary covering about 92% of everyday English text
★ NGSL-Spoken 720 – the most frequent words in spoken English
★ PHRASE List 506 – high-frequency multi-word expressions
★ PhaVE List 150 – the most common phrasal verbs, a classic headache for learners
All lists come from openly licensed academic research; sources are credited in the app's About page.

📥 Import your own lists in 14 languages
Turn your own vocabulary notes, textbook words, or work phrases into a CSV file and listen to them in the background, just like the built-in lists. Reading is supported in 14 languages: English, Traditional and Simplified Chinese, Japanese, Korean, Vietnamese, Indonesian, Spanish, Portuguese, French, German, Italian, Thai, and Arabic, with a translation column in the language you know best. (Some languages require downloading a text-to-speech voice in your phone settings first.)

📊 Progress stats and daily reminders
See how many words you learned today and in total, and track your progress through the NGSL core words. Set a daily reminder to build a steady study habit.

🎁 Free to start
A large part of every word list is free. Watch a short ad to unlock more, or upgrade to Premium to unlock all content and remove ads.

Audio is read by your phone's built-in text-to-speech engine.
```

## 圖片（store_assets/localized/en/）

- 主題圖：`feature_graphic.png`（1024×500）
- 手機截圖：`1_home.png`、`2_intro.png`、`3_stats.png`、`4_paywall.png`（依序上傳）
- 產生方式：`python3 store_assets/generate_localized_assets.py en`（英文單字卡下方不顯示翻譯、朗讀模式顯示「Word only」，與英文介面實際畫面一致）
