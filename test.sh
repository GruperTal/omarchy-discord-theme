#!/bin/bash
# Every installed Omarchy theme, plus legacy-format themes, must generate a full gray table
# with readable text on Discord's backgrounds.
set -euo pipefail
python3 - "$(dirname "$(realpath "$0")")/omarchy-discord-theme" <<'EOF'
import colorsys, glob, os, re, sys, tempfile, types
gen = types.ModuleType("gen")
exec(open(sys.argv[1]).read(), gen.__dict__)

def color(triplet):
    h, s, l = (float(x) for x in re.findall(r"[\d.]+", triplet))
    return tuple(round(v * 255) for v in colorsys.hls_to_rgb(h / 360, l / 100, s / 100))

# Third-party themes in the wild: ANSI-only palettes (no accent, muted or shades) and short names.
LEGACY = {
    "ansi": 'background = "#1b2d40"\nforeground = "#d6e2ee"\n'
            + "".join(f'color{i} = "#{v}"\n' for i, v in enumerate(
                "1b2d40 4d86b0 5e95bc 6fa4c9 6fb8e3 8bc9eb b4e4f6 d6e2ee 4a6b80 4d86b0 5e95bc 6fa4c9 6fb8e3 8bc9eb b4e4f6 fff".split())),
    "short-names": 'accent = "#808b40"\nbg = "#0D1319"\nfg = "#F2ECCD"\nlighter_bg = "#172532"\nmuted = "#7b8a8e"\n'
                   'red = "#cf5a44"\ngreen = "#dbc66f"\nyellow = "#fff38a"\nblue = "#808b40"\nmagenta = "#e0a154"\ncyan = "#ebe36c"\n',
}
tmp = tempfile.mkdtemp()
fixtures = []
for name, body in LEGACY.items():
    fixtures.append(os.path.join(tmp, f"{name}.toml"))
    open(fixtures[-1], "w").write(body)

themes = glob.glob("/usr/share/omarchy/themes/*/colors.toml") + glob.glob(os.path.expanduser("~/.config/omarchy/themes/*/colors.toml")) + fixtures
for path in themes:
    out = gen.build(gen.palette(path))
    assert len(out["gray"]) == 1001, path
    at = lambda light: color(out["gray"][round(light * 10)])
    # Discord lightness of each role in the Darker / Light theme (see anchors in the generator).
    bg, text, muted = (14.314, 94.118, 60.392) if out["scheme"] == "dark" else (100, 19.216, 44.314)
    assert gen.contrast(at(text), at(bg)) >= 4.5, (path, "text")
    assert gen.contrast(at(muted), at(bg)) >= 4.5, (path, "muted text")
print(f"generator OK on {len(themes)} themes ({len(fixtures)} legacy-format)")
EOF
