#!/usr/bin/env bash

# Options
tmux set -g status-interval 1
tmux set -g status on
tmux set -g status-justify left
tmux set -g status-style "bg=${PALETTE[bg]},fg=${PALETTE[fg]}"

# Panes
tmux set -g pane-border-style "bg=default,fg=${PALETTE[fg_gutter]}"
tmux set -g pane-active-border-style "bg=default,fg=${PALETTE[green]}"
tmux set -g display-panes-colour "${PALETTE[bg]}"
tmux set -g display-panes-active-colour "${PALETTE[fg_gutter]}"

# Clock
tmux setw -g clock-mode-colour "${PALETTE[green]}"

# Messages
tmux set -g message-style "bg=${PALETTE[bg_highlight]},fg=${PALETTE[green]}"
tmux set -g message-command-style "bg=${PALETTE[bg_highlight]},fg=${PALETTE[green]}"
