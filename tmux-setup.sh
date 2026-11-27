#!/usr/bin/env bash
# Quick tmux setup for HTB Pwnbox: mouse scroll, drag-select -> clipboard, big scrollback.
# Usage: curl -sL https://raw.githubusercontent.com/anthoai97/red-hand-on-scripts/main/tmux-setup.sh | bash

SCRIPT_VERSION=2
CONF="$HOME/.tmux.conf"

echo "[*] tmux-setup v$SCRIPT_VERSION"

if ! command -v tmux >/dev/null 2>&1; then
  echo "[!] tmux is not installed"; exit 1
fi

# --- Clipboard tool (Pwnbox normally has xclip) ---
if ! command -v xclip >/dev/null 2>&1 && ! command -v xsel >/dev/null 2>&1; then
  echo "[*] Installing xclip..."
  # </dev/null so apt can't eat the rest of the script when run via curl | bash
  if ! { sudo apt-get update -qq && sudo apt-get install -y -qq xclip; } </dev/null >/dev/null 2>&1; then
    echo "[!] xclip install failed"
  fi
fi

if command -v xclip >/dev/null 2>&1; then
  CLIP="xclip -in -selection clipboard >/dev/null 2>&1"
elif command -v xsel >/dev/null 2>&1; then
  CLIP="xsel --clipboard --input >/dev/null 2>&1"
else
  CLIP=""
fi

# copy-pipe-no-clear (tmux >= 3.2) keeps the highlight visible after you release the mouse
TMUX_VER=$(tmux -V | grep -oE '[0-9]+\.[0-9]+' | head -1)
if printf '%s\n3.2\n' "$TMUX_VER" | sort -V -C 2>/dev/null && [ "$TMUX_VER" != "3.2" ]; then
  COPY_MOUSE="copy-pipe"            # older tmux
else
  COPY_MOUSE="copy-pipe-no-clear"
fi

# --- Back up old config (handles a symlinked ~/.tmux.conf) ---
if [ -e "$CONF" ] || [ -L "$CONF" ]; then
  cp -L "$CONF" "$CONF.bak.$(date +%s)" 2>/dev/null
  rm -f "$CONF"
fi

cat > "$CONF" <<'EOF'
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
# Drag = select + copy (highlight stays; press q or scroll down to leave copy mode)
bind -T copy-mode-vi MouseDragEnd1Pane send -X $COPY_MOUSE "$CLIP"
# Double-click = copy word, triple-click = copy line
bind -T root        DoubleClick1Pane select-pane \\; copy-mode -M \\; send -X select-word \\; send -X $COPY_MOUSE "$CLIP"
bind -T copy-mode-vi DoubleClick1Pane select-pane \\; send -X select-word \\; send -X $COPY_MOUSE "$CLIP"
bind -T root        TripleClick1Pane select-pane \\; copy-mode -M \\; send -X select-line \\; send -X $COPY_MOUSE "$CLIP"
bind -T copy-mode-vi TripleClick1Pane select-pane \\; send -X select-line \\; send -X $COPY_MOUSE "$CLIP"
# Keyboard: v to start, y or Enter to copy
bind -T copy-mode-vi y     send -X copy-pipe-and-cancel "$CLIP"
bind -T copy-mode-vi Enter send -X copy-pipe-and-cancel "$CLIP"
set -s set-clipboard on
EOF
fi

# --- Apply to a running tmux server, if any ---
if tmux list-sessions >/dev/null 2>&1; then
  if tmux source-file "$CONF"; then
    echo "[+] Reloaded running tmux"
  else
    echo "[!] tmux failed to load $CONF"
  fi
fi

echo "[+] Wrote $CONF"
echo "    tmux $TMUX_VER | clipboard: ${CLIP%% *} | DISPLAY=${DISPLAY:-<unset>}"
[ -z "$CLIP" ] && echo "[!] No clipboard tool: copies only go to the tmux buffer (paste with Ctrl-b ])"
echo "    - Scroll: mouse wheel"
echo "    - Copy:   drag to select (or double/triple-click), then paste with Ctrl+Shift+V"
echo "    - Shift+drag uses the terminal's own selection instead of tmux"
