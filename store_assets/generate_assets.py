"""
產生 Google Play 上架素材：
- icon.png (512x512)
- screenshot_home.png / screenshot_stats.png / screenshot_paywall.png (1080x2160)
- feature_graphic.png (1024x500)
"""
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import math

FONT_DIR = "/usr/share/fonts/opentype/noto/"

def font(weight, size):
    path = {
        "regular": FONT_DIR + "NotoSansCJK-Regular.ttc",
        "medium": FONT_DIR + "NotoSansCJK-Medium.ttc",
        "bold": FONT_DIR + "NotoSansCJK-Bold.ttc",
        "black": FONT_DIR + "NotoSansCJK-Black.ttc",
    }[weight]
    return ImageFont.truetype(path, size, index=3)  # index 3 = Traditional Chinese face

TEAL_DARK = (11, 94, 86)
TEAL = (13, 148, 136)
TEAL_MID = (45, 168, 157)
TEAL_LIGHT = (170, 224, 216)
TEAL_BG = (240, 249, 248)
WHITE = (255, 255, 255)
INK = (28, 38, 37)
GREY = (117, 128, 126)
GREY_LIGHT = (223, 229, 228)
AMBER = (245, 158, 11)
CARD_BORDER = (228, 234, 233)

def rr(draw, box, radius, **kw):
    draw.rounded_rectangle(box, radius=radius, **kw)

def vgrad(w, h, top, bottom):
    img = Image.new("RGB", (w, h), top)
    px = img.load()
    for y in range(h):
        t = y / max(h - 1, 1)
        r = int(top[0] + (bottom[0] - top[0]) * t)
        g = int(top[1] + (bottom[1] - top[1]) * t)
        b = int(top[2] + (bottom[2] - top[2]) * t)
        for x in range(w):
            px[x, y] = (r, g, b)
    return img

def dgrad(w, h, tl, br):
    """對角漸層"""
    img = Image.new("RGB", (w, h))
    px = img.load()
    maxd = w + h
    for y in range(h):
        for x in range(w):
            t = (x + y) / maxd
            r = int(tl[0] + (br[0] - tl[0]) * t)
            g = int(tl[1] + (br[1] - tl[1]) * t)
            b = int(tl[2] + (br[2] - tl[2]) * t)
            px[x, y] = (r, g, b)
    return img

