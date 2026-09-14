# Firestore 設定：使用者意見回饋

App 內建的「意見回饋」功能會把使用者填寫的內容寫進 Cloud Firestore 的
`feedback` 集合。這個功能使用 Firestore（不是 Firebase Storage），
**不需要升級 Blaze 方案**，免費的 Spark 方案本身就有 Firestore 額度
（每天 50,000 次讀取、20,000 次寫入，對這個用途來說非常夠用）。

## 需要你做的兩件事

### 1. 在 Firebase 後台啟用 Firestore

1. 前往 https://console.firebase.google.com ，選你的專案
2. 左側選單找「Firestore Database」→「建立資料庫」
3. 選一個離台灣近的地區（例如 `asia-east1`，台灣）
4. 安全規則先選「以測試模式啟動」也可以，但**強烈建議**接著做下面第 2 步，
   把規則換成正式版本，避免任何人都能讀到所有使用者的回饋內容

### 2. 設定安全規則（保護使用者隱私）

在 Firestore 後台的「規則」分頁，把內容換成：

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /feedback/{feedbackId} {
      // 允許任何人「新增」一筆回饋（App 送出意見時用）
      allow create: if true;
      // 不允許任何人從 App 端讀取、修改、刪除別人的回饋內容，
      // 只有你自己在 Firebase 後台看得到全部內容
      allow read, update, delete: if false;
    }
  }
}
```

這樣設定的意思：使用者可以「送出」回饋，但沒有人能透過 App
反過來讀取、竄改、刪除任何一筆回饋紀錄——只有你自己登入 Firebase
後台才看得到完整清單。

## 怎麼查看使用者的回饋

前往 Firebase 後台 →「Firestore Database」→「資料」分頁 →
點 `feedback` 集合，就能看到每一筆回饋（內容、類型、聯絡信箱、
App 版本、送出時間）。
