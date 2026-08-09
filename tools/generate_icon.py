#!/usr/bin/env python3
"""Render the 1024x1024 app icon: a cream toggle switch plate on charcoal.

Pure stdlib - signed-distance-field shapes with smooth edges, written as PNG.
"""
import math
import os
import struct
import zlib

SIZE = 1024
OUT = os.path.join(os.path.dirname(__file__), "..", "BoringSwitch",
                   "Assets.xcassets", "AppIcon.appiconset", "AppIcon.png")


def sd_round_rect(px, py, cx, cy, hw, hh, r):
    dx = abs(px - cx) - (hw - r)
    dy = abs(py - cy) - (hh - r)
    ox = max(dx, 0.0)
    oy = max(dy, 0.0)
    return math.hypot(ox, oy) + min(max(dx, dy), 0.0) - r


def sd_circle(px, py, cx, cy, r):
    return math.hypot(px - cx, py - cy) - r


def mix(a, b, t):
    return tuple(a[i] + (b[i] - a[i]) * t for i in range(3))


def coverage(d):
    # 1 inside, 0 outside, smooth over ~1.5px
    return max(0.0, min(1.0, 0.5 - d / 1.5))


BG_TOP = (26, 27, 32)
BG_BOT = (14, 14, 18)
PLATE = (240, 232, 214)
PLATE_EDGE = (196, 186, 162)
BEZEL = (58, 52, 44)
LEVER = (252, 248, 240)
LEVER_SHADE = (208, 200, 184)
SCREW = (150, 140, 120)

rows = []
for y in range(SIZE):
    row = bytearray()
    ty = y / SIZE
    for x in range(SIZE):
        c = mix(BG_TOP, BG_BOT, ty)

        # subtle glow behind the plate
        glow = math.exp(-((x - 512) ** 2 + (y - 470) ** 2) / (2 * 330.0 ** 2))
        c = mix(c, (58, 56, 48), glow * 0.55)

        # wall plate with soft drop shadow
        dsh = sd_round_rect(x, y + 14, 512, 512, 210, 310, 56)
        c = mix(c, (0, 0, 0), 0.35 * max(0.0, min(1.0, -dsh / 40 + 0.5)) if dsh < 20 else 0.0)
        dp = sd_round_rect(x, y, 512, 512, 210, 310, 56)
        plate_col = mix(PLATE, PLATE_EDGE, max(0.0, min(1.0, (y - 300) / 500)))
        c = mix(c, plate_col, coverage(dp))

        if dp < 0:
            # screws
            for sy in (268, 756):
                c = mix(c, SCREW, coverage(sd_circle(x, y, 512, sy, 13)))
            # bezel opening
            db = sd_round_rect(x, y, 512, 512, 62, 130, 20)
            c = mix(c, BEZEL, coverage(db))
            # lever flipped up
            dl = sd_round_rect(x, y, 512, 448, 40, 84, 16)
            lever_col = mix(LEVER, LEVER_SHADE, max(0.0, min(1.0, (y - 380) / 160)))
            c = mix(c, lever_col, coverage(dl))

        row += bytes((int(c[0]), int(c[1]), int(c[2])))
    rows.append(bytes(row))

raw = b"".join(b"\x00" + r for r in rows)


def chunk(tag, data):
    return (struct.pack(">I", len(data)) + tag + data +
            struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF))


png = (b"\x89PNG\r\n\x1a\n" +
       chunk(b"IHDR", struct.pack(">IIBBBBB", SIZE, SIZE, 8, 2, 0, 0, 0)) +
       chunk(b"IDAT", zlib.compress(raw, 6)) +
       chunk(b"IEND", b""))

with open(OUT, "wb") as f:
    f.write(png)
print(f"wrote {os.path.abspath(OUT)} ({len(png)//1024} KB)")
