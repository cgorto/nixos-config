#!/usr/bin/env bash
# Stage the irreplaceable-core backup before the NixOS swap.
# Usage: ./backup-core.sh /path/to/backup/destination
# Run this on the BAZZITE HOST (not inside the distrobox).
set -euo pipefail

DEST="${1:?usage: backup-core.sh <destination dir>}"
DEST="$DEST/bazzite-backup-$(date +%Y%m%d)"
mkdir -p "$DEST"

HOME_DIR="${HOME}"
RSYNC="rsync -aR --info=progress2"

echo ">>> backing up to $DEST"
cd "$HOME_DIR"

# --- irreplaceable core ---
$RSYNC \
  ./.ssh \
  ./Documents \
  ./Pictures \
  ./.local/share/kwalletd \
  ./.config/niri ./.config/fish ./.config/git ./.config/gh \
  ./.config/helix ./.config/ghostty ./.config/fuzzel \
  ./.config/waybar ./.config/mako ./.config/MangoHud \
  ./.config/zed ./.config/sublime-text ./.config/weechat \
  ./.config/godot ./.config/lutris \
  "$DEST/" 2>/dev/null || true

# --- game saves (non-steam) ---
$RSYNC \
  ./.barony ./.runelite ./.ironwail ./.alephone \
  ./.local/share/osu \
  ./.local/share/lutris ./.local/share/umu \
  ./.var/app/at.vintagestory.VintageStory \
  "$DEST/" 2>/dev/null || true

# --- app state ---
$RSYNC \
  ./.var/app/org.mozilla.firefox/.mozilla \
  ./.var/app/md.obsidian.Obsidian/config \
  ./.var/app/com.obsproject.Studio/config \
  ./.local/share/fonts \
  ./.claude ./.claude.json ./.codex ./.pi ./.opencode ./.gemini \
  "$DEST/" 2>/dev/null || true

# --- projects outside ~/dev ---
$RSYNC \
  ./blender \
  ./"My project" \
  "$DEST/" 2>/dev/null || true

echo
echo ">>> done. size:"
du -sh "$DEST"
echo
echo ">>> NOT backed up (survives in the home subvolume, or intentionally dropped):"
echo "    kept in-place: ~/dev ~/Downloads ~/.local/share/Steam"
echo "    dropped:       ~/Unity ~/Games ~/Calibre* recordings Chrome .cache Trash toolchains"
echo
echo ">>> reminder: ~/.claude-science (15G) was excluded - add it manually if needed"
