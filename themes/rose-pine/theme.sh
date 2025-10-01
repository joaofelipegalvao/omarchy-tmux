#!/usr/bin/env bash

#+----------------+
#+ Plugin Support +
#+----------------+
#+--- tmux-prefix-highlight ---+
tmux set -g @prefix_highlight_fg "${PALETTE[teal]}"
tmux set -g @prefix_highlight_bg "${PALETTE[bg]}"

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
tmux set -g status-style "bg=${PALETTE[bg]},fg=${PALETTE[fg]}"

#+--- Windows ---+
tmux set -g window-status-style "bg=${PALETTE[bg_highlight]},fg=${PALETTE[fg_dark]}"
tmux set -g window-status-current-style "bg=${PALETTE[teal]},fg=${PALETTE[bg]},bold"

#+-------+
#+ Panes +
#+-------+
tmux set -g pane-border-style "bg=default,fg=${PALETTE[fg_gutter]}"
tmux set -g pane-active-border-style "bg=default,fg=${PALETTE[teal]}"
tmux set -g display-panes-colour "${PALETTE[bg]}"
tmux set -g display-panes-active-colour "${PALETTE[fg]}"

#+------------+
#+ Clock Mode +
#+------------+
tmux setw -g clock-mode-colour "${PALETTE[teal]}"

#+----------+
#+ Messages +
#+----------+
tmux set -g message-style "bg=${PALETTE[bg_highlight]},fg=${PALETTE[teal]}"
tmux set -g message-command-style "bg=${PALETTE[bg_highlight]},fg=${PALETTE[teal]}"
