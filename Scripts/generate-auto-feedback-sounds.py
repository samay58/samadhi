#!/usr/bin/env python3
"""Offline prototype arrival sounds for Samadhi Auto feedback.

Standard library only. No network, no paid service, no third-party audio. Every file is
synthesized from the parameters in FAMILIES below, so the same script reproduces the same bytes.
These are prototypes for physical comparison, not approved product assets.
"""

import argparse
import hashlib
import json
import math
import os
import struct
import wave
import zlib

SAMPLE_RATE = 48000
CHANNELS = 1
SAMPLE_WIDTH_BYTES = 2
PEAK_TARGET_DBFS = -9.0
HARMONIC_RATIO = 2.0
HARMONIC_GAIN = 0.18
TAIL_FADE_SECONDS = 0.008

# Warm mid register: low enough to stay under a vocal, high enough to survive a pocket.
ROOT_HZ = 294.0
FOURTH_HZ = 392.0
FIFTH_HZ = 441.0

# One segment is one tone. A glide moves from start_hz to end_hz in log frequency, which is how a
# musical interval is heard. gain_start and gain_end shade the direction without changing the order.
FAMILIES = {
    "pulse": {
        "material": "two short soft tones a fifth apart",
        "faster": [
            {"start": 0.0, "duration": 0.13, "start_hz": ROOT_HZ, "end_hz": ROOT_HZ,
             "gain_start": 0.75, "gain_end": 0.75, "attack": 0.012, "tau": 0.045},
            {"start": 0.15, "duration": 0.16, "start_hz": FIFTH_HZ, "end_hz": FIFTH_HZ,
             "gain_start": 1.0, "gain_end": 1.0, "attack": 0.010, "tau": 0.055},
        ],
        "slower": [
            {"start": 0.0, "duration": 0.13, "start_hz": FIFTH_HZ, "end_hz": FIFTH_HZ,
             "gain_start": 1.0, "gain_end": 1.0, "attack": 0.010, "tau": 0.045},
            {"start": 0.15, "duration": 0.19, "start_hz": ROOT_HZ, "end_hz": ROOT_HZ,
             "gain_start": 0.70, "gain_end": 0.70, "attack": 0.014, "tau": 0.070},
        ],
    },
    "swell": {
        "material": "one gliding tone across a fifth",
        "faster": [
            {"start": 0.0, "duration": 0.32, "start_hz": ROOT_HZ, "end_hz": FIFTH_HZ,
             "gain_start": 0.62, "gain_end": 1.0, "attack": 0.015, "tau": 0.150},
        ],
        "slower": [
            {"start": 0.0, "duration": 0.34, "start_hz": FIFTH_HZ, "end_hz": ROOT_HZ,
             "gain_start": 1.0, "gain_end": 0.60, "attack": 0.012, "tau": 0.130},
        ],
    },
    "step": {
        "material": "three stepped tones through root, fourth, fifth",
        "faster": [
            {"start": 0.0, "duration": 0.14, "start_hz": ROOT_HZ, "end_hz": ROOT_HZ,
             "gain_start": 0.70, "gain_end": 0.70, "attack": 0.010, "tau": 0.048},
            {"start": 0.10, "duration": 0.14, "start_hz": FOURTH_HZ, "end_hz": FOURTH_HZ,
             "gain_start": 0.85, "gain_end": 0.85, "attack": 0.009, "tau": 0.048},
            {"start": 0.20, "duration": 0.15, "start_hz": FIFTH_HZ, "end_hz": FIFTH_HZ,
             "gain_start": 1.0, "gain_end": 1.0, "attack": 0.009, "tau": 0.060},
        ],
        "slower": [
            {"start": 0.0, "duration": 0.14, "start_hz": FIFTH_HZ, "end_hz": FIFTH_HZ,
             "gain_start": 1.0, "gain_end": 1.0, "attack": 0.009, "tau": 0.048},
            {"start": 0.105, "duration": 0.14, "start_hz": FOURTH_HZ, "end_hz": FOURTH_HZ,
             "gain_start": 0.85, "gain_end": 0.85, "attack": 0.010, "tau": 0.048},
            {"start": 0.215, "duration": 0.16, "start_hz": ROOT_HZ, "end_hz": ROOT_HZ,
             "gain_start": 0.70, "gain_end": 0.70, "attack": 0.014, "tau": 0.068},
        ],
    },
}

