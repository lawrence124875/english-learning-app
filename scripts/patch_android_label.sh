#!/usr/bin/env bash
# 桌面上 App 名稱：flutter create 預設是 android:label="english_learning_app"。
# 依 lib/l10n/app_*.arb 的 appTitle 產生各語言 strings.xml（app_name），
# 並把 manifest 的 label 改成 @string/app_name，手機語言不同就顯示不同名稱。
set -euo pipefail
python3 <<'PY'
import json, os, re, html
RES = "android/app/src/main/res"
# arb 檔名 → Android 資源資料夾（values = 不支援語言時的預設，跟 App 介面一樣用英文）
MAP = {
    "en": ["values"],
    "zh": ["values-zh", "values-zh-rTW", "values-zh-rHK", "values-zh-rMO"],
    "zh_Hans": ["values-zh-rCN", "values-zh-rSG", "values-b+zh+Hans"],
    "ja": ["values-ja"], "ko": ["values-ko"], "vi": ["values-vi"],
    "id": ["values-in", "values-id"], "es": ["values-es"], "pt": ["values-pt"],
    "th": ["values-th"], "ar": ["values-ar"],
}
for key, dirs in MAP.items():
    arb = f"lib/l10n/app_{key}.arb"
    if not os.path.exists(arb):
        print("略過（找不到）", arb); continue
    name = json.load(open(arb, encoding="utf-8"))["appTitle"]
    val = html.escape(name, quote=False).replace("'", "\\'")
    for d in dirs:
        os.makedirs(f"{RES}/{d}", exist_ok=True)
        p = f"{RES}/{d}/strings.xml"
        with open(p, "w", encoding="utf-8") as f:
            f.write(f'<?xml version="1.0" encoding="utf-8"?>\n<resources>\n    <string name="app_name">{val}</string>\n</resources>\n')
    print(key, "→", name)
m = "android/app/src/main/AndroidManifest.xml"
s = open(m, encoding="utf-8").read()
s2 = re.sub(r'android:label="[^"]*"', 'android:label="@string/app_name"', s, count=1)
assert 'android:label="@string/app_name"' in s2, "manifest 找不到 android:label"
open(m, "w", encoding="utf-8").write(s2)
print("manifest label 已改為 @string/app_name")
PY
