#!/bin/bash
# super-marius — OpenClaw installer
#
# Sets up Hammerspoon-based macOS desktop control so the agent can click,
# type, and screenshot. Tahoe-compatible (does not use cliclick).
#
# Idempotent: safe to re-run.

set -e

# ──────────────────────────────────────────────────────────────────────────
# Pre-flight
# ──────────────────────────────────────────────────────────────────────────

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "❌ This plugin is macOS-only (detected: $(uname -s))" >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$SCRIPT_DIR/super-marius"

if [[ ! -d "$PLUGIN_DIR" ]]; then
    echo "❌ Plugin directory not found at: $PLUGIN_DIR" >&2
    echo "   Run this script from the marketplace repo root." >&2
    exit 1
fi

echo "▶ super-marius installer"
echo "  Plugin dir: $PLUGIN_DIR"
echo

# ──────────────────────────────────────────────────────────────────────────
# 1. Homebrew check
# ──────────────────────────────────────────────────────────────────────────

if ! command -v brew >/dev/null 2>&1; then
    echo "❌ Homebrew is required but not installed." >&2
    echo "   Install it first: https://brew.sh" >&2
    exit 1
fi

echo "✓ Homebrew detected: $(brew --version | head -1)"

# ──────────────────────────────────────────────────────────────────────────
# 2. Install Hammerspoon if missing
# ──────────────────────────────────────────────────────────────────────────

if [[ -d "/Applications/Hammerspoon.app" ]]; then
    echo "✓ Hammerspoon already installed"
else
    echo "▶ Installing Hammerspoon..."
    brew install --cask hammerspoon
    echo "✓ Hammerspoon installed"
fi

# ──────────────────────────────────────────────────────────────────────────
# 3. Configure Hammerspoon to load the IPC module (idempotent)
# ──────────────────────────────────────────────────────────────────────────

HS_CONFIG_DIR="$HOME/.hammerspoon"
HS_INIT="$HS_CONFIG_DIR/init.lua"
mkdir -p "$HS_CONFIG_DIR"

if ! grep -q 'require("hs.ipc")' "$HS_INIT" 2>/dev/null && ! grep -q "require('hs.ipc')" "$HS_INIT" 2>/dev/null; then
    {
        echo "-- Added by super-marius installer"
        echo 'require("hs.ipc")'
        echo
    } >> "$HS_INIT"
    echo "✓ Added hs.ipc to $HS_INIT"
else
    echo "✓ hs.ipc already loaded in $HS_INIT"
fi

# ──────────────────────────────────────────────────────────────────────────
# 4. Launch Hammerspoon and reload its config
# ──────────────────────────────────────────────────────────────────────────

if pgrep -lf Hammerspoon >/dev/null 2>&1; then
    echo "✓ Hammerspoon is running"
else
    echo "▶ Launching Hammerspoon..."
    open -a Hammerspoon
    sleep 2
fi

# Trigger config reload via URL handler (works whether or not IPC is up)
open -g 'hammerspoon://reload' >/dev/null 2>&1 || true
sleep 1

# ──────────────────────────────────────────────────────────────────────────
# 5. Install the `mac` wrapper
# ──────────────────────────────────────────────────────────────────────────

mkdir -p "$HOME/.local/bin"
cp "$PLUGIN_DIR/bin/mac" "$HOME/.local/bin/mac"
chmod +x "$HOME/.local/bin/mac"
echo "✓ Installed: $HOME/.local/bin/mac"

# Warn if ~/.local/bin isn't on PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo
    echo "⚠️  $HOME/.local/bin is not on your PATH."
    echo "   Add this to your shell rc:"
    echo "     export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

# ──────────────────────────────────────────────────────────────────────────
# 6. Smoke test (will fail silently if TCC not yet granted — that's expected)
# ──────────────────────────────────────────────────────────────────────────

echo
echo "▶ Smoke test..."
if "$HOME/.local/bin/mac" say "super-marius installed" 2>/dev/null; then
    echo "✓ Hammerspoon IPC working"
else
    echo "ℹ Hammerspoon IPC not responding yet — this is normal before TCC is granted"
fi

# ──────────────────────────────────────────────────────────────────────────
# 7. Manual TCC instructions (cannot be automated)
# ──────────────────────────────────────────────────────────────────────────

cat <<'EOF'

═══════════════════════════════════════════════════════════════════════════
  REQUIRED MANUAL STEP — grant Hammerspoon TCC permissions
═══════════════════════════════════════════════════════════════════════════

macOS blocks programmatic TCC grants. You MUST do this at the keyboard
of the Mac (not over SSH):

  1. Open System Settings → Privacy & Security → Accessibility
     → enable Hammerspoon

  2. Open System Settings → Privacy & Security → Screen Recording
     → enable Hammerspoon

Then verify:

    mac say "hello"               # alert should pop on screen
    mac screenshot /tmp/x.png     # should produce a real PNG
    mac help                      # full command reference

If the smoke-test alert above showed up on screen, TCC is already granted —
you can skip the manual step.

═══════════════════════════════════════════════════════════════════════════

EOF

echo "✓ Done."
