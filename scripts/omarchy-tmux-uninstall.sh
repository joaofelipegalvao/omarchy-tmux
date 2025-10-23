#!/bin/bash
# Omarchy Tmux Theme - Uninstaller
# https://github.com/joaofelipegalvao/omarchy-tmux

set -uo pipefail

readonly VERSION="1.0.0"
readonly INSTALL_DIR="$HOME/.config/tmux/plugins/omarchy-tmux"
readonly TMUX_CONF="$HOME/.config/tmux/tmux.conf"
readonly THEMES_DIR="$HOME/.config/omarchy/themes"
readonly UPDATE_SCRIPT="$HOME/.local/bin/omarchy-tmux-hook"
readonly HOOK_FILE="$HOME/.config/omarchy/hooks/theme-set"

QUIET=0
FORCE=0
KEEP_CONFIGS=0

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

log() { [[ $QUIET -eq 0 ]] && echo -e "${GREEN}▶${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC} $*" >&2; }
success() { [[ $QUIET -eq 0 ]] && echo -e "${GREEN}✓${NC} $*"; }
error() {
  echo -e "${RED}✗${NC} $*" >&2
  exit 1
}
info() { [[ $QUIET -eq 0 ]] && echo -e "${BLUE}󰋼${NC} $*"; }

usage() {
  cat <<EOF
Omarchy Tmux Theme Uninstaller v$VERSION

Usage: $(basename "$0") [OPTIONS]

Options:
  -h, --help          Show this help
  -q, --quiet         Minimal output
  -f, --force         Skip confirmation prompts
  -k, --keep-configs  Keep theme configs in ~/.config/omarchy/themes
  -v, --version       Show version

EOF
  exit 0
}

confirm() {
  [[ $FORCE -eq 1 ]] && return 0

  local prompt="$1"
  read -rp "$prompt [y/N] " response </dev/tty
  [[ $response =~ ^[Yy]$ ]]
}

remove_plugin() {
  if [[ -d "$INSTALL_DIR" ]]; then
    log "Removing Omarchy Tmux plugin directory..."
    rm -rf "$INSTALL_DIR" || warn "Failed to remove plugin directory: $INSTALL_DIR. Manual removal may be required."
  else
    [[ $QUIET -eq 0 ]] && info "Omarchy Tmux plugin not found, skipping."
  fi
}

