#!/bin/bash
# Every installed Omarchy theme must generate a full gray table with readable text on Discord's backgrounds.
set -euo pipefail
python3 - "$(dirname "$(realpath "$0")")/omarchy-discord-theme" <<'EOF'
import colorsys, glob, os, re, sys, tomllib, types
gen = types.ModuleType("gen")
exec(open(sys.argv[1]).read(), gen.__dict__)

def color(triplet):
    h, s, l = (float(x) for x in re.findall(r"[\d.]+", triplet))
    return tuple(round(v * 255) for v in colorsys.hls_to_rgb(h / 360, l / 100, s / 100))

themes = glob.glob("/usr/share/omarchy/themes/*/colors.toml") + glob.glob(os.path.expanduser("~/.config/omarchy/themes/*/colors.toml"))
for path in themes:
    out = gen.build(tomllib.load(open(path, "rb")))
    assert len(out["gray"]) == 1001, path
    at = lambda light: color(out["gray"][round(light * 10)])
    # Discord lightness of each role in the Darker / Light theme (see anchors in the generator).
    bg, text, muted = (14.314, 94.118, 60.392) if out["scheme"] == "dark" else (100, 19.216, 44.314)
    assert gen.contrast(at(text), at(bg)) >= 4.5, (path, "text")
    assert gen.contrast(at(muted), at(bg)) >= 4.5, (path, "muted text")
print(f"generator OK on {len(themes)} themes")
EOF
