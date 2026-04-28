# Super Marius 🦸

A Claude/OpenClaw plugin marketplace containing one plugin: **super-marius** —
let an agent click, type, and screenshot on your Mac.

## Why this exists

macOS Tahoe tightened TCC so ad-hoc-signed CLI binaries (like `cliclick`) are
silently rejected from the Accessibility panel. The fix: route everything
through Hammerspoon, a properly signed `.app` bundle that macOS will accept.

Super Marius packages that solution: a tiny shell wrapper (`mac`) over
Hammerspoon's `hs` CLI, plus a SKILL.md so agents know to use it.

## Plugin: super-marius

```
mac click X Y            mac type "text"        mac screenshot [path]
mac dclick X Y           mac key cmd-c          mac screen
mac rclick X Y           mac scroll DX DY       mac windows
mac mouse X Y            mac pos                mac apps
                                                mac focus "AppName"
                                                mac say "msg"
                                                mac eval 'lua...'
```

See `super-marius/README.md` for full details.

## Install

### Cowork

Drag the `.plugin` file onto Cowork — it renders as an interactive card you
can install with one click.

### Claude Code

```
/plugin marketplace add autosolutionsai-didac/super-marius
/plugin install super-marius@super-marius
```

After install, run the post-install setup (it installs Hammerspoon and the
wrapper, and prints the manual TCC steps you need to do at the keyboard):

```bash
git clone https://github.com/autosolutionsai-didac/super-marius
bash super-marius/openclaw-install.sh
```

### OpenClaw

```bash
git clone https://github.com/autosolutionsai-didac/super-marius
cd super-marius
bash openclaw-install.sh
```

## Repo structure

```
super-marius/                         ← marketplace repo root
├── .claude-plugin/
│   └── marketplace.json              ← marketplace catalog
├── super-marius/                     ← the plugin (at repo root, not nested)
│   ├── .claude-plugin/
│   │   └── plugin.json               ← plugin manifest
│   ├── skills/
│   │   └── super-marius/
│   │       └── SKILL.md              ← skill that auto-triggers on GUI requests
│   ├── bin/
│   │   └── mac                       ← the CLI wrapper
│   └── README.md
├── openclaw-install.sh               ← installs Hammerspoon + wrapper + TCC instructions
└── README.md                         ← this file
```

## Architecture

```
agent
  └── mac <subcommand>           ← shell wrapper at ~/.local/bin/mac
        └── hs -c '<lua>'        ← Hammerspoon CLI
              └── Hammerspoon.app ← signed app, TCC-granted
                    └── CGEventPost / hs.eventtap / hs.mouse / hs.screen
```

## Manual step you can't avoid

After install, grant Hammerspoon two TCC permissions at the keyboard:

1. **System Settings → Privacy & Security → Accessibility** → enable Hammerspoon
2. **System Settings → Privacy & Security → Screen Recording** → enable Hammerspoon

macOS specifically blocks programmatic TCC grants — there's no way around
this. The installer prints these instructions at the end.

## License

MIT
