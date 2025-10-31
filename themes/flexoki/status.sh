#!/usr/bin/env bash

if [ ${#PALETTE[@]} -eq 0 ]; then
  echo "Warning: Flexoki Light palette not loaded. Colors may not display correctly."
fi

#+----------------+
#+ Plugin Support +
#+----------------+
#+--- tmux-prefix-highlight ---+
tmux set -g @prefix_highlight_fg "${PALETTE[bg]}"
tmux set -g @prefix_highlight_bg "${PALETTE[green]}"

#+---------+
#+ Options +
#+---------+
tmux set -g status-interval 1
tmux set -g status on

#+--------+
#+ Status +
#+--------+
#+--- Layout ---+
tmux set -g status-justify left

#+--- Colors ---+
tmux set -g status-style "bg=${PALETTE[bg1]},fg=${PALETTE[fg]}"

#+-------+
#+ Panes +
#+-------+
tmux set -g pane-border-style "bg=default,fg=${PALETTE[base_150]}"
tmux set -g pane-active-border-style "bg=default,fg=${PALETTE[blue]}"
tmux set -g display-panes-colour "${PALETTE[bg]}"
tmux set -g display-panes-active-colour "${PALETTE[fg_gutter]}"

#+------------+
#+ Clock Mode +
#+------------+
tmux setw -g clock-mode-colour "${PALETTE[blue]}"

#+----------+
#+ Messages +
#+---------+
tmux set -g message-style "bg=${PALETTE[bg1]},fg=${PALETTE[fg]}"
tmux set -g message-command-style "bg=${PALETTE[base_150]},fg=${PALETTE[fg]}"
