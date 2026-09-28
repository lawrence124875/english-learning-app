#!/usr/bin/env bash
# 桌面上的 App 名稱：依手機語言顯示 ARB 的 appTitle（flutter create 預設是 english_learning_app）。
# 產生 res/values-*/strings.xml 的 app_name，並把 AndroidManifest 的 android:label 改成 @string/app_name。
set -euo pipefail
python3 - <<'PY'
import json, os, re
from xml.sax.saxutils import escape
RES = "android/app/src/main/res"
# ARB 檔 → Android 資源資料夾（values 是找不到語言時的預設＝英文）
m = {
  "en": ["values", "values-en"],
  "zh": ["values-zh", "values-zh-rTW", "values-zh-rHK", "values-zh-rMO", "values-b+zh+Hant"],
  "zh_Hans": ["values-zh-rCN", "values-zh-rSG", "values-b+zh+Hans"],
  "ja": ["values-ja"], "ko": ["values-ko"], "vi": ["values-vi"],
  "id": ["values-in", "values-id"], "es": ["values-es"], "pt": ["values-pt"],
  "th": ["values-th"], "ar": ["values-ar"],
}
for arb, dirs in m.items():
    title = json.load(open(f"lib/l10n/app_{arb}.arb", encoding="utf-8"))["appTitle"]
    val = escape(title).replace("'", "\\'").replace('"', '\\"')
    for d in dirs:
        os.makedirs(f"{RES}/{d}", exist_ok=True)
        p = f"{RES}/{d}/strings.xml"
        xml = open(p, encoding="utf-8").read() if os.path.exists(p) else '<?xml version="1.0" encoding="utf-8"?>\n<resources>\n</resources>\n'
        xml = re.sub(r'\s*<string name="app_name">.*?</string>', '', xml, flags=re.S)
        xml = xml.replace("</resources>", f'    <string name="app_name">{val}</string>\n</resources>')
        open(p, "w", encoding="utf-8").write(xml)
    print(arb, "→", title)
man = "android/app/src/main/AndroidManifest.xml"
s = open(man, encoding="utf-8").read()
s2 = re.sub(r'android:label="[^"]*"', 'android:label="@string/app_name"', s, count=1)
assert 'android:label="@string/app_name"' in s2, "找不到 android:label"
open(man, "w", encoding="utf-8").write(s2)
print("AndroidManifest android:label → @string/app_name")
PY
