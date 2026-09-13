# omarchy-discord-theme

Make the Discord web app follow your [Omarchy](https://omarchy.org) theme, and keep following it every time you switch themes. Discord recolors live, no reload needed.

Inspired by [omarchy-telegram-theme](https://github.com/gmickel/omarchy-telegram-theme). Siblings: [omarchy-slack-theme](https://github.com/GruperTal/omarchy-slack-theme), [omarchy-whatsapp-theme](https://github.com/GruperTal/omarchy-whatsapp-theme).

## Install

```bash
git clone https://github.com/GruperTal/omarchy-discord-theme
cd omarchy-discord-theme
./install.sh
```

Then, once, in your browser (Chrome, Chromium, Brave… whichever runs your Omarchy web apps):

1. Open `chrome://extensions` and turn on **Developer mode**
2. **Load unpacked** → `~/.local/share/omarchy-discord-theme/extension`
3. Reload Discord

In Discord → User Settings → Appearance pick **Darker** for dark Omarchy themes or **Light** for light ones. Those are the themes the colour mapping is calibrated against; Dark and Midnight still follow Omarchy, just lighter or darker than your palette.

## How it works

Discord builds its ~1000 semantic colours out of primitive ramps like `--neutral-82-hsl` or `--blurple-50-hsl`.

- **`omarchy-discord-theme`** reads `~/.local/state/omarchy/current/theme/colors.toml` and writes `theme.json` into the extension folder:
  - a lightness → colour table for the gray ramps, anchored so Discord's backgrounds land on Omarchy's backgrounds and its text on Omarchy's foreground (muted text nudged to 4.5:1 contrast)
  - an Omarchy hue for each colour ramp (blurple → accent, red → red, …), keeping Discord's own lightness steps
- **The extension** runs on `discord.com` only. It reads every ramp step's lightness from Discord's CSS and overrides it from `theme.json`. It re-reads `theme.json` every 2 seconds; unpacked extensions serve files straight from disk, so a theme switch shows up without reloading anything. It has no permissions and makes no network requests.
- **`install.sh`** copies the extension and generator into place and adds an Omarchy `theme-set.d` hook that regenerates `theme.json` on every theme switch.

## Requirements

- Omarchy 4 (theme hooks + `colors.toml`)
- A Chromium-based browser
- Python 3.11+

## Uninstall

Remove the extension in `chrome://extensions`, then:

```bash
rm -r ~/.local/share/omarchy-discord-theme
rm ~/.local/bin/omarchy-discord-theme ~/.config/omarchy/hooks/theme-set.d/omarchy-discord-theme
```

## Test

`./test.sh` checks that every installed Omarchy theme generates readable text and muted text on Discord's backgrounds.

## Caveats

- Illustrations, banners and the login page artwork are images and stay stock.
- Discord can rename its ramps in any release; parts that stop following the theme mean the mapping needs an update.
