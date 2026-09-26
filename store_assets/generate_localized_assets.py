"""
產生各語言（含繁中）的 Google Play 截圖與主題圖（feature graphic）。
文字直接讀取 lib/l10n/app_<lang>.arb，確保與 App 內用語一致。
輸出：store_assets/localized/<lang>/
  1_home.png、2_intro.png、3_stats.png、4_paywall.png、feature_graphic.png
執行：python3 store_assets/generate_localized_assets.py（在 repo 根目錄）
"""
import json, os, re
from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "store_assets", "localized")
FONT_DIR = "/usr/share/fonts/opentype/noto/"

# Noto Sans CJK 的 face index：0=日 1=韓 2=簡中 3=繁中。拉丁語系用日文 face（含越南文字母）。
FACE = {"zh": 3, "ja": 0, "ko": 1, "zh_Hans": 2, "vi": 0, "id": 0, "es": 0, "pt": 0}
CJK = {"zh", "ja", "zh_Hans"}  # 逐字換行；韓文有空格，照單字換行

# ARB 沒有的少量文字
EXTRA = {
    "zh": dict(word="帳單", best="最划算",
               fg1="NGSL・口語・語塊・片語動詞", fg2="背景朗讀學英語，通勤運動不間斷"),
    "zh_Hans": dict(word="账单", best="最划算",
                    fg1="NGSL・口语・语块・短语动词", fg2="后台朗读学英语，通勤运动不间断"),
    "ja": dict(word="請求書", best="いちばんお得",
               fg1="NGSL・話し言葉・フレーズ・句動詞", fg2="聞き流しで英語学習。通勤中も運動中も"),
    "ko": dict(word="청구서", best="가장 경제적",
               fg1="NGSL · 구어 · 어구 · 구동사", fg2="백그라운드 낭독으로 출퇴근·운동 중에도 영어 공부"),
    "vi": dict(word="hóa đơn", best="Tiết kiệm nhất",
               fg1="NGSL · Văn nói · Cụm từ · Cụm động từ", fg2="Nghe nền học tiếng Anh, cả khi đi làm lẫn tập thể dục"),
    "id": dict(word="tagihan", best="Paling hemat",
               fg1="NGSL · Lisan · Frasa · Phrasal verb", fg2="Belajar bahasa Inggris sambil dengar, saat perjalanan atau olahraga"),
    "es": dict(word="factura", best="Más conveniente",
               fg1="NGSL · Habla · Expresiones · Phrasal verbs", fg2="Aprende inglés escuchando, en el trayecto o haciendo deporte"),
    "pt": dict(word="conta", best="Mais vantajoso",
               fg1="NGSL · Fala · Expressões · Phrasal verbs", fg2="Aprenda inglês ouvindo, no trajeto ou malhando"),
}

TEAL = (13, 148, 136); TEAL_BG = (240, 249, 248); TEAL_LIGHT_BG = (224, 246, 242)
WHITE = (255, 255, 255); INK = (28, 38, 37); GREY = (117, 128, 126)
GREY_LIGHT = (223, 229, 228); AMBER = (245, 158, 11); CARD_BORDER = (228, 234, 233)
W, H = 1080, 2160

LANG = None
def font(weight, size):
    name = {"regular": "Regular", "medium": "Medium", "bold": "Bold", "black": "Black"}[weight]
    return ImageFont.truetype(f"{FONT_DIR}NotoSansCJK-{name}.ttc", size, index=FACE[LANG])

def fit_font(draw, text, weight, size, max_w, min_size=18):
    while size > min_size and draw.textlength(text, font=font(weight, size)) > max_w:
        size -= 1
    return font(weight, size)

def wrap(draw, text, fnt, max_w):
    tokens = list(text) if LANG in CJK else re.split(r"(\s+)", text)
    lines, line = [], ""
    for t in tokens:
        test = line + t
        if line and draw.textlength(test.strip(), font=fnt) > max_w:
            lines.append(line.strip()); line = t.lstrip()
        else:
            line = test
    if line.strip(): lines.append(line.strip())
    return lines

