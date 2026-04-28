# super-marius

🦸 **Super Marius** — let an agent click, type, and screenshot on your Mac.
Hammerspoon-based desktop automation, Tahoe-compatible.

## What this gives the agent

A `mac` CLI in `~/.local/bin/`:

```
mac click X Y            mac type "text"        mac screenshot [path]
mac dclick X Y           mac key cmd-c          mac screen
mac rclick X Y           mac scroll DX DY       mac windows
mac mouse X Y            mac pos                mac apps
                                                mac focus "AppName"
                                                mac say "msg"
                                                mac eval 'lua...'
```

Plus a SKILL.md that auto-triggers when the user asks the agent to interact
with native macOS apps.

## Architecture

```
agent
  └── mac <subcommand>           ← shell wrapper at ~/.local/bin/mac
        └── hs -c '<lua>'        ← Hammerspoon CLI
              └── Hammerspoon.app ← signed app, TCC-granted
                    └── CGEventPost / hs.eventtap / hs.mouse / hs.screen
```

Hammerspoon is used (not `cliclick`) because macOS Tahoe rejects
ad-hoc-signed CLI binaries from the TCC Accessibility panel. Hammerspoon
ships as a proper signed `.app`, so it works.

## Install (Cowork / Claude Code)

```
/plugin marketplace add autosolutionsai-didac/super-marius
/plugin install super-marius@super-marius
```

Then run the post-install setup (the installer writes the wrapper but you
must grant TCC permissions yourself):

```bash
bash openclaw-install.sh    # also works for non-OpenClaw setups; it's a generic installer
```

## Install (OpenClaw)

```bash
git clone https://github.com/autosolutionsai-didac/super-marius
cd super-marius
bash openclaw-install.sh
```

## Manual TCC setup (required, can't be automated)

After install, you MUST grant Hammerspoon two permissions in System Settings.
macOS specifically blocks programmatic TCC grants — you have to do this at
the keyboard:

1. **System Settings → Privacy & Security → Accessibility** → enable Hammerspoon
2. **System Settings → Privacy & Security → Screen Recording** → enable Hammerspoon

Then verify:

```bash
mac say "hello"             # should pop an on-screen alert
mac screenshot /tmp/x.png   # should produce a real PNG
```

## When the agent should use this

✅ Native macOS apps (Mail, Notes, Finder, System Settings)
✅ GUI-only tools without a CLI/API
✅ End-to-end flows that span multiple apps

## When the agent should NOT use this

❌ Browser tasks — use Playwright MCP (DOM-based is much more reliable)
❌ Anything with a CLI — use Bash
❌ Anything with an API — call the API

Computer-use is the *last* resort.
