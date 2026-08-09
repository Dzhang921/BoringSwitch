#!/usr/bin/env python3
"""Generate the click sound library for Boring Switch.

Writes BoringSwitch/Resources/Sounds/<style>_<material>_<on|off>.wav
(5 styles x 4 materials x 2 states = 40 short mono 44.1kHz WAVs).

Pure stdlib so it runs anywhere: simple additive synthesis with
exponentially decaying sines plus filtered noise transients.
"""
import math
import os
import random
import struct
import wave

SR = 44100
OUT = os.path.join(os.path.dirname(__file__), "..", "BoringSwitch", "Resources", "Sounds")

random.seed(7)  # deterministic output


def silence(dur):
    return [0.0] * int(SR * dur)


def add(buf, other, offset=0.0):
    start = int(SR * offset)
    while len(buf) < start + len(other):
        buf.append(0.0)
    for i, s in enumerate(other):
        buf[start + i] += s
    return buf


def decaying_sine(freq, decay, amp, dur=None):
    dur = dur or decay * 6
    n = int(SR * dur)
    return [amp * math.exp(-i / (SR * decay)) * math.sin(2 * math.pi * freq * i / SR)
            for i in range(n)]


def noise_burst(dur, decay, amp, lowpass=0.0):
    n = int(SR * dur)
    out = []
    prev = 0.0
    for i in range(n):
        s = random.uniform(-1, 1) * amp * math.exp(-i / (SR * decay))
        if lowpass > 0:
            s = prev + lowpass * (s - prev)
            prev = s
        out.append(s)
    return out


def transient(bright, amp):
    """A 3-8ms attack tick. bright in [0,1] controls high-frequency content."""
    return noise_burst(0.008, 0.0015 + 0.002 * bright, amp, lowpass=1.0 - 0.7 * (1 - bright))


# ---------------------------------------------------------------- styles

def base_toggle(pitch):
    buf = transient(0.9, 0.9)
    add(buf, decaying_sine(1800 * pitch, 0.008, 0.35))
    add(buf, decaying_sine(700 * pitch, 0.018, 0.4))
    # second contact bounce, very close - the classic "snap"
    add(buf, transient(0.8, 0.45), offset=0.012)
    add(buf, decaying_sine(950 * pitch, 0.010, 0.2), offset=0.012)
    return buf


def base_rocker(pitch):
    buf = noise_burst(0.02, 0.008, 0.7, lowpass=0.25)
    add(buf, decaying_sine(310 * pitch, 0.035, 0.5))
    add(buf, decaying_sine(620 * pitch, 0.015, 0.2))
    return buf


def base_push(pitch):
    buf = transient(0.4, 0.5)
    add(buf, decaying_sine(150 * pitch, 0.05, 0.6))
    add(buf, decaying_sine(450 * pitch, 0.02, 0.25))
    return buf


def base_knife(pitch):
    buf = transient(0.7, 1.0)
    add(buf, decaying_sine(90 * pitch, 0.07, 0.7))
    add(buf, decaying_sine(1244 * pitch, 0.12, 0.12))
    add(buf, decaying_sine(2333 * pitch, 0.09, 0.08))
    # blade rattle settling into the contact
    add(buf, transient(0.6, 0.3), offset=0.03)
    add(buf, transient(0.5, 0.18), offset=0.055)
    return buf


def base_chain(pitch):
    buf = silence(0.001)
    t = 0.0
    for k in range(4):  # bead rattle on the way down
        add(buf, transient(0.85, 0.25 + 0.08 * k), offset=t)
        add(buf, decaying_sine(2100 * pitch * (1 + 0.07 * k), 0.006, 0.1), offset=t)
        t += random.uniform(0.035, 0.055)
    # the internal mechanism clunk
    add(buf, decaying_sine(500 * pitch, 0.02, 0.45), offset=t)
    add(buf, transient(0.5, 0.5), offset=t)
    return buf


# ------------------------------------------------------------- materials

def apply_material(buf, material, pitch):
    if material == "plastic":
        # slightly damped: one-pole lowpass
        out, prev = [], 0.0
        for s in buf:
            prev = prev + 0.55 * (s - prev)
            out.append(prev)
        return out
    if material == "brass":
        add(buf, decaying_sine(1046 * pitch, 0.09, 0.10))
        add(buf, decaying_sine(2093 * pitch, 0.06, 0.07))
        return buf
    if material == "steel":
        add(buf, decaying_sine(3520 * pitch, 0.045, 0.10))
        add(buf, noise_burst(0.006, 0.002, 0.25))
        return buf
    if material == "wood":
        add(buf, decaying_sine(220 * pitch, 0.055, 0.16))
        out, prev = [], 0.0
        for s in buf:
            prev = prev + 0.4 * (s - prev)
            out.append(prev)
        return out
    return buf


def write_wav(path, buf):
    peak = max(1e-9, max(abs(s) for s in buf))
    scale = 0.72 / peak
    # short fade-out to avoid a click at the tail
    fade = min(len(buf), int(SR * 0.01))
    frames = bytearray()
    for i, s in enumerate(buf):
        s *= scale
        if i >= len(buf) - fade:
            s *= (len(buf) - i) / fade
        frames += struct.pack("<h", int(max(-1, min(1, s)) * 32767))
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(bytes(frames))


STYLES = {
    "toggle": base_toggle,
    "rocker": base_rocker,
    "push": base_push,
    "knife": base_knife,
    "chain": base_chain,
}

os.makedirs(OUT, exist_ok=True)
count = 0
for style, gen in STYLES.items():
    for material in ["plastic", "brass", "steel", "wood"]:
        for state, pitch in [("on", 1.0), ("off", 0.85)]:
            random.seed(hash((style, material, state)) % (2**31))
            buf = gen(pitch)
            buf = apply_material(buf, material, pitch)
            name = f"{style}_{material}_{state}.wav"
            write_wav(os.path.join(OUT, name), buf)
            count += 1
print(f"wrote {count} sounds to {os.path.abspath(OUT)}")
