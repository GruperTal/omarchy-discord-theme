// Applies theme.json (written by omarchy-discord-theme) and follows it live.
// Unpacked extensions serve files straight from disk, so polling picks up theme switches.
const style = document.createElement("style");
let lastJson = "";
let ramps = [];

// Discord's primitive ramps as [property, family, lightness], e.g. ["--neutral-82-hsl", "neutral", 13.333].
// :root defines them; .visual-refresh (set on <html>) redefines some, so it wins.
function readRamps() {
  const root = new Map();
  const refresh = new Map();
  const walk = (rules) => {
    for (const rule of rules) {
      if (rule.cssRules) walk(rule.cssRules);
      const target = rule.selectorText === ":root" ? root : rule.selectorText === ".visual-refresh" ? refresh : null;
      if (!target) continue;
      for (const prop of rule.style) {
        const name = prop.match(/^--([a-z-]+?)-\d+-hsl$/);
        const light = name && rule.style.getPropertyValue(prop).match(/([\d.]+)%\s*$/);
        if (light) target.set(prop, [name[1], parseFloat(light[1])]);
      }
    }
  };
  for (const sheet of document.styleSheets) {
    if (sheet.ownerNode === style) continue;
    try { walk(sheet.cssRules); } catch {}
  }
  return [...new Map([...root, ...refresh])].map(([prop, [family, light]]) => [prop, family, light]);
}

async function tick() {
  let json;
  try {
    json = await (await fetch(chrome.runtime.getURL("theme.json"), { cache: "no-store" })).text();
  } catch {
    return;
  }
  if (!ramps.length) ramps = readRamps(); // Discord's main stylesheet may not be parsed yet at document_start
  if (!ramps.length || json === lastJson) return;
  lastJson = json;

  const theme = JSON.parse(json);
  const decls = [`color-scheme: ${theme.scheme}`];
  for (const [prop, family, light] of ramps) {
    const value = theme.grayFamilies.includes(family) ? theme.gray[Math.round(light * 10)]
      : theme.hues[family] ? `${theme.hues[family]} ${light}%`
      : theme.flats[family];
    if (value) decls.push(`${prop}: ${value}`);
  }
  style.textContent = `:root {\n${decls.map((d) => `  ${d} !important;`).join("\n")}\n}`;
  if (!style.isConnected) (document.head || document.documentElement).append(style);
}

tick();
setInterval(tick, 2000);
