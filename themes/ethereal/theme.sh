#!/usr/bin/env bash

if [ ${#PALETTE[@]} -eq 0 ]; then
  echo "Warning: Ethereal palette not loaded."
fi

# Options
tmux set -g status-interval 1
tmux set -g status on
tmux set -g status-justify left

# Status bar
tmux set -g status-style "bg=${PALETTE[bg]},fg=${PALETTE[fg]}"

# Panes
tmux set -g pane-border-style "bg=default,fg=${PALETTE[fg_gutter]}"
tmux set -g pane-active-border-style "bg=default,fg=${PALETTE[blue]}"
tmux set -g display-panes-colour "${PALETTE[bg]}"
tmux set -g display-panes-active-colour "${PALETTE[fg_gutter]}"

# Clock
tmux setw -g clock-mode-colour "${PALETTE[blue]}"

# Messages
tmux set -g message-style "bg=${PALETTE[bg_highlight]},fg=${PALETTE[blue]}"
tmux set -g message-command-style "bg=${PALETTE[bg_highlight]},fg=${PALETTE[blue]}"
