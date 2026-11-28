#!/usr/bin/env bash
# Quick tmux setup for HTB Pwnbox: mouse scroll, drag-select -> clipboard.
# Usage: curl -sL https://raw.githubusercontent.com/anthoai97/red-hand-on-scripts/main/tmux-setup.sh | bash

echo "[*] tmux-setup v4"

# </dev/null so apt can't eat the rest of the script when run via curl | bash
command -v xclip >/dev/null || { sudo apt-get update -qq && sudo apt-get install -y -qq xclip; } </dev/null >/dev/null 2>&1

cat > ~/.tmux.conf <<'EOF'
set -g mouse on
setw -g mode-keys vi
bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "xclip -in -selection clipboard"

bind v split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
bind x kill-pane
EOF

tmux source-file ~/.tmux.conf 2>/dev/null
echo "[+] Done. Drag to copy, Ctrl+Shift+V to paste. DISPLAY=${DISPLAY:-<unset>}"
