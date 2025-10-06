#!/usr/bin/env bash

DATE_FORMAT=$(tmux show-environment -g THEME_DATE_FORMAT 2>/dev/null | cut -d= -f2-)
TIME_FORMAT=$(tmux show-environment -g THEME_TIME_FORMAT 2>/dev/null | cut -d= -f2-)

DATE_FORMAT=${DATE_FORMAT:-"%Y-%m-%d"}
TIME_FORMAT=${TIME_FORMAT:-"%H:%M"}

#+----------------+
#+ Plugin Support +
#+----------------+
#+--- tmux-prefix-highlight ---+
tmux set -g @prefix_highlight_output_prefix "#[fg=${PALETTE[purple]}]#[bg=${PALETTE[bg]}]#[nobold]#[noitalics]#[nounderscore]#[bg=${PALETTE[purple]}]#[fg=${PALETTE[bg]}]"
tmux set -g @prefix_highlight_output_suffix ""
tmux set -g @prefix_highlight_copy_mode_attr "fg=${PALETTE[purple]},bg=${PALETTE[bg]},bold"

#+--------+
#+ Status +  
#+--------+
#+--- Bars ---+
tmux set -g status-left "#[fg=${PALETTE[bg]},bg=${PALETTE[green]},bold] 󰌌 #S #[fg=${PALETTE[green]},bg=${PALETTE[bg]},nobold,noitalics,nounderscore]"
tmux set -g status-right "#{prefix_highlight}#[fg=${PALETTE[bg_highlight]},bg=${PALETTE[bg]},nobold,noitalics,nounderscore]#[fg=${PALETTE[fg]},bg=${PALETTE[bg_highlight]}] 󰃭 ${DATE_FORMAT} #[fg=${PALETTE[fg]},bg=${PALETTE[bg_highlight]},nobold,noitalics,nounderscore]#[fg=${PALETTE[fg]},bg=${PALETTE[bg_highlight]}] 󰥔 ${TIME_FORMAT} #[fg=${PALETTE[cyan]},bg=${PALETTE[bg_highlight]},nobold,noitalics,nounderscore]#[fg=${PALETTE[bg]},bg=${PALETTE[cyan]},bold] #H "

#+--- Windows ---+
tmux set -g window-status-format "#[fg=${PALETTE[bg]},bg=${PALETTE[bg_highlight]},nobold,noitalics,nounderscore] #[fg=${PALETTE[fg]},bg=${PALETTE[bg_highlight]}]#I #[fg=${PALETTE[fg]},bg=${PALETTE[bg_highlight]},nobold,noitalics,nounderscore] #[fg=${PALETTE[fg]},bg=${PALETTE[bg_highlight]}]#W #F #[fg=${PALETTE[bg_highlight]},bg=${PALETTE[bg]},nobold,noitalics,nounderscore]"
tmux set -g window-status-current-format "#[fg=${PALETTE[bg]},bg=${PALETTE[purple]},nobold,noitalics,nounderscore] #[fg=${PALETTE[bg]},bg=${PALETTE[purple]}]#I #[fg=${PALETTE[bg]},bg=${PALETTE[purple]},nobold,noitalics,nounderscore] #[fg=${PALETTE[bg]},bg=${PALETTE[purple]}]#W #F #[fg=${PALETTE[purple]},bg=${PALETTE[bg]},nobold,noitalics,nounderscore]"
tmux set -g window-status-separator ""