def rr(d, box, radius, **kw): d.rounded_rectangle(box, radius=radius, **kw)
def card(d, box, radius=32, fill=WHITE, outline=CARD_BORDER): rr(d, box, radius, fill=fill, outline=outline, width=2)

def status_bar(d):
    d.text((44, 26), "9:41", font=font("bold", 30), fill=INK)
    d.rounded_rectangle([970, 30, 1036, 56], radius=6, outline=INK, width=3)
    d.rectangle([974, 34, 1000, 52], fill=INK)

def app_bar(d, title, back=False, icons=True):
    d.rectangle([0, 84, W, 220], fill=WHITE)
    x = 48
    if back:
        d.polygon([(80, 132), (56, 152), (80, 172)], fill=INK); x = 110
    max_w = (W - 270 - x) if icons else (W - 60 - x)
    d.text((x, 152), title, font=fit_font(d, title, "bold", 44, max_w), fill=INK, anchor="lm")
    if icons:
        for cx in [W - 220, W - 140, W - 60]:
            d.ellipse([cx - 26, 126, cx + 26, 178], outline=GREY, width=3)
    d.line([0, 220, W, 220], fill=CARD_BORDER, width=2)

def button(d, box, text, filled=True, color=TEAL, icon=None, size=32):
    x0, y0, x1, y1 = box
    if filled: rr(d, box, (y1 - y0) // 2, fill=color); tc = WHITE
    else: rr(d, box, (y1 - y0) // 2, outline=color, width=3, fill=WHITE); tc = color
    label = (icon + "  " if icon else "") + text
    d.text(((x0 + x1) // 2, (y0 + y1) // 2), label,
           font=fit_font(d, label, "medium", size, (x1 - x0) - 48), fill=tc, anchor="mm")

def chip(d, x, y, text, selected=False):
    f = font("medium", 30); w = int(d.textlength(text, font=f)) + 56; h = 76
    if selected: rr(d, [x, y, x + w, y + h], h // 2, fill=TEAL); fg = WHITE
    else: rr(d, [x, y, x + w, y + h], h // 2, outline=GREY_LIGHT, width=3, fill=WHITE); fg = INK
    d.text((x + w // 2, y + h // 2), text, font=f, fill=fg, anchor="mm")
    return w

def gesture_and_crop(img, d, y, name):
    d.rounded_rectangle([W // 2 - 68, y + 90, W // 2 + 68, y + 98], radius=4, fill=GREY_LIGHT)
    h = max(y + 130, int(W * 1.0))  # 長邊不超過短邊 2 倍，且不小於正方形
    img.crop((0, 0, W, min(h, 2 * W))).save(name, "PNG")

def fmt(s, **kw):
    for k, v in kw.items(): s = s.replace("{" + k + "}", str(v))
    return s

def home(L, E, path):
    img = Image.new("RGB", (W, H), TEAL_BG); d = ImageDraw.Draw(img)
    status_bar(d); app_bar(d, L["appTitle"])
    labels = [("✓ " + L["datasetShortNgsl"], True), (L["datasetShortSpoken"], False),
              (L["datasetShortPhrase"], False), (L["datasetShortPhave"], False)]
    x, y = 48, 260
    for t, sel in labels:
        w = int(d.textlength(t, font=font("medium", 30))) + 56
        if x + w > W - 48: x = 48; y += 96
        x += chip(d, x, y, t, sel) + 20
    top = y + 130; box = [48, top, W - 48, top + 620]; card(d, box, 40)
    ix0, ix1 = box[0] + 56, box[2] - 56
    rr(d, [ix0, top + 56, ix1, top + 70], 7, fill=GREY_LIGHT)
    rr(d, [ix0, top + 56, ix0 + int((ix1 - ix0) * 0.33), top + 70], 7, fill=TEAL)
    d.text((W // 2, top + 220), "bill", font=font("black", 96), fill=INK, anchor="mm")
    d.text((W // 2, top + 310), E["word"], font=font("regular", 44), fill=GREY, anchor="mm")
    button(d, [ix0, top + 400, ix1, top + 496], L["playButtonStart"], icon="▶")
    button(d, [ix0, top + 520, ix1, top + 616], L["starButton"], filled=False, color=AMBER, icon="☆")
    ut = box[3] + 32; ub = [48, ut, W - 48, ut + 260]
    card(d, ub, 32, fill=(255, 249, 230), outline=(250, 220, 150))
    t = fmt(L["unlockFreeProgress"], unlocked=936, total=2809)
    d.text((ub[0] + 40, ut + 50), t, font=fit_font(d, t, "bold", 34, ub[2] - ub[0] - 80), fill=INK, anchor="lm")
    bw = (ub[2] - ub[0] - 120) // 2; by = ut + 120
    button(d, [ub[0] + 40, by, ub[0] + 40 + bw, by + 96], L["unlockWatchAd"], filled=False, icon="▶")
    button(d, [ub[0] + 80 + bw, by, ub[0] + 80 + 2 * bw, by + 96], L["menuPremium"], icon="★")
    nt = ub[3] + 32; bw3 = (W - 96 - 40) // 3
    for i, lb in enumerate([L["navPrevious"], L["navReplay"], L["navNext"]]):
        x0 = 48 + i * (bw3 + 20)
        button(d, [x0, nt, x0 + bw3, nt + 96], lb, filled=False, color=GREY, size=30)
    st = nt + 124; sb = [48, st, W - 48, st + 130]; card(d, sb, 28)
    d.text((sb[0] + 36, st + 45), L["settingsTitle"], font=font("medium", 34), fill=INK, anchor="lm")
    s = fmt(L["settingsSummaryLine"], mode=L["summaryReadBilingual"], count=2, rate="0.9")
    d.text((sb[0] + 36, st + 95), s, font=font("regular", 26), fill=GREY, anchor="lm")
    cx, cy = sb[2] - 40, st + 65
    d.polygon([(cx - 12, cy - 6), (cx + 12, cy - 6), (cx, cy + 10)], fill=GREY)
    gesture_and_crop(img, d, sb[3], path)

def intro(L, E, path):
    img = Image.new("RGB", (W, H), WHITE); d = ImageDraw.Draw(img)
    status_bar(d)
    d.text((W - 60, 150), L["introSkip"], font=font("medium", 32), fill=TEAL, anchor="rm")
    cy = 420
    d.ellipse([W // 2 - 130, cy - 130, W // 2 + 130, cy + 130], fill=TEAL_LIGHT_BG)
    # 簡易「上升趨勢」圖示
    pts = [(W // 2 - 70, cy + 40), (W // 2 - 20, cy - 10), (W // 2 + 15, cy + 20), (W // 2 + 70, cy - 45)]
    d.line(pts, fill=TEAL, width=16, joint="curve")
    for p in pts: d.ellipse([p[0] - 12, p[1] - 12, p[0] + 12, p[1] + 12], fill=TEAL)
    y = cy + 230
    tf = fit_font(d, L["introTitle1"], "bold", 56, W - 140)
    for ln in wrap(d, L["introTitle1"], tf, W - 140):
        d.text((W // 2, y), ln, font=tf, fill=INK, anchor="mm"); y += 76
    y += 40; bf = font("regular", 38)
    for ln in wrap(d, L["introBody1"], bf, W - 180):
        d.text((W // 2, y), ln, font=bf, fill=GREY, anchor="mm"); y += 64
    y += 90
    for i in range(6):
        w = 44 if i == 0 else 16; x0 = W // 2 - 90 + i * 30 + (0 if i == 0 else 28)
        rr(d, [x0, y, x0 + w, y + 16], 8, fill=TEAL if i == 0 else (190, 226, 221))
    y += 70
    rr(d, [60, y, W - 60, y + 110], 26, fill=TEAL)
    d.text((W // 2, y + 55), L["introNext"], font=font("medium", 38), fill=WHITE, anchor="mm")
    gesture_and_crop(img, d, y + 110, path)

def stats(L, E, path):
    img = Image.new("RGB", (W, H), TEAL_BG); d = ImageDraw.Draw(img)
    status_bar(d); app_bar(d, L["statsTitle"], back=True, icons=False)
    top = 260; cw = (W - 96 - 24) // 2
    for i, (v, lb) in enumerate([("12", L["todayLearnedLabel"]), ("1,248", L["totalLearnedLabel"])]):
        b = [48 + i * (cw + 24), top, 48 + i * (cw + 24) + cw, top + 260]; card(d, b, 28)
        cx = (b[0] + b[2]) // 2
        d.text((cx, top + 90), v, font=font("black", 64), fill=INK, anchor="mm")
        d.text((cx, top + 150), L["unitCount"], font=font("regular", 28), fill=GREY, anchor="mm")
        d.text((cx, top + 200), lb, font=fit_font(d, lb, "medium", 30, cw - 40), fill=INK, anchor="mm")
    nt = top + 292; ix0, ix1 = 96, W - 96
    note = re.split(r"[（(]", L["statsDescNgsl"])[0].strip()
    nf = font("regular", 28); lines = wrap(d, note, nf, ix1 - ix0)
    nb = [48, nt, W - 48, nt + 250 + len(lines) * 46]; card(d, nb, 32)
    d.text((ix0, nt + 56), L["datasetNameNgsl"], font=fit_font(d, L["datasetNameNgsl"], "bold", 34, ix1 - ix0), fill=INK, anchor="lm")
    py = nt + 120
    rr(d, [ix0, py, ix1, py + 20], 10, fill=GREY_LIGHT)
    rr(d, [ix0, py, ix0 + int((ix1 - ix0) * 1248 / 2809), py + 20], 10, fill=TEAL)
    d.text((ix0, py + 60), fmt(L["itemsCountLabel"], learned="1,248", total="2,809"), font=font("regular", 30), fill=GREY, anchor="lm")
    ly = py + 125
    for ln in lines: d.text((ix0, ly), ln, font=nf, fill=GREY, anchor="lm"); ly += 46
    rt = nb[3] + 32; rb = [48, rt, W - 48, rt + 300]; card(d, rb, 32)
    d.text((ix0, rt + 56), L["dailyReminderHeader"], font=font("bold", 34), fill=INK, anchor="lm")
    d.text((ix0, rt + 130), L["enableDailyReminder"], font=fit_font(d, L["enableDailyReminder"], "regular", 32, ix1 - ix0 - 150), fill=INK, anchor="lm")
    rr(d, [ix1 - 110, rt + 102, ix1, rt + 158], 28, fill=TEAL)
    d.ellipse([ix1 - 52, rt + 106, ix1 - 4, rt + 154], fill=WHITE)
    d.text((ix0, rt + 220), L["reminderTimeLabel"], font=font("regular", 32), fill=INK, anchor="lm")
    d.text((ix1, rt + 220), "20:00", font=font("medium", 32), fill=TEAL, anchor="rm")
    gesture_and_crop(img, d, rb[3], path)

def paywall(L, E, path):
    img = Image.new("RGB", (W, H), WHITE); d = ImageDraw.Draw(img)
    status_bar(d); app_bar(d, L["menuPremium"], back=True, icons=False)
    y = 300
    d.text((48, y), L["paywallHeadline"], font=fit_font(d, L["paywallHeadline"], "black", 52, W - 96), fill=INK, anchor="lm")
    y += 100
    for b in [L["paywallBenefitAllContent"], L["paywallBenefitNoAds"], L["paywallBenefitBackground"]]:
        cx, cy = 60, y + 20
        d.ellipse([cx - 22, cy - 22, cx + 22, cy + 22], fill=TEAL_LIGHT_BG)
        d.line([cx - 10, cy, cx - 2, cy + 10], fill=TEAL, width=6)
        d.line([cx - 2, cy + 10, cx + 12, cy - 10], fill=TEAL, width=6)
        d.text((100, cy), b, font=fit_font(d, b, "regular", 36, W - 150), fill=INK, anchor="lm")
        y += 76
    y += 40
    for name, featured in [(L["paywallPlanAnnual"], True), (L["paywallPlanMonthly"], False)]:
        b = [48, y, W - 48, y + 130]
        if featured:
            card(d, b, 28, fill=TEAL, outline=TEAL); fg = WHITE
            tf = font("bold", 26); tw = int(d.textlength(E["best"], font=tf)) + 48
            tag = [b[2] - 30 - tw, b[1] - 18, b[2] - 30, b[1] + 34]; rr(d, tag, 20, fill=AMBER)
            d.text(((tag[0] + tag[2]) // 2, (tag[1] + tag[3]) // 2), E["best"], font=tf, fill=WHITE, anchor="mm")
        else:
            card(d, b, 28); fg = INK
        d.text((b[0] + 44, b[1] + 65), name, font=font("bold", 36), fill=fg, anchor="lm")
        y += 158
    y += 20
    d.text((W // 2, y + 20), L["paywallRestoreButton"], font=font("medium", 32), fill=TEAL, anchor="mm")
    gesture_and_crop(img, d, y + 20, path)

def feature_graphic(L, E, path):
    import math
    FW, FH = 1024, 500
    img = Image.new("RGB", (FW, FH))
    px = img.load()
    for yy in range(FH):
        for x in range(FW):
            t = (x + yy) / (FW + FH)
            px[x, yy] = tuple(int(a + (b - a) * t) for a, b in zip((14, 116, 106), (9, 82, 75)))
    img = img.convert("RGBA")
    ov = Image.new("RGBA", (FW, FH), (0, 0, 0, 0)); od = ImageDraw.Draw(ov)
    for i in range(22):  # 右側半透明音波（與繁中主題圖相同）
        x0 = 660 + i * 24; h = 40 + int(180 * abs(math.sin(i * 0.7)))
        od.rounded_rectangle([x0, FH // 2 - h // 2, x0 + 14, FH // 2 + h // 2], radius=7, fill=(255, 255, 255, 45))
    img = Image.alpha_composite(img, ov); d = ImageDraw.Draw(img)
    bx, by = 150, FH // 2
    d.ellipse([bx - 110, by - 110, bx + 110, by + 110], fill=WHITE)
    for i, h in enumerate([40, 74, 54, 86, 34]):
        x0 = bx - 57 + i * 23
        rr(d, [x0, by - h // 2, x0 + 13, by + h // 2], 6, fill=TEAL)
    d.arc([bx - 140, by - 140, bx + 140, by + 140], start=200, end=340, fill=(255, 255, 255, 230), width=16)
    x, max_w = 300, FW - 300 - 40
    tf = fit_font(d, L["appTitle"], "black", 66, max_w, 40)
    tl = wrap(d, L["appTitle"], tf, max_w)
    f1 = fit_font(d, E["fg1"], "medium", 32, max_w, 22)
    f2 = font("regular", 30); l2 = wrap(d, E["fg2"], f2, max_w)
    total = len(tl) * 80 + 20 + 50 + len(l2) * 44
    y = FH // 2 - total // 2 + 40
    for ln in tl: d.text((x, y), ln, font=tf, fill=WHITE, anchor="lm"); y += 80
    y += 10
    d.text((x, y), E["fg1"], font=f1, fill=(220, 245, 242), anchor="lm"); y += 60
    for ln in l2: d.text((x, y), ln, font=f2, fill=(220, 245, 242), anchor="lm"); y += 44
    img.convert("RGB").save(path, "PNG")

for lang in ["zh", "ja", "ko", "vi", "id", "zh_Hans", "es", "pt"]:
    LANG = lang
    L = json.load(open(os.path.join(ROOT, "lib", "l10n", f"app_{lang}.arb"), encoding="utf-8"))
    E = EXTRA[lang]
    od = os.path.join(OUT, lang); os.makedirs(od, exist_ok=True)
    home(L, E, os.path.join(od, "1_home.png"))
    intro(L, E, os.path.join(od, "2_intro.png"))
    stats(L, E, os.path.join(od, "3_stats.png"))
    paywall(L, E, os.path.join(od, "4_paywall.png"))
    feature_graphic(L, E, os.path.join(od, "feature_graphic.png"))
    print(lang, "done")
