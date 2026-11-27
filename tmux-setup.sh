#!/usr/bin/env bash
# Quick tmux setup for HTB Pwnbox: mouse scroll, mouse select -> clipboard, big scrollback.
# Usage: bash tmux-setup.sh

set -e

CONF="$HOME/.tmux.conf"

# Pick a clipboard tool (Pwnbox normally has xclip)
if command -v xclip >/dev/null 2>&1; then
  CLIP="xclip -in -selection clipboard"
elif command -v xsel >/dev/null 2>&1; then
  CLIP="xsel --clipboard --input"
else
  echo "[*] xclip not found, trying to install..."
  sudo apt-get install -y xclip >/dev/null 2>&1 && CLIP="xclip -in -selection clipboard" || CLIP=""
fi

[ -f "$CONF" ] && cp "$CONF" "$CONF.bak.$(date +%s)"

cat > "$CONF" <<EOF
# --- Mouse: scroll wheel, click panes, drag to select ---
set -g mouse on
set -g history-limit 50000

# --- vi keys in copy mode ---
setw -g mode-keys vi
bind -T copy-mode-vi v send -X begin-selection
EOF

if [ -n "$CLIP" ]; then
  cat >> "$CONF" <<EOF

# --- Copy selection to system clipboard ---
bind -T copy-mode-vi y send -X copy-pipe-and-cancel "$CLIP"
bind -T copy-mode-vi Enter send -X copy-pipe-and-cancel "$CLIP"
bind -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe-and-cancel "$CLIP"
set -s set-clipboard on
EOF
else
  echo "[!] No clipboard tool available; selections will only go to the tmux buffer (paste with Ctrl-b ])."
fi

# Apply to a running tmux server, if any
if tmux info >/dev/null 2>&1; then
  tmux source-file "$CONF" && echo "[+] Reloaded running tmux"
fi

echo "[+] Wrote $CONF"
echo "    - Scroll with mouse wheel"
echo "    - Drag to select -> copied to clipboard on release"
echo "    - Hold Shift while dragging to use the terminal's native selection"
