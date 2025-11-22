#!/usr/bin/env bash

if [ ${#PALETTE[@]} -eq 0 ]; then
  echo "Warning: Ethereal palette not loaded."
fi

DATE_FORMAT=$(tmux show-environment -g THEME_DATE_FORMAT 2>/dev/null | cut -d= -f2-)
TIME_FORMAT=$(tmux show-environment -g THEME_TIME_FORMAT 2>/dev/null | cut -d= -f2-)

DATE_FORMAT=${DATE_FORMAT:-"%Y-%m-%d"}
TIME_FORMAT=${TIME_FORMAT:-"%H:%M"}

# Prefix highlight
tmux set -g @prefix_highlight_output_prefix "#[fg=${PALETTE[blue5]}]#[bg=${PALETTE[bg]}]#[bg=${PALETTE[blue5]}]#[fg=${PALETTE[bg]}]"
tmux set -g @prefix_highlight_output_suffix ""
tmux set -g @prefix_highlight_copy_mode_attr "fg=${PALETTE[blue5]},bg=${PALETTE[bg]},bold"

# Bars
tmux set -g status-left "#[fg=${PALETTE[bg]},bg=${PALETTE[green]},bold] 󰌌 #S #[fg=${PALETTE[green]},bg=${PALETTE[bg]}]"

tmux set -g status-right "#{prefix_highlight}\
#[fg=${PALETTE[blue7]},bg=${PALETTE[bg]}]\
#[fg=${PALETTE[white]},bg=${PALETTE[blue7]}] 󰃭 ${DATE_FORMAT} \
#[fg=${PALETTE[white]},bg=${PALETTE[blue7]}]\
#[fg=${PALETTE[white]},bg=${PALETTE[blue7]}] 󰥔 ${TIME_FORMAT} \
#[fg=${PALETTE[blue]},bg=${PALETTE[blue7]}]\
#[fg=${PALETTE[bg]},bg=${PALETTE[blue]},bold] #H "

# Windows
tmux set -g window-status-format "\
#[fg=${PALETTE[bg]},bg=${PALETTE[blue]}] #[fg=${PALETTE[white]},bg=${PALETTE[blue]}]#I \
#[fg=${PALETTE[white]},bg=${PALETTE[blue]}] #[fg=${PALETTE[white]},bg=${PALETTE[blue]}]#W #F \
#[fg=${PALETTE[blue]},bg=${PALETTE[bg]}]"

tmux set -g window-status-current-format "\
#[fg=${PALETTE[bg]},bg=${PALETTE[yellow]}] #[fg=${PALETTE[bg]},bg=${PALETTE[yellow]}]#I \
#[fg=${PALETTE[bg]},bg=${PALETTE[yellow]}] #[fg=${PALETTE[bg]},bg=${PALETTE[yellow]}]#W #F \
#[fg=${PALETTE[yellow]},bg=${PALETTE[bg]}]"

tmux set -g window-status-separator ""
