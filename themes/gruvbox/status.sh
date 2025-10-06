#!/usr/bin/env bash

DATE_FORMAT=$(tmux show-environment -g THEME_DATE_FORMAT 2>/dev/null | cut -d= -f2-)
TIME_FORMAT=$(tmux show-environment -g THEME_TIME_FORMAT 2>/dev/null | cut -d= -f2-)

DATE_FORMAT=${DATE_FORMAT:-"%Y-%m-%d"}
TIME_FORMAT=${TIME_FORMAT:-"%H:%M"}

#+----------------+
#+ Plugin Support +
#+----------------+
#+--- tmux-prefix-highlight ---+
tmux set -g @prefix_highlight_output_prefix "#[fg=${PALETTE[yellow_bright]}]#[bg=${PALETTE[bg]}]#[nobold]#[noitalics]#[nounderscore]#[bg=${PALETTE[yellow_bright]}]#[fg=${PALETTE[bg]}]"
tmux set -g @prefix_highlight_output_suffix ""
tmux set -g @prefix_highlight_copy_mode_attr "fg=${PALETTE[yellow_bright]},bg=${PALETTE[bg]},bold"

#+--------+
#+ Status +  
#+--------+
#+--- Bars ---+
tmux set -g status-left "#[fg=${PALETTE[bg]},bg=${PALETTE[green_bright]},bold] 󰌌 #S #[fg=${PALETTE[green_bright]},bg=${PALETTE[bg]},nobold,noitalics,nounderscore]"
tmux set -g status-right "#{prefix_highlight}#[fg=${PALETTE[bg1]},bg=${PALETTE[bg]},nobold,noitalics,nounderscore]#[fg=${PALETTE[fg]},bg=${PALETTE[bg1]}] 󰃭 ${DATE_FORMAT} #[fg=${PALETTE[fg]},bg=${PALETTE[bg1]},nobold,noitalics,nounderscore]#[fg=${PALETTE[fg]},bg=${PALETTE[bg1]}] 󰥔 ${TIME_FORMAT} #[fg=${PALETTE[yellow_bright]},bg=${PALETTE[bg1]},nobold,noitalics,nounderscore]#[fg=${PALETTE[bg]},bg=${PALETTE[yellow_bright]},bold] #H "

#+--- Windows ---+
tmux set -g window-status-format "#[fg=${PALETTE[bg]},bg=${PALETTE[bg2]},nobold,noitalics,nounderscore] #[fg=${PALETTE[fg]},bg=${PALETTE[bg2]}]#I #[fg=${PALETTE[fg]},bg=${PALETTE[bg2]},nobold,noitalics,nounderscore] #[fg=${PALETTE[fg]},bg=${PALETTE[bg2]}]#W #F #[fg=${PALETTE[bg2]},bg=${PALETTE[bg]},nobold,noitalics,nounderscore]"
tmux set -g window-status-current-format "#[fg=${PALETTE[bg]},bg=${PALETTE[yellow_bright]},nobold,noitalics,nounderscore] #[fg=${PALETTE[bg]},bg=${PALETTE[yellow_bright]}]#I #[fg=${PALETTE[bg]},bg=${PALETTE[yellow_bright]},nobold,noitalics,nounderscore] #[fg=${PALETTE[bg]},bg=${PALETTE[yellow_bright]}]#W #F #[fg=${PALETTE[yellow_bright]},bg=${PALETTE[bg]},nobold,noitalics,nounderscore]"
tmux set -g window-status-separator ""
