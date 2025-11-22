#!/usr/bin/env bash

if [ ${#PALETTE[@]} -eq 0 ]; then
  echo "Warning: Hackerman palette not loaded."
fi

DATE_FORMAT=${DATE_FORMAT:-"%Y-%m-%d"}
TIME_FORMAT=${TIME_FORMAT:-"%H:%M"}

tmux set -g status-left "#[fg=${PALETTE[bg]},bg=${PALETTE[green]},bold] #S #[fg=${PALETTE[green]},bg=${PALETTE[bg]}]"

tmux set -g status-right "#[fg=${PALETTE[fg]},bg=${PALETTE[bg_highlight]}] ${DATE_FORMAT} ${TIME_FORMAT} #[fg=${PALETTE[bg]},bg=${PALETTE[green]},bold] #H "

tmux set -g window-status-format "#[fg=${PALETTE[bg]},bg=${PALETTE[green]}] #I #W #F #[fg=${PALETTE[green]},bg=${PALETTE[bg]}]"
tmux set -g window-status-current-format "#[fg=${PALETTE[bg]},bg=${PALETTE[blue]}] #I #W #F #[fg=${PALETTE[blue]},bg=${PALETTE[bg]}]"
tmux set -g window-status-separator ""
