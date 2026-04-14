#!/usr/bin/env bash
# tmux-worktree: displays the current worktree/task name in the tmux status bar.
#
# Reads from /tmp/.tmux-worktree-<session_name>, which is written by
# tmuxinator on_project_start (or any other session bootstrapper).
#
# Usage in .tmux.conf:
#   set -g @plugin 'aross/tmux-worktree'
#
# Options:
#   @worktree-colors "fg bg"   (default: "#282a36 #50fa7b" — dark on green, Dracula palette)
#   @worktree-icon "🌿"        (default: 🌿)

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/scripts/helpers.sh"

get_tmux_option() {
  local option="$1"
  local default_value="$2"
  local option_value
  option_value=$(tmux show-option -gqv "$option")
  if [ -z "$option_value" ]; then
    echo "$default_value"
  else
    echo "$option_value"
  fi
}

main() {
  local fg bg current_status worktree_segment
  IFS=' ' read -r fg bg <<< "$(get_tmux_option "@worktree-colors" "#282a36 #50fa7b")"

  worktree_segment="#[fg=${fg},bg=${bg}]#($CURRENT_DIR/scripts/worktree.sh) "
  current_status=$(tmux show-option -gqv status-right)

  # Prepend so the worktree label appears first (leftmost) in status-right
  tmux set-option -g status-right "${worktree_segment}${current_status}"
}

main
