#!/bin/bash
# Make the Discord web app follow the Omarchy theme. No sudo needed.
set -euo pipefail
cd "$(dirname "$(realpath "$0")")"

ext=~/.local/share/omarchy-discord-theme/extension
mkdir -p "$ext"
cp extension/manifest.json extension/content.js "$ext/"
install -Dm755 omarchy-discord-theme ~/.local/bin/omarchy-discord-theme

hook=~/.config/omarchy/hooks/theme-set.d/omarchy-discord-theme
cat >"$hook" <<'EOF'
#!/bin/bash
# Regenerate Discord colours; the extension picks them up live. Never fail the theme switch.
~/.local/bin/omarchy-discord-theme || logger -t omarchy-discord-theme "failed to generate Discord theme for ${1:-unknown}"
exit 0
EOF
chmod +x "$hook"

~/.local/bin/omarchy-discord-theme

cat <<EOF
Installed. One-time step in your browser:
  1. Open chrome://extensions and turn on Developer mode
  2. Load unpacked -> $ext
  3. Reload Discord, and pick Settings -> Appearance -> Darker (or Light for light Omarchy themes)
EOF
