"""
把 store_screenshots_test.dart 渲染的原始畫面（build/store_screenshots/<lang>/raw_*.png）
補上狀態列（9:41、訊號、電池）與底部手勢列，輸出到 store_assets/localized/<lang>/。
執行：python3 tool/store_screenshots/compose.py [語言...]（在 repo 根目錄；不給語言＝全部）
"""
import os, sys
from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
RAW = os.path.join(ROOT, "build", "store_screenshots")
OUT = os.path.join(ROOT, "store_assets", "localized")
FLUTTER = os.environ.get("FLUTTER_ROOT", "/home/claude/flutter")
FONT = os.path.join(FLUTTER, "bin/cache/artifacts/material_fonts/Roboto-Medium.ttf")
NAMES = ["1_home", "2_dark", "3_settings", "4_intro", "5_stats"]
DPR = 2.625
ALL = ["zh", "ja", "ko", "vi", "id", "zh_Hans", "es", "pt", "th", "ar", "en"]


def compose(src, dst):
    img = Image.open(src).convert("RGB")
    W, H = img.size
    r, g, b = img.getpixel((W // 2, 10))
    dark = (0.299 * r + 0.587 * g + 0.114 * b) < 128
    ink = (236, 242, 238) if dark else (30, 38, 34)
    d = ImageDraw.Draw(img)
    top = int(24 * DPR)
    cy = top // 2 + 2
    d.text((int(16 * DPR), cy), "9:41", font=ImageFont.truetype(FONT, 38), fill=ink, anchor="lm")
    # 訊號（4 格）
    x = W - 200
    for i in range(4):
        h = 10 + i * 7
        d.rectangle([x + i * 12, cy + 13 - h, x + i * 12 + 7, cy + 13], fill=ink)
    # 電池
    x = W - 120
    d.rounded_rectangle([x, cy - 13, x + 52, cy + 13], radius=5, outline=ink, width=3)
    d.rectangle([x + 52, cy - 5, x + 57, cy + 5], fill=ink)
    d.rectangle([x + 6, cy - 7, x + 40, cy + 7], fill=ink)
    # 手勢列
    bot = int(16 * DPR)
    d.rounded_rectangle([W // 2 - 140, H - bot // 2 - 6, W // 2 + 140, H - bot // 2 + 6],
                        radius=6, fill=(ink[0], ink[1], ink[2]) if dark else (60, 66, 62))
    img.save(dst, "PNG", optimize=True)


for lang in (sys.argv[1:] or ALL):
    od = os.path.join(OUT, lang)
    os.makedirs(od, exist_ok=True)
    for old in ["1_home.png", "2_intro.png", "3_stats.png", "4_paywall.png"]:
        p = os.path.join(od, old)
        if os.path.exists(p): os.remove(p)
    for n in NAMES:
        compose(os.path.join(RAW, lang, f"raw_{n}.png"), os.path.join(od, f"{n}.png"))
    print(lang, "done")
