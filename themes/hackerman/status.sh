#!/usr/bin/env bash

if [ ${#PALETTE[@]} -eq 0 ]; then
  echo "Warning: Hackerman palette not loaded."
fi

DATE_FORMAT=${DATE_FORMAT:-"%Y-%m-%d"}
TIME_FORMAT=${TIME_FORMAT:-"%H:%M"}

# Prefix Highlight (plugin)
tmux set -g @prefix_highlight_output_prefix "#[fg=${PALETTE[green]}]#[bg=${PALETTE[bg]}]#[bg=${PALETTE[green]}]#[fg=${PALETTE[bg]}]"
tmux set -g @prefix_highlight_output_suffix ""
tmux set -g @prefix_highlight_copy_mode_attr "fg=${PALETTE[green]},bg=${PALETTE[bg]},bold"

# Bars
tmux set -g status-left "#[fg=${PALETTE[bg]},bg=${PALETTE[green]},bold] 󰌌 #S #[fg=${PALETTE[green]},bg=${PALETTE[bg]}]"

tmux set -g status-right "#{prefix_highlight}\
#[fg=${PALETTE[bg_highlight]},bg=${PALETTE[bg]}]\
#[fg=${PALETTE[fg]},bg=${PALETTE[bg_highlight]}] 󰃭 ${DATE_FORMAT} \
#[fg=${PALETTE[fg]},bg=${PALETTE[bg_highlight]}]\
#[fg=${PALETTE[fg]},bg=${PALETTE[bg_highlight]}] 󰥔 ${TIME_FORMAT} \
#[fg=${PALETTE[green]},bg=${PALETTE[bg_highlight]}]\
#[fg=${PALETTE[bg]},bg=${PALETTE[green]},bold] #H "

# Windows
tmux set -g window-status-format "#[fg=${PALETTE[bg]},bg=${PALETTE[green]}] #I  #W #F #[fg=${PALETTE[green]},bg=${PALETTE[bg]}]"
tmux set -g window-status-current-format "#[fg=${PALETTE[bg]},bg=${PALETTE[blue]}] #I  #W #F #[fg=${PALETTE[blue]},bg=${PALETTE[bg]}]"
tmux set -g window-status-separator ""
