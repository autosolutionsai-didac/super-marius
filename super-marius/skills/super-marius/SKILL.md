---
name: super-marius
description: >
  Control the macOS desktop — move/click the mouse, type text, send key
  combos, take screenshots, focus apps, query windows. Use when the user asks
  you to "click on", "open", "type into", "screenshot", or otherwise interact
  with native macOS apps that aren't a browser. (For browser tasks prefer
  Playwright MCP — DOM-based clicking is dramatically more reliable than
  pixel-clicking a browser window.)
---

# super-marius

Wrapper around Hammerspoon (`hs` CLI) that lets an agent drive a Mac's GUI.
Designed to work under macOS Tahoe (which blocks ad-hoc-signed CLI binaries
like `cliclick` from the TCC Accessibility panel).

## Architecture

```
agent
  └── shell command: mac <subcommand>
        └── ~/.local/bin/mac
              └── hs -c '<lua>'
                    └── Hammerspoon.app  ← TCC-granted (Accessibility + Screen Recording)
                          └── CGEventPost / hs.eventtap / hs.mouse / hs.screen
```

Why Hammerspoon and not `cliclick`? Hammerspoon ships as a properly signed
`.app` bundle, so macOS Tahoe accepts it in the TCC Accessibility list. CLI
binaries with ad-hoc/linker signatures (like cliclick) are silently rejected
by Tahoe's TCC system.

## CLI reference

| Command | Description |
|---|---|
| `mac click X Y` | Left-click at coordinates |
| `mac rclick X Y` | Right-click |
| `mac dclick X Y` | Double-click |
| `mac mouse X Y` | Move cursor without clicking |
| `mac pos` | Print current cursor position |
| `mac scroll DX DY` | Scroll wheel by pixels (+y = up) |
| `mac type "text"` | Type a string |
| `mac key cmd-c` | Press key combo (modifiers separated by `-`) |
| `mac screenshot [path]` | Capture full screen → PNG (uses Hammerspoon, NOT `screencapture` — see below) |
| `mac screen` | Main screen size and position |
| `mac windows` | List all visible windows |
| `mac apps` | List running apps that have UI |
| `mac focus "Safari"` | Bring an app to front |
| `mac say "msg"` | Show on-screen alert |
| `mac eval 'lua...'` | Raw Hammerspoon Lua escape hatch |

Coordinates are in screen pixels (origin top-left, including the menu bar).

## Workflow tips

1. **Always screenshot first** when starting an interaction so you know what's
   on screen.
2. **Focus the target app before clicking** — `mac focus "AppName"` then click.
   Otherwise clicks may go to whatever happens to be frontmost.
3. **Prefer key combos over clicks** when possible. `mac key cmd-w` is more
   robust than finding the close-button pixel.
4. **For typing into a field**: focus the field with a click, then `mac type`.
5. **Multi-step operations**: chain commands with `&&`, but consider small
   sleeps between actions if the UI animates (`sleep 0.3`).

## Screenshots: why we use Hammerspoon, not `screencapture`

The standard `/usr/sbin/screencapture` requires Screen Recording grant for
the *responsible process* — which, when invoked by a launchd-spawned agent,
is the agent's parent process (e.g. `node`), not Terminal. Granting Screen
Recording to `node` is messy. So we route through Hammerspoon, which has its
own Screen Recording grant via being a proper signed `.app`.

## Setup verification

After install + TCC grants:

```bash
mac say "hello"           # alert should pop on screen
mac screenshot /tmp/x.png # should produce a real PNG
mac pos                   # should return current cursor coords
```

If `hs` errors with "can't access Hammerspoon message port", Hammerspoon
needs to be running with the IPC module loaded. The installer writes
`require("hs.ipc")` to `~/.hammerspoon/init.lua`. Open Hammerspoon.app and
reload config from the menu bar if needed.

## When NOT to use this skill

- **Browser tasks** → use Playwright MCP (`mcp__playwright__*`) — DOM-based
  is dramatically more reliable than coordinate clicks.
- **File/terminal operations** → use Bash directly.
- **Things that have a CLI** → use the CLI. Computer-use is the *last* resort.