clean_tmux_conf() {
  if [[ ! -f "$TMUX_CONF" ]]; then
    [[ $QUIET -eq 0 ]] && info "Tmux config file not found: $TMUX_CONF, skipping cleanup."
    return
  fi

  local omarchy_source_line="source-file ~/.config/omarchy/current/theme/tmux.conf"
  local omarchy_begin_marker="# >>> Omarchy Tmux Integration BEGIN >>>"
  local omarchy_end_marker="# <<< Omarchy Tmux Integration END <<<"
  local found_integration=0

  if grep -qF "$omarchy_begin_marker" "$TMUX_CONF" 2>/dev/null; then
    log "Removing Omarchy integration block from tmux.conf..."
    sed -i "/$omarchy_begin_marker/,/$omarchy_end_marker/d" "$TMUX_CONF"
    found_integration=1
  fi

  if grep -q "# Omarchy Tmux integration" "$TMUX_CONF" 2>/dev/null; then
    log "Removing old commented Omarchy integration block from tmux.conf..."
    sed -i '/# Omarchy Tmux integration/,/# End Omarchy Tmux integration/d' "$TMUX_CONF"
    found_integration=1
  fi

  if grep -qF "$omarchy_source_line" "$TMUX_CONF" 2>/dev/null; then
    log "Removing standalone Omarchy source-file line from tmux.conf..."
    sed -i "\|$omarchy_source_line|d" "$TMUX_CONF"
    found_integration=1
  fi

  if [[ $found_integration -eq 1 ]]; then
    log "Cleaning up empty lines in tmux.conf..."
    sed -i '/^$/N; /^\n$/N; //D' "$TMUX_CONF"
  else
    [[ $QUIET -eq 0 ]] && info "No Omarchy integration found in tmux.conf, skipping cleanup."
  fi
}
remove_theme_configs() {
  if [[ $KEEP_CONFIGS -eq 1 ]]; then
    info "Keeping theme configs (--keep-configs)"
    return
  fi

  if [[ ! -d "$THEMES_DIR" ]]; then
    warn "Themes directory not found at $THEMES_DIR"
    return
  fi

  local count=0
  local theme_name tmux_file

  for theme_dir in "$THEMES_DIR"/*; do
    [[ ! -d "$theme_dir" ]] && continue

    theme_name=$(basename "$theme_dir")
    tmux_file="$theme_dir/tmux.conf"

    if [[ -f "$tmux_file" ]]; then
      if [[ $QUIET -eq 0 ]]; then
        log "Removing config: $theme_name/tmux.conf"
      fi
      rm -f "$tmux_file"
      ((count++)) || true
    fi
  done

  if [[ $count -gt 0 ]]; then
    log "Removed $count theme config(s)"
  else
    [[ $QUIET -eq 0 ]] && info "No theme configs found to remove"
  fi
}

remove_hook() {
  if [[ -f "$HOOK_FILE" ]]; then
    sed -i '/omarchy-tmux-hook/d' "$HOOK_FILE"
  fi

  if [[ -f "$UPDATE_SCRIPT" ]]; then
    rm $UPDATE_SCRIPT
  fi
}

reload_tmux() {
  [[ $QUIET -eq 1 ]] && return

  if ! command -v tmux >/dev/null 2>&1; then
    info "tmux not found: skipping reload"
    return
  fi

  if tmux list-sessions &>/dev/null; then
    if [[ -n "${TMUX-}" ]]; then
      info "Inside tmux session: please restart tmux manually to apply changes"
      echo -e "  Run: ${CYAN}tmux kill-server${NC} then ${CYAN}tmux${NC}"
    else
      log "Restarting tmux server..."
      if tmux kill-server >/dev/null 2>&1; then
        success "Tmux reloaded successfully"
      else
        warn "Could not restart tmux. Please run: tmux kill-server"
      fi
    fi
  else
    info "No active tmux sessions found"
  fi
}

show_summary() {
  if [[ $QUIET -eq 1 ]]; then
    return
  fi

  echo -e "\n${BLUE}Removal Summary:${NC}"

  echo -e "\n${GREEN}Removed:${NC}"
  [[ ! -d "$INSTALL_DIR" ]] && echo "  ✓ Omarchy Tmux plugin"
  [[ ! -f "$UPDATE_SCRIPT" ]] && echo "  ✓ Update hook"
  echo "  ✓ Tmux.conf integration"

  echo -e "\n${BLUE}Next steps:${NC}"
  echo "  If tmux is running, restart it:"
  echo -e "    ${CYAN}tmux kill-server${NC}"
  echo -e "    ${CYAN}tmux${NC}"
}

main() {
  while [[ $# -gt 0 ]]; do
    case $1 in
    -h | --help) usage ;;
    -q | --quiet)
      QUIET=1
      shift
      ;;
    -f | --force)
      FORCE=1
      shift
      ;;
    -k | --keep-configs)
      KEEP_CONFIGS=1
      shift
      ;;
    -v | --version)
      echo "$VERSION"
      exit 0
      ;;
    *) error "Unknown option: $1\nUse --help for usage" ;;
    esac
  done

  [[ $QUIET -eq 0 ]] && echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
  [[ $QUIET -eq 0 ]] && echo -e "${BLUE}║${NC}         ${BLUE}Omarchy Tmux Uninstaller${NC}       ${BLUE}║${NC}"
  [[ $QUIET -eq 0 ]] && echo -e "${BLUE}╚════════════════════════════════════════╝${NC}\n"

  if [[ $FORCE -eq 0 ]]; then
    echo "This will attempt to remove the following components:"
    echo "  • Omarchy Tmux plugin"
    echo "  • Monitor script"
    [[ $KEEP_CONFIGS -eq 0 ]] && echo "  • Theme configs and empty theme directories (use -k to keep configs)"
    echo "  • Omarchy Tmux integration from tmux.conf"
    echo ""

    if ! confirm "Continue with uninstallation?"; then
      info "Uninstallation aborted by user."
      exit 0
    fi
  fi

  remove_plugin
  remove_hook
  clean_tmux_conf
  remove_theme_configs
  reload_tmux
  show_summary

  if [[ $QUIET -eq 0 ]]; then
    echo -e "\n${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}        ${GREEN}✓${NC} Uninstallation Complete       ${GREEN}║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}\n"
  fi
}

main "$@"