DIRECTIONS = ("faster", "slower")


def render_segment(segment):
    frame_count = int(round(segment["duration"] * SAMPLE_RATE))
    attack_frames = max(1, int(round(segment["attack"] * SAMPLE_RATE)))
    fade_frames = max(1, int(round(TAIL_FADE_SECONDS * SAMPLE_RATE)))
    log_start = math.log(segment["start_hz"])
    log_end = math.log(segment["end_hz"])
    samples = [0.0] * frame_count
    phase = 0.0
    for index in range(frame_count):
        position = index / max(1, frame_count - 1)
        frequency = math.exp(log_start + (log_end - log_start) * position)
        phase += 2.0 * math.pi * frequency / SAMPLE_RATE
        tone = math.sin(phase) + HARMONIC_GAIN * math.sin(HARMONIC_RATIO * phase)

        if index < attack_frames:
            envelope = 0.5 * (1.0 - math.cos(math.pi * index / attack_frames))
        else:
            elapsed = (index - attack_frames) / SAMPLE_RATE
            envelope = math.exp(-elapsed / segment["tau"])

        # A short linear fade guarantees the segment reaches exact zero instead of a step.
        remaining = frame_count - index
        if remaining < fade_frames:
            envelope *= remaining / fade_frames

        gain = segment["gain_start"] + (segment["gain_end"] - segment["gain_start"]) * position
        samples[index] = tone * envelope * gain
    return samples


def render_file(segments):
    total_seconds = max(segment["start"] + segment["duration"] for segment in segments)
    total_frames = int(round(total_seconds * SAMPLE_RATE))
    mix = [0.0] * total_frames
    for segment in segments:
        rendered = render_segment(segment)
        offset = int(round(segment["start"] * SAMPLE_RATE))
        for index, value in enumerate(rendered):
            target = offset + index
            if target < total_frames:
                mix[target] += value

    peak = max(abs(value) for value in mix)
    scale = (10.0 ** (PEAK_TARGET_DBFS / 20.0)) / peak
    return [value * scale for value in mix]


def dbfs(value):
    return 20.0 * math.log10(value) if value > 0 else float("-inf")


def write_wave(path, samples):
    frames = bytearray()
    for value in samples:
        clamped = max(-1.0, min(1.0, value))
        frames += struct.pack("<h", int(round(clamped * 32767.0)))
    with wave.open(path, "wb") as handle:
        handle.setnchannels(CHANNELS)
        handle.setsampwidth(SAMPLE_WIDTH_BYTES)
        handle.setframerate(SAMPLE_RATE)
        handle.writeframes(bytes(frames))
    return bytes(frames)


def measure(frames):
    count = len(frames) // SAMPLE_WIDTH_BYTES
    values = struct.unpack("<%dh" % count, frames)
    peak = max(abs(value) for value in values) / 32768.0
    energy = sum(float(value) * float(value) for value in values) / count
    rms = math.sqrt(energy) / 32768.0
    return peak, rms, count


def png_chunk(tag, payload):
    body = tag + payload
    return struct.pack(">I", len(payload)) + body + struct.pack(">I", zlib.crc32(body) & 0xFFFFFFFF)


def write_png(path, width, height, pixels):
    raw = bytearray()
    for row in range(height):
        raw.append(0)
        raw += pixels[row * width * 3:(row + 1) * width * 3]
    header = struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0)
    with open(path, "wb") as handle:
        handle.write(b"\x89PNG\r\n\x1a\n")
        handle.write(png_chunk(b"IHDR", header))
        handle.write(png_chunk(b"IDAT", zlib.compress(bytes(raw), 9)))
        handle.write(png_chunk(b"IEND", b""))


