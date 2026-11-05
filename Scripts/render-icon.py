#!/usr/bin/env python3
"""Draws the Slipstream app icon: ideal flow past a sphere, with a wake that sways left and right, around one
polished sphere that mirrors the lines. Every value that shapes the picture is a keyword.

Needs numpy and Pillow, which the app itself never uses:
python3 -m venv .build/icon && .build/icon/bin/pip install numpy pillow
.build/icon/bin/python Scripts/render-icon.py
"""
import sys
import numpy as np
from PIL import Image


def linear(hex_color):
    return np.array([int(hex_color[i:i + 2], 16) / 255 for i in (0, 2, 4)]) ** 2.2


def smooth(e0, e1, x):
    t = np.clip((x - e0) / (e1 - e0), 0, 1)
    return t * t * (3 - 2 * t)


def stream(x, y, cx, cy, a, ripple, ripple_length, ripple_height):
    dx, dy = x - cx, y - cy
    # Behind a body the wake sways left, right, left, right at a steady rate, the way a stride does.
    start = smooth(a * .75, a * 2.3, dx)
    sway = ripple * start * np.sin(2 * np.pi * (dx - a) / ripple_length) * np.exp(-dy * dy / (2 * ripple_height ** 2))
    bent = dy - sway
    return bent * (1 - a * a / np.maximum(dx * dx + dy * dy, a * a * .2))


def render(ground, line, shadow, size=1024, ss=4, ball='BDAEEF', ball_deep='4B3A86', sheen='FFFFFF',
           cx=-.34, cy=0., a=.5, pitch=.148, width=.05, ripple=.2, ripple_length=.82, ripple_height=.66,
           mirror=.6, mirror_power=5):
    n = size * ss
    xs = (np.arange(n) + .5) / n * 2 - 1
    x, y = np.meshgrid(xs, -xs)
    args = (cx, cy, a, ripple, ripple_length, ripple_height)
    psi = stream(x, y, *args) + pitch / 2   # the half step keeps a line from tracing the sphere's own outline
    gy, gx = np.gradient(psi, xs[1] - xs[0])
    dist = np.abs(psi - pitch * np.round(psi / pitch)) / np.maximum(np.hypot(gx, gy), 1e-3)
    px = 2 / n
    mask = smooth(width / 2 + px, width / 2 - px, dist)
    ground_c, line_c = linear(ground)[None, None, :], linear(line)[None, None, :]
    img = ground_c * (1 - mask[..., None]) + line_c * mask[..., None]

    dx, dy = x - cx, y - cy
    rr = np.hypot(dx, dy)
    cast = smooth(a * 1.2, a * .9, np.hypot(dx - a * .05, dy + a * .1))
    img = img * (1 - shadow * cast[..., None])

    # A lacquered ball: a saturated base under a clear coat that mirrors the room and the lines around it.
    nx, ny = dx / a, dy / a
    rho = np.clip(np.hypot(nx, ny), 0, 1)
    nz = np.sqrt(np.clip(1 - nx * nx - ny * ny, 0, 1))
    key = np.array([-.48, .6, .64])
    lambert = np.clip(nx * key[0] + ny * key[1] + nz * key[2], 0, 1)
    wrap = (.2 + .8 * lambert) ** 1.3
    base = linear(ball_deep)[None, None, :] + (linear(ball) - linear(ball_deep))[None, None, :] * wrap[..., None]
    fresnel = .02 + .98 * (1 - nz) ** mirror_power

    # The coat mirrors the line field, bent by the curve of the ball. This is what reads as polish.
    rx, ry = 2 * nz * nx, 2 * nz * ny
    sx = np.clip(((x + rx * a * 1.1 + 1) / 2 * n).astype(int), 0, n - 1)
    sy = np.clip(((1 - (y + ry * a * 1.1)) / 2 * n).astype(int), 0, n - 1)
    world = img[sy, sx]

    # One large soft box, arched along the curve of the ball at the upper left, and a thin rim light opposite.
    angle = np.arctan2(ny, nx)
    around = np.abs(np.angle(np.exp(1j * (angle - np.radians(128)))))
    box = smooth(np.radians(46), np.radians(30), around) * smooth(.46, .56, rho) * smooth(.9, .8, rho)
    box = box * (.55 + .45 * smooth(.56, .8, rho))
    around2 = np.abs(np.angle(np.exp(1j * (angle - np.radians(-52)))))
    rim = smooth(np.radians(62), np.radians(10), around2) * smooth(.86, .95, rho) * smooth(1., .975, rho)
    sheen_c = linear(sheen)[None, None, :]
    ball_img = base * (1 - fresnel[..., None]) + world * (fresnel[..., None] * mirror)
    ball_img = ball_img + sheen_c * (box[..., None] * .82 + rim[..., None] * .5)

    aa = smooth(a + px, a - px, rr)[..., None]
    img = img * (1 - aa) + ball_img * aa
    img = np.clip(img, 0, 1) ** (1 / 2.2)
    out = Image.fromarray((img * 255 + .5).astype('uint8'))
    return out.resize((size, size), Image.LANCZOS)


if __name__ == '__main__':
    folder = sys.argv[1] if len(sys.argv) > 1 else 'Resources/Assets.xcassets/AppIcon.appiconset'
    render(ground='D8F24C', line='0B0D08', shadow=.5).save(f'{folder}/AppIcon.png', optimize=True)
    render(ground='0B0D08', line='D8F24C', shadow=.95).save(f'{folder}/AppIcon-dark.png', optimize=True)
    # The system tints this one, so it carries only light and dark, stored as RGB for the asset catalog.
    gray = render(ground='D8F24C', line='0B0D08', shadow=.5).convert('L').convert('RGB')
    gray.save(f'{folder}/AppIcon-tinted.png', optimize=True)
