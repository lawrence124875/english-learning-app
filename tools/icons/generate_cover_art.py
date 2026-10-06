"""0.3.1 鎖屏／通知卡片封面（無文字）。
cover_plain.png：鼠尾草綠放射漸層（一般手機，封面當卡片背景）。
cover_logo.png：同底色＋App 圖示（小米 MIUI 把封面當右側縮圖）。
執行：python3 tools/icons/generate_cover_art.py（需先有 tools/icons/out）
"""
from PIL import Image, ImageDraw
import os
HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "..", "..", "assets", "cover")
S = 512
def plain():
    im = Image.new("RGB", (S, S), "#5B8A72"); d = ImageDraw.Draw(im)
    for r in range(int(S * 0.9), 0, -2):
        t = r / (S * 0.9)
        c = tuple(int(a * t + b * (1 - t)) for a, b in zip((0x5B, 0x8A, 0x72), (0x6E, 0x9C, 0x84)))
        d.ellipse((S / 2 - r, S * 0.4 - r, S / 2 + r, S * 0.4 + r), fill=c)
    return im
def logo():
    fg = Image.open(os.path.join(HERE, "out/android/mipmap-xxxhdpi/ic_launcher_foreground.png")).convert("RGBA")
    im = plain().convert("RGBA"); f = fg.resize((int(S * 0.9), int(S * 0.9)), Image.LANCZOS)
    im.alpha_composite(f, ((S - f.width) // 2, (S - f.height) // 2))
    return im.convert("RGB")
os.makedirs(OUT, exist_ok=True)
plain().save(os.path.join(OUT, "cover_plain.png"), optimize=True)
logo().save(os.path.join(OUT, "cover_logo.png"), optimize=True)
