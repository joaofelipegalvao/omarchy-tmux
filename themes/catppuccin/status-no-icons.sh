#!/usr/bin/env bash

if [ ${#PALETTE[@]} -eq 0 ]; then
  echo "Warning: Catppuccin palette not loaded. Colors may not display correctly."
fi

#+----------------+
#+ Plugin Support +
#+----------------+
#+--- tmux-prefix-highlight ---+
tmux set -g @prefix_highlight_output_prefix "\
#[fg=${PALETTE[magenta]}]#[bg=${PALETTE[bg]}]#[nobold]#[noitalics]#[nounderscore]\
#[bg=${PALETTE[magenta]}]#[fg=${PALETTE[bg]}]"
tmux set -g @prefix_highlight_output_suffix ""
tmux set -g @prefix_highlight_copy_mode_attr \
  "fg=${PALETTE[magenta]},bg=${PALETTE[bg]},bold"

#+--------+
#+ Status +
#+--------+
#+--- Bars ---+
tmux set -g status-left "\
#[fg=${PALETTE[bg]},bg=${PALETTE[green]},bold]\
#[fg=${PALETTE[bg]},bg=${PALETTE[green]}] #S \
#[fg=${PALETTE[green]},bg=${PALETTE[bg]},nobold,noitalics,nounderscore]"

tmux set -g status-right "\
#{prefix_highlight}\
#[fg=${PALETTE[magenta]},bg=${PALETTE[bg]},nobold,noitalics,nounderscore]\
#[fg=${PALETTE[bg]},bg=${PALETTE[magenta]}]\
#[fg=${PALETTE[bg_highlight]},bg=${PALETTE[magenta]},nobold,noitalics,nounderscore]\
#[fg=${PALETTE[fg]},bg=${PALETTE[bg_highlight]}] %d/%m %H:%M \
#[fg=${PALETTE[bg]},bg=${PALETTE[bg_highlight]},nobold,noitalics,nounderscore]\
#[fg=${PALETTE[bg]},bg=${PALETTE[bg]}]\
#[fg=${PALETTE[magenta]},bg=${PALETTE[bg]},nobold,noitalics,nounderscore]\
#[fg=${PALETTE[bg]},bg=${PALETTE[magenta]},bold] #H "

#+--- Windows ---+
tmux set -g window-status-format "\
#[fg=${PALETTE[bg]},bg=${PALETTE[bg_highlight]},nobold,noitalics,nounderscore]\
#[fg=${PALETTE[fg]},bg=${PALETTE[bg_highlight]}] #I \
#[fg=${PALETTE[bg_highlight]},bg=${PALETTE[terminal_black]},nobold,noitalics,nounderscore]\
#[fg=${PALETTE[fg]},bg=${PALETTE[terminal_black]}] #W \
#[fg=${PALETTE[terminal_black]},bg=${PALETTE[bg]},nobold,noitalics,nounderscore]"

tmux set -g window-status-current-format "\
#[fg=${PALETTE[bg]},bg=${PALETTE[magenta]},nobold,noitalics,nounderscore]\
#[fg=${PALETTE[fg]},bg=${PALETTE[magenta]}] #I \
#[fg=${PALETTE[magenta]},bg=${PALETTE[blue]},nobold,noitalics,nounderscore]\
#[fg=${PALETTE[fg]},bg=${PALETTE[blue]}] #W \
#[fg=${PALETTE[blue]},bg=${PALETTE[bg]},nobold,noitalics,nounderscore]"
tmux set -g window-status-separator ""
