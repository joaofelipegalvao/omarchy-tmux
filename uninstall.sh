#!/bin/bash
# omarchy-tmux — uninstaller
# https://github.com/joaofelipegalvao/omarchy-tmux

set -euo pipefail

readonly TMUX_CONF="$HOME/.config/tmux/tmux.conf"
readonly THEME_SET_SCRIPT="$HOME/.local/bin/omarchy-tmux-theme-set"
readonly POWERKIT_THEME_CONF="$HOME/.config/tmux/powerkit-theme.conf"
readonly POWERKIT_DIR="$HOME/.config/tmux/plugins/tmux-powerkit"
readonly THEME_SET_HOOK="$HOME/.config/omarchy/hooks/theme-set"
readonly POST_UPDATE_HOOK="$HOME/.config/omarchy/hooks/post-update"

YES=0

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

log() { echo -e "${GREEN}▶${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC} $*" >&2; }

confirm() {
  [[ $YES -eq 1 ]] && return 0
  if [[ ! -t 0 && ! -e /dev/tty ]]; then
    warn "No interactive terminal available, skipping confirmation requires -y"
    return 1
  fi
  echo -ne "${YELLOW}?${NC} $1 [y/N]: "
  read -r response </dev/tty
  [[ "$response" =~ ^[Yy]$ ]]
}

remove_from_tmux_conf() {
  log "Cleaning tmux.conf..."
  [[ ! -f "$TMUX_CONF" ]] && return 0

  # Backup
  cp "$TMUX_CONF" "${TMUX_CONF}.backup-uninstall-$(date +%Y%m%d-%H%M%S)"

  # Remove omarchy-tmux block
  sed -i '/# >>> omarchy-tmux/,/# <<< omarchy-tmux/d' "$TMUX_CONF" 2>/dev/null || true
}

remove_script() {
  log "Removing omarchy-tmux-theme-set..."
  rm -f "$THEME_SET_SCRIPT"
}

remove_theme_conf() {
  log "Removing powerkit-theme.conf..."
  rm -f "$POWERKIT_THEME_CONF"
}

remove_hooks() {
  log "Cleaning hooks..."

  # theme-set hook
  if [[ -f "$THEME_SET_HOOK" ]]; then
    sed -i '\|omarchy-tmux-theme-set|d' "$THEME_SET_HOOK" 2>/dev/null || true
  fi

  # post-update hook
  if [[ -f "$POST_UPDATE_HOOK" ]]; then
    sed -i '/# >>> omarchy-tmux/,/# <<< omarchy-tmux/d' "$POST_UPDATE_HOOK" 2>/dev/null || true
  fi
}

remove_powerkit() {
  if [[ ! -d "$POWERKIT_DIR" ]]; then
    return 0
  fi

  if confirm "Remove tmux-powerkit plugin? (skip if managed by TPM)"; then
    rm -rf "$POWERKIT_DIR"
    log "Removed tmux-powerkit"
  fi
}

main() {
  while [[ $# -gt 0 ]]; do
    case $1 in
    -y | --yes)
      YES=1
      shift
      ;;
    -h | --help)
      echo "Usage: $(basename "$0") [-y] [-h]"
      echo "  -y  Skip confirmation prompts"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
    esac
  done

  echo ""
  echo -e "${RED}omarchy-tmux uninstaller${NC}"
  echo ""

  if ! confirm "Remove omarchy-tmux integration?"; then
    echo "Cancelled."
    exit 0
  fi

  echo ""
  remove_from_tmux_conf
  remove_script
  remove_theme_conf
  remove_hooks
  remove_powerkit

  echo ""
  echo -e "${GREEN}✓ Done!${NC}"
  echo ""
  echo "Reload tmux to apply changes:"
  echo -e "  ${YELLOW}tmux source-file ~/.config/tmux/tmux.conf${NC}"
  echo ""
}

main "$@"
