#!/usr/bin/env bash

#+----------------+
#+ Plugin Support +
#+----------------+
#+--- tmux-prefix-highlight ---+
tmux set -g @prefix_highlight_fg "${PALETTE[bg]}"
tmux set -g @prefix_highlight_bg "${PALETTE[teal]}"

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

#+-------+
#+ Panes +
#+-------+
tmux set -g pane-border-style "bg=default,fg=${PALETTE[fg_gutter]}"
tmux set -g pane-active-border-style "bg=default,fg=${PALETTE[teal]}"
tmux set -g display-panes-colour "${PALETTE[bg]}"
tmux set -g display-panes-active-colour "${PALETTE[fg_gutter]}"

#+------------+
#+ Clock Mode +
#+------------+
tmux setw -g clock-mode-colour "${PALETTE[teal]}"

#+----------+
#+ Messages +
#+---------+
tmux set -g message-style "bg=${PALETTE[bg_highlight]},fg=${PALETTE[teal]}"
tmux set -g message-command-style "bg=${PALETTE[bg_highlight]},fg=${PALETTE[teal]}"
