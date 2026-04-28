<div align="center">

<img src="assets/banner.png" alt="Super Marius" width="100%" />

# 🦸 Super Marius

### *Give your AI agent hands.*

**One command. Your AI assistant can now click, type, and see your Mac screen.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![macOS](https://img.shields.io/badge/macOS-Tahoe%20compatible-blue)](https://github.com/autosolutionsai-didac/super-marius)
[![Works with](https://img.shields.io/badge/works%20with-Claude%20Code%20%7C%20Cowork%20%7C%20OpenClaw-purple)](https://github.com/autosolutionsai-didac/super-marius)

</div>

---

## What is this? (plain English)

You know how AI assistants like Claude can write code, search the web, and read your files?
**Super Marius lets them do something else: actually *use* your Mac.**

That means an AI agent can:

- 🖱️ **Click on things** for you — buttons, menus, app icons
- ⌨️ **Type into fields** — emails, forms, search boxes
- 📸 **See what's on your screen** — by taking screenshots
- 🪟 **Open apps and switch between them** — Mail, Notes, Safari, anything
- 🎯 **Press keyboard shortcuts** — Cmd+C, Cmd+S, the works

Think of it as **giving your AI assistant a physical body on your Mac**. You ask it to do something, and it actually does it — instead of just telling you the steps.

> **Example:** "Open Notes and write me a shopping list with eggs, milk, and bread."
>
> The AI literally opens Notes, creates a new note, and types the list. You watch it happen.

---

## Why does this exist?

Apple recently updated macOS (the "Tahoe" release) with new security rules. The old way of letting AI agents control a Mac — using a small command-line tool called `cliclick` — **stopped working overnight**. macOS now silently rejects it.

Super Marius is the workaround. It uses **Hammerspoon**, a free Mac automation app that Apple *does* trust because it's properly signed. Super Marius bundles up that workaround into a 30-second install, plus a clean little command called `mac` that any AI agent can use.

---

## What's in the box

```
mac click 500 300            ← click anywhere
mac type "hello world"       ← type text
mac screenshot               ← capture the screen
mac focus "Safari"           ← bring an app to front
mac key cmd-c                ← press a keyboard shortcut
mac apps                     ← list what's running
```

Plus a SKILL file that tells AI agents *when* to use these — so they automatically know to use Super Marius the moment you ask them to "open Mail" or "click that button."

---

## How to install

### Easy way (any Mac, any AI agent)

Open Terminal on your Mac and paste:

```bash
git clone https://github.com/autosolutionsai-didac/super-marius
cd super-marius
bash openclaw-install.sh
```

The installer will:

1. Check that you're on a Mac ✓
2. Install Hammerspoon if you don't already have it
3. Set everything up
4. **Tell you the one thing you need to do manually** (Apple won't let installers grant security permissions automatically — you'll need to flip two switches in System Settings, the installer prints exactly which ones)

### For Claude Code users

```
/plugin marketplace add autosolutionsai-didac/super-marius
/plugin install super-marius@super-marius
```

### For Cowork users

Drag the `super-marius.plugin` file (in [releases](https://github.com/autosolutionsai-didac/super-marius/releases)) directly onto Cowork.

### For OpenClaw users

Same as the easy way above — `git clone` and run `openclaw-install.sh`.

---

## The one manual step (sorry)

Apple specifically blocks installers from granting security permissions. So after install, **you have to flip two switches yourself** at the keyboard:

1. Open **System Settings → Privacy & Security → Accessibility** → enable **Hammerspoon**
2. Open **System Settings → Privacy & Security → Screen Recording** → enable **Hammerspoon**

That's it. The installer prints these instructions clearly at the end.

---

## When should an AI use this?

✅ **Yes:** Native Mac apps (Mail, Notes, Finder, System Settings, design tools, anything without an API)
✅ **Yes:** Multi-step flows that span several apps
✅ **Yes:** Anything you'd normally do by clicking around the screen

❌ **No:** Browser tasks — there are better tools for those (the AI will know to use Playwright instead)
❌ **No:** Anything you can do from the command line — the AI should just run a command
❌ **No:** Anything that has a real API — the AI should call it directly

Super Marius is the **last resort** for an AI agent — used when there's no faster, more reliable way. Which is exactly when it's most magical.

---

## How it works (for the curious)

```
your AI agent
    └── runs:  mac click 500 300
        └── shell wrapper at ~/.local/bin/mac
            └── hs -c '<lua>'              ← Hammerspoon's CLI
                └── Hammerspoon.app          ← signed app, Apple-approved
                    └── CGEventPost            ← actually moves the cursor
```

Super Marius is intentionally **tiny** — about 100 lines of shell script and one config file. It's just a polite wrapper around Hammerspoon, which does all the heavy lifting.

---

## What's actually in this repo?

```
super-marius/
├── assets/
│   └── banner.png                       ← that hero image up top
├── .claude-plugin/
│   └── marketplace.json                 ← plugin marketplace catalog
├── super-marius/                        ← the plugin itself
│   ├── .claude-plugin/plugin.json       ← plugin manifest
│   ├── skills/super-marius/SKILL.md     ← what the AI reads to know how to use it
│   ├── bin/mac                          ← the actual command-line tool
│   └── README.md
├── openclaw-install.sh                  ← the installer
└── README.md                            ← this file
```

---

## License

MIT — use it, fork it, ship it, commercialise it. Just don't blame us if your AI agent buys you 47 cans of tuna by mistake.

---

<div align="center">

**Built with 🦸 by an AI agent that wanted hands, and got them.**

[Report an issue](https://github.com/autosolutionsai-didac/super-marius/issues)
·
[See the source](https://github.com/autosolutionsai-didac/super-marius/tree/main/super-marius)

</div>