def draw_waveforms(path, rendered):
    """One stacked grey-on-white waveform sheet so the shapes can be inspected without listening."""
    width = 900
    lane_height = 110
    height = lane_height * len(rendered)
    pixels = bytearray([255] * (width * height * 3))

    def put(x, y, color):
        if 0 <= x < width and 0 <= y < height:
            base = (y * width + x) * 3
            pixels[base:base + 3] = bytes(color)

    longest = max(len(samples) for _, samples in rendered)
    for lane, (name, samples) in enumerate(rendered):
        centre = lane * lane_height + lane_height // 2
        for x in range(width):
            put(x, centre, (200, 200, 200))
        span = int(len(samples) / longest * width)
        for x in range(max(1, span)):
            start = int(x / max(1, span) * len(samples))
            end = max(start + 1, int((x + 1) / max(1, span) * len(samples)))
            window = samples[start:end]
            high = max(window)
            low = min(window)
            top = centre - int(high * (lane_height // 2 - 6))
            bottom = centre - int(low * (lane_height // 2 - 6))
            for y in range(min(top, bottom), max(top, bottom) + 1):
                put(x, y, (40, 40, 40))
        for x in range(width):
            put(x, lane * lane_height, (230, 230, 230))
    write_png(path, width, height, pixels)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", required=True, help="directory that receives <family>/arrival-<direction>.wav")
    parser.add_argument("--manifest", required=True, help="path for the JSON manifest")
    parser.add_argument("--waveform", default=None, help="optional PNG waveform sheet")
    arguments = parser.parse_args()

    entries = []
    rendered_for_plot = []
    for family in sorted(FAMILIES):
        family_directory = os.path.join(arguments.output, family)
        os.makedirs(family_directory, exist_ok=True)
        for direction in DIRECTIONS:
            segments = FAMILIES[family][direction]
            samples = render_file(segments)
            name = "arrival-%s.wav" % direction
            path = os.path.join(family_directory, name)
            frames = write_wave(path, samples)
            peak, rms, frame_count = measure(frames)
            with open(path, "rb") as handle:
                digest = hashlib.sha256(handle.read()).hexdigest()
            entries.append({
                "file": "%s/%s" % (family, name),
                "family": family,
                "direction": direction,
                "material": FAMILIES[family]["material"],
                "sample_rate_hz": SAMPLE_RATE,
                "channels": CHANNELS,
                "bit_depth": SAMPLE_WIDTH_BYTES * 8,
                "frames": frame_count,
                "duration_seconds": round(frame_count / SAMPLE_RATE, 6),
                "peak_dbfs": round(dbfs(peak), 3),
                "rms_dbfs": round(dbfs(rms), 3),
                "sha256": digest,
                "segments": segments,
            })
            rendered_for_plot.append(("%s %s" % (family, direction), samples))

    manifest = {
        "generator": "Scripts/generate-auto-feedback-sounds.py",
        "status": "offline prototype, not an approved product sound",
        "third_party_material": "none",
        "sample_rate_hz": SAMPLE_RATE,
        "channels": CHANNELS,
        "bit_depth": SAMPLE_WIDTH_BYTES * 8,
        "peak_target_dbfs": PEAK_TARGET_DBFS,
        "second_harmonic_gain": HARMONIC_GAIN,
        "root_hz": ROOT_HZ,
        "fourth_hz": FOURTH_HZ,
        "fifth_hz": FIFTH_HZ,
        "files": entries,
    }
    os.makedirs(os.path.dirname(os.path.abspath(arguments.manifest)), exist_ok=True)
    with open(arguments.manifest, "w") as handle:
        json.dump(manifest, handle, indent=2, sort_keys=False)
        handle.write("\n")

    if arguments.waveform:
        os.makedirs(os.path.dirname(os.path.abspath(arguments.waveform)), exist_ok=True)
        draw_waveforms(arguments.waveform, rendered_for_plot)

    for entry in entries:
        print("%-22s %6.3f s  peak %7.2f dBFS  rms %7.2f dBFS" % (
            entry["file"], entry["duration_seconds"], entry["peak_dbfs"], entry["rms_dbfs"]))


if __name__ == "__main__":
    main()
