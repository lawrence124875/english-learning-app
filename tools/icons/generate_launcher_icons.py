"""產生 App 安裝後的桌面圖示（Android 各密度＋自適應圖示、iOS 1024）。
圖案與 store_assets/generate_assets.py 的商店圖示相同，只是分層、高解析度繪製。
輸出到 tools/icons/out/，CI 由 scripts/patch_android_icons.sh、patch_ios.sh 複製進專案。
執行：python3 tools/icons/generate_launcher_icons.py
"""
from PIL import Image, ImageDraw, ImageFilter
import os

TEAL = (13, 148, 136)
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "out")

def background(S):
    """對角漸層＋柔和光暈（同商店圖示）。"""
    tl, br = (16, 122, 112), (8, 74, 68)
    grad = Image.linear_gradient("L").rotate(45, expand=True).resize((S * 2, S * 2))
    grad = grad.crop((S // 2, S // 2, S // 2 + S, S // 2 + S))
    img = Image.merge("RGB", [grad.point(lambda v, a=a, b=b: int(a + (b - a) * v / 255)) for a, b in zip(tl, br)]).convert("RGBA")
    glow = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    ImageDraw.Draw(glow).ellipse([S*0.15, S*0.05, S*0.95, S*0.75], fill=(255, 255, 255, 28))
    glow = glow.filter(ImageFilter.GaussianBlur(S * 60 / 512))
    return Image.alpha_composite(img, glow)

def artwork(S, scale):
    """白色圓＋音波＋耳機弧線，scale=1 時與 512 商店圖示比例相同。透明底。"""
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    k = S / 512 * scale
    cx, cy = S / 2, S / 2 + 8 * k
    r = 150 * k
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(255, 255, 255, 255))
    bars_h = [70, 130, 95, 150, 60]
    bw, gap = 22 * k, 16 * k
    x = cx - (len(bars_h) * bw + (len(bars_h) - 1) * gap) / 2
    for h in bars_h:
        h *= k
        d.rounded_rectangle([x, cy - h / 2, x + bw, cy + h / 2], radius=bw / 2, fill=TEAL + (255,))
        x += bw + gap
    R = 195 * k
    d.arc([cx - R, cy - R, cx + R, cy + R], start=200, end=340, fill=(255, 255, 255, 230), width=max(1, round(26 * k)))
    return img

def full_icon(S):
    return Image.alpha_composite(background(S), artwork(S, 1.0))

def save(img, *path):
    p = os.path.join(OUT, *path)
    os.makedirs(os.path.dirname(p), exist_ok=True)
    img.save(p, "PNG")

BIG = 1024
# iOS：1024 不透明
save(full_icon(BIG).convert("RGB"), "ios", "icon_1024.png")

# Android 舊式圖示（Android 7 以下與部分啟動器）
legacy = full_icon(BIG)
dens = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}
for d, m in dens.items():
    save(legacy.resize((int(48 * m),) * 2, Image.LANCZOS), "android", f"mipmap-{d}", "ic_launcher.png")

# Android 8+ 自適應圖示：108dp 畫布，安全區直徑 66dp。
# 商店圖示的圖案（耳機弧線外緣）約佔 512 的 81%，縮到 108dp 畫布約 58%，完整落在安全區內。
AD = 432 * 3
bg = background(AD)
fg = artwork(AD, 0.72)
for d, m in dens.items():
    n = int(108 * m)
    save(bg.resize((n, n), Image.LANCZOS).convert("RGB"), "android", f"mipmap-{d}", "ic_launcher_background.png")
    save(fg.resize((n, n), Image.LANCZOS), "android", f"mipmap-{d}", "ic_launcher_foreground.png")

xml = '''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@mipmap/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
'''
p = os.path.join(OUT, "android", "mipmap-anydpi-v26", "ic_launcher.xml")
os.makedirs(os.path.dirname(p), exist_ok=True)
open(p, "w").write(xml)

# 預覽（圓形遮罩模擬 Pixel 啟動器）
prev = Image.alpha_composite(bg, fg).resize((432, 432), Image.LANCZOS)
mask = Image.new("L", (432, 432), 0)
ImageDraw.Draw(mask).ellipse([0, 0, 431, 431], fill=255)
circ = Image.new("RGBA", (432, 432), (255, 255, 255, 0)); circ.paste(prev, (0, 0), mask)
canvas = Image.new("RGB", (432 * 2 + 30, 432), (230, 230, 230))
canvas.paste(full_icon(432).convert("RGB"), (0, 0)); canvas.paste(circ, (462, 0), circ)
canvas.save("/tmp/icon_preview.png")
print("done")