# ============================================================
# 1. App 圖示 512x512
# ============================================================
def make_icon():
    S = 512
    img = dgrad(S, S, (16, 122, 112), (8, 74, 68)).convert("RGBA")
    draw = ImageDraw.Draw(img)

    # 柔和光暈
    glow = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    gd.ellipse([S*0.15, S*0.05, S*0.95, S*0.75], fill=(255, 255, 255, 28))
    glow = glow.filter(ImageFilter.GaussianBlur(60))
    img = Image.alpha_composite(img, glow)
    draw = ImageDraw.Draw(img)

    cx, cy = S // 2, S // 2 + 8

    # 中央白色圓形耳機/音波底座
    r = 150
    draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(255, 255, 255, 255))

    # 音波等化器長條（teal 色），象徵朗讀/聲音
    bars_h = [70, 130, 95, 150, 60]
    bar_w = 22
    gap = 16
    total_w = len(bars_h) * bar_w + (len(bars_h) - 1) * gap
    start_x = cx - total_w // 2
    for i, h in enumerate(bars_h):
        x0 = start_x + i * (bar_w + gap)
        y0 = cy - h // 2
        rr(draw, [x0, y0, x0 + bar_w, y0 + h], radius=bar_w // 2, fill=TEAL)

    # 外圈耳機弧線
    arc_bbox = [cx - 195, cy - 195, cx + 195, cy + 195]
    draw.arc(arc_bbox, start=200, end=340, fill=(255, 255, 255, 230), width=26)

    img.convert("RGB").save("/home/claude/store_assets/icon.png", "PNG")
    print("icon.png done")

make_icon()

W, H = 1080, 2160

def new_screen(bg=WHITE):
    img = Image.new("RGB", (W, H), bg)
    return img, ImageDraw.Draw(img)

def status_bar(draw, dark_icons=True):
    col = INK if dark_icons else WHITE
    draw.text((44, 26), "9:41", font=font("bold", 30), fill=col)
    draw.rounded_rectangle([970, 30, 1036, 56], radius=6, outline=col, width=3)
    draw.rectangle([974, 34, 1000, 52], fill=col)

def app_bar(draw, title):
    draw.rectangle([0, 84, W, 220], fill=WHITE)
    draw.text((48, 152), title, font=font("bold", 44), fill=INK, anchor="lm")
    icon_y = 152
    for i, cx in enumerate([W - 220, W - 140, W - 60]):
        draw.ellipse([cx - 26, icon_y - 26, cx + 26, icon_y + 26], outline=GREY, width=3)
    draw.line([0, 220, W, 220], fill=CARD_BORDER, width=2)

def chip(draw, x, y, text, selected=False):
    tw = draw.textlength(text, font=font("medium", 30))
    w = int(tw) + 56
    h = 76
    if selected:
        rr(draw, [x, y, x + w, y + h], radius=h // 2, fill=TEAL)
        fg = WHITE
    else:
        rr(draw, [x, y, x + w, y + h], radius=h // 2, outline=GREY_LIGHT, width=3, fill=WHITE)
        fg = INK
    draw.text((x + w // 2, y + h // 2), text, font=font("medium", 30), fill=fg, anchor="mm")
    return w

def button(draw, box, text, filled=True, color=TEAL, text_color=None, icon=None):
    x0, y0, x1, y1 = box
    if filled:
        rr(draw, box, radius=(y1 - y0) // 2, fill=color)
        tc = text_color or WHITE
    else:
        rr(draw, box, radius=(y1 - y0) // 2, outline=color, width=3, fill=WHITE)
        tc = text_color or color
    label = (icon + "  " if icon else "") + text
    draw.text(((x0 + x1) // 2, (y0 + y1) // 2), label, font=font("medium", 32), fill=tc, anchor="mm")

def card(draw, box, radius=32, fill=WHITE, outline=CARD_BORDER):
    rr(draw, box, radius=radius, fill=fill, outline=outline, width=2)

def make_screenshot_home():
    img, draw = new_screen(TEAL_BG)
    status_bar(draw)
    app_bar(draw, "智慧聽覺巡航")

    y = 260
    x = 48
    labels = [("✓ NGSL 2809字", True), ("口語 720字", False), ("高頻語塊 506", False)]
    for text, sel in labels:
        w = chip(draw, x, y, text, sel)
        x += w + 20
    x = 48
    y += 96
    chip(draw, x, y, "片語動詞 150", False)

    card_top = y + 130
    card_box = [48, card_top, W - 48, card_top + 620]
    card(draw, card_box, radius=40)
    inner_x0, inner_x1 = card_box[0] + 56, card_box[2] - 56

    prog_y = card_top + 56
    rr(draw, [inner_x0, prog_y, inner_x1, prog_y + 14], radius=7, fill=GREY_LIGHT)
    prog_w = int((inner_x1 - inner_x0) * 0.33)
    rr(draw, [inner_x0, prog_y, inner_x0 + prog_w, prog_y + 14], radius=7, fill=TEAL)

    word_cy = card_top + 220
    draw.text((W // 2, word_cy), "bill", font=font("black", 96), fill=INK, anchor="mm")
    draw.text((W // 2, word_cy + 90), "帳單", font=font("regular", 44), fill=GREY, anchor="mm")

    btn_y = card_top + 400
    button(draw, [inner_x0, btn_y, inner_x1, btn_y + 96], "開始巡航朗讀", filled=True, icon="▶")
    btn_y2 = btn_y + 120
    button(draw, [inner_x0, btn_y2, inner_x1, btn_y2 + 96], "加入不熟悉單字庫", filled=False, color=AMBER, icon="☆")

    unlock_top = card_box[3] + 32
    unlock_box = [48, unlock_top, W - 48, unlock_top + 260]
    card(draw, unlock_box, radius=32, fill=(255, 249, 230), outline=(250, 220, 150))
    draw.text((unlock_box[0] + 40, unlock_top + 50), "免費版已解鎖 936 / 2809 個項目",
               font=font("bold", 34), fill=INK, anchor="lm")
    bw = (unlock_box[2] - unlock_box[0] - 40 * 3) // 2
    by0 = unlock_top + 120
    button(draw, [unlock_box[0] + 40, by0, unlock_box[0] + 40 + bw, by0 + 96],
           "看廣告 +20", filled=False, color=TEAL, icon="▶")
    button(draw, [unlock_box[0] + 80 + bw, by0, unlock_box[0] + 80 + 2 * bw, by0 + 96],
           "升級 Premium", filled=True, icon="★")

    nav_top = unlock_box[3] + 32
    nav_h = 96
    labels3 = ["上一個", "再讀一次", "下一個"]
    gap = 20
    bw3 = (W - 48 * 2 - gap * 2) // 3
    for i, lb in enumerate(labels3):
        x0 = 48 + i * (bw3 + gap)
        button(draw, [x0, nav_top, x0 + bw3, nav_top + nav_h], lb, filled=False, color=GREY)

    set_top = nav_top + nav_h + 28
    set_box = [48, set_top, W - 48, set_top + 110]
    card(draw, set_box, radius=28)
    draw.text((set_box[0] + 36, set_top + 55), "播放設定", font=font("medium", 34), fill=INK, anchor="lm")
    draw.text((set_box[0] + 36, set_top + 95), "英雙讀・讀2次・0.9x", font=font("regular", 26), fill=GREY, anchor="lm")
    cx2, cy2 = set_box[2] - 40, set_top + 58
    draw.polygon([(cx2 - 12, cy2 - 6), (cx2 + 12, cy2 - 6), (cx2, cy2 + 10)], fill=GREY)

    # 底部手勢列（裝飾）
    gy = set_box[3] + 90
    draw.rounded_rectangle([W // 2 - 68, gy, W // 2 + 68, gy + 8], radius=4, fill=GREY_LIGHT)

    img = img.crop((0, 0, W, gy + 40))
    img.save("/home/claude/store_assets/screenshot_home.png", "PNG")
    print("screenshot_home.png done")

make_screenshot_home()

def stat_card(draw, box, value, unit, label):
    card(draw, box, radius=28)
    cx = (box[0] + box[2]) // 2
    draw.text((cx, box[1] + 90), value, font=font("black", 64), fill=INK, anchor="mm")
    draw.text((cx, box[1] + 150), unit, font=font("regular", 28), fill=GREY, anchor="mm")
    draw.text((cx, box[1] + 200), label, font=font("medium", 30), fill=INK, anchor="mm")

def toggle(draw, box, on=True):
    x0, y0, x1, y1 = box
    h = y1 - y0
    fill = TEAL if on else GREY_LIGHT
    rr(draw, box, radius=h // 2, fill=fill)
    r = h // 2 - 4
    cx = x1 - h // 2 if on else x0 + h // 2
    draw.ellipse([cx - r, y0 + 4, cx + r, y1 - 4], fill=WHITE)

def make_screenshot_stats():
    img, draw = new_screen(TEAL_BG)
    status_bar(draw)
    app_bar(draw, "學習統計")

    top = 260
    gap = 24
    cw = (W - 48 * 2 - gap) // 2
    stat_card(draw, [48, top, 48 + cw, top + 260], "12", "個", "今日已學習")
    stat_card(draw, [48 + cw + gap, top, 48 + cw + gap + cw, top + 260], "1,248", "個", "累計已學習")

    # NGSL 進度卡
    ngsl_top = top + 260 + 32
    ngsl_box = [48, ngsl_top, W - 48, ngsl_top + 420]
    card(draw, ngsl_box, radius=32)
    ix0, ix1 = ngsl_box[0] + 48, ngsl_box[2] - 48
    draw.text((ix0, ngsl_top + 56), "NGSL 2809 核心單字進度", font=font("bold", 34), fill=INK, anchor="lm")

    pbar_y = ngsl_top + 120
    rr(draw, [ix0, pbar_y, ix1, pbar_y + 20], radius=10, fill=GREY_LIGHT)
    pw = int((ix1 - ix0) * (1248 / 2809))
    rr(draw, [ix0, pbar_y, ix0 + pw, pbar_y + 20], radius=10, fill=TEAL)
    draw.text((ix0, pbar_y + 60), "1,248 / 2,809 個項目", font=font("regular", 30), fill=GREY, anchor="lm")

    note = "根據 NGSL 官方研究，完整學會這 2,809 個核心單字，可達到一般日常英文文本約 92% 的理解涵蓋率。"
    # 簡單換行
    words = list(note)
    line = ""
    ly = pbar_y + 130
    max_w = ix1 - ix0
    nf = font("regular", 26)
    for ch in words:
        test = line + ch
        if draw.textlength(test, font=nf) > max_w:
            draw.text((ix0, ly), line, font=nf, fill=GREY, anchor="lm")
            ly += 42
            line = ch
        else:
            line = test
    if line:
        draw.text((ix0, ly), line, font=nf, fill=GREY, anchor="lm")

    # 每日複習提醒卡
    rem_top = ngsl_box[3] + 32
    rem_box = [48, rem_top, W - 48, rem_top + 300]
    card(draw, rem_box, radius=32)
    rx0, rx1 = rem_box[0] + 48, rem_box[2] - 48
    draw.text((rx0, rem_top + 56), "每日複習提醒", font=font("bold", 34), fill=INK, anchor="lm")

    row1_y = rem_top + 130
    draw.text((rx0, row1_y), "開啟每日提醒", font=font("regular", 32), fill=INK, anchor="lm")
    toggle(draw, [rx1 - 110, row1_y - 28, rx1, row1_y + 28], on=True)

    row2_y = rem_top + 220
    draw.text((rx0, row2_y), "提醒時間", font=font("regular", 32), fill=INK, anchor="lm")
    draw.text((rx1, row2_y), "20:00", font=font("medium", 32), fill=TEAL, anchor="rm")

    gy = rem_box[3] + 90
    draw.rounded_rectangle([W // 2 - 68, gy, W // 2 + 68, gy + 8], radius=4, fill=GREY_LIGHT)
    img = img.crop((0, 0, W, gy + 40))
    img.save("/home/claude/store_assets/screenshot_stats.png", "PNG")
    print("screenshot_stats.png done")

make_screenshot_stats()

def make_feature_graphic():
    FW, FH = 1024, 500
    img = dgrad(FW, FH, (14, 116, 106), (9, 82, 75)).convert("RGBA")
    draw = ImageDraw.Draw(img)

    # 裝飾音波（右側大型，半透明）
    import random
    random.seed(7)
    bar_area_x0 = 660
    bars = 22
    bw = 14
    gap = 10
    for i in range(bars):
        x0 = bar_area_x0 + i * (bw + gap)
        h = 40 + int(180 * abs(math.sin(i * 0.7)))
        y0 = FH // 2 - h // 2
        alpha = 70
        overlay = Image.new("RGBA", (FW, FH), (0, 0, 0, 0))
        od = ImageDraw.Draw(overlay)
        od.rounded_rectangle([x0, y0, x0 + bw, y0 + h], radius=bw // 2, fill=(255, 255, 255, alpha))
        img = Image.alpha_composite(img, overlay)
    draw = ImageDraw.Draw(img)

    # 左側圖示徽章
    badge_r = 110
    bx, by = 150, FH // 2
    draw.ellipse([bx - badge_r, by - badge_r, bx + badge_r, by + badge_r], fill=(255, 255, 255, 255))
    bars_h = [40, 74, 54, 86, 34]
    bar_w = 13
    bgap = 10
    total_w = len(bars_h) * bar_w + (len(bars_h) - 1) * bgap
    sx = bx - total_w // 2
    for i, h in enumerate(bars_h):
        x0 = sx + i * (bar_w + bgap)
        y0 = by - h // 2
        rr(draw, [x0, y0, x0 + bar_w, y0 + h], radius=bar_w // 2, fill=TEAL)
    arc_bbox = [bx - 140, by - 140, bx + 140, by + 140]
    draw.arc(arc_bbox, start=200, end=340, fill=(255, 255, 255, 230), width=16)

    # 文字
    draw.text((300, 170), "智慧聽覺巡航", font=font("black", 72), fill=WHITE, anchor="lm")
    draw.text((300, 250), "NGSL・口語・語塊・片語動詞", font=font("medium", 34), fill=(220, 245, 242), anchor="lm")
    draw.text((300, 320), "背景朗讀學英語，通勤運動不間斷", font=font("regular", 30), fill=(220, 245, 242), anchor="lm")

    img.convert("RGB").save("/home/claude/store_assets/feature_graphic.png", "PNG")
    print("feature_graphic.png done")

make_feature_graphic()
