#!/bin/bash
# Omarchy Tmux - Uninstaller
# Removes all Omarchy Tmux integration
# https://github.com/joaofelipegalvao/omarchy-tmux

set -euo pipefail

readonly VERSION="2.1.0"
readonly TMUX_CONF="$HOME/.config/tmux/tmux.conf"
readonly RELOAD_SCRIPT="$HOME/.local/bin/omarchy-tmux-reload"
readonly GENERATOR_SCRIPT="$HOME/.local/bin/omarchy-tmux-generator"
readonly HOOK_FILE="$HOME/.config/omarchy/hooks/theme-set"
readonly PERSISTENT_THEMES_DIR="$HOME/.config/tmux/omarchy-themes"
readonly CURRENT_THEME_LINK="$HOME/.config/tmux/omarchy-current-theme.conf"

QUIET=0
KEEP_THEMES=0
YES=0

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

log() {
  if [[ $QUIET -eq 0 ]]; then
    echo -e "${GREEN}▶${NC} $*"
  fi
}

warn() { echo -e "${YELLOW}⚠${NC} $*" >&2; }
error() {
  echo -e "${RED}✗${NC} $*" >&2
  exit 1
}

info() {
  if [[ $QUIET -eq 0 ]]; then
    echo -e "${BLUE}ℹ ${NC} $*"
  fi
}

usage() {
  cat <<EOF
Omarchy Tmux Uninstaller v$VERSION

Removes Omarchy Tmux v2.1 integration and related files.

Usage: $(basename "$0") [OPTIONS]

Options:
  -h, --help          Show this help
  -q, --quiet         Minimal output
  -y, --yes           Skip confirmation prompts
  -k, --keep-themes   Keep theme configurations (don't delete)
  -v, --version       Show version

What will be removed:
  • Omarchy v2.1 integration from ~/.config/tmux/tmux.conf
  • Scripts: omarchy-tmux-reload, omarchy-tmux-generator
  • Hook from ~/.config/omarchy/hooks/theme-set
  • Symlink: ~/.config/tmux/omarchy-current-theme.conf
  • Theme profiles: ~/.config/tmux/omarchy-themes/ (unless -k)

Note: This uninstaller is for v2.1 only. 
      For v2.0 or earlier, use the uninstaller from that release.

What will NOT be removed:
  • tmux itself
  • TPM (Tmux Plugin Manager)
  • Your custom tmux.conf settings
  • PowerKit plugin (can be removed via TPM)

EOF
  exit 0
}

confirm() {
  [[ $YES -eq 1 ]] && return 0

  local prompt="$1"
  echo -e "${YELLOW}?${NC} $prompt [y/N]: "
  read -r response
  [[ "$response" =~ ^[Yy]$ ]]
}

backup_tmux_conf() {
  if [[ -f "$TMUX_CONF" ]]; then
    local backup="${TMUX_CONF}.backup-uninstall-$(date +%Y%m%d-%H%M%S)"
    if cp "$TMUX_CONF" "$backup"; then
      info "Created backup: $backup"
      return 0
    else
      warn "Failed to create backup"
      return 1
    fi
  fi
  return 0
}

remove_from_tmux_conf() {
  log "Removing Omarchy integration from tmux.conf..."

  if [[ ! -f "$TMUX_CONF" ]]; then
    info "tmux.conf not found (nothing to remove)"
    return 0
  fi

  # Check if v2.1 integration exists
  if ! grep -q "Omarchy Tmux Integration (v2.1)" "$TMUX_CONF" 2>/dev/null; then
    info "No Omarchy v2.1 integration found in tmux.conf"
    info "For v2.0 or earlier, use the uninstaller from that release"
    return 0
  fi

  # Create backup
  backup_tmux_conf || warn "Continuing without backup..."

  # Remove v2.1 integration block
  sed -i '/# ============================================================================/,/# End Omarchy Tmux Integration/d' "$TMUX_CONF" 2>/dev/null || true

  # Remove standalone source-file line (in case block removal failed)
  sed -i '\|source-file ~/.config/tmux/omarchy-current-theme.conf|d' "$TMUX_CONF" 2>/dev/null || true

  log "Removed Omarchy v2.1 integration from tmux.conf"
}

remove_scripts() {
  log "Removing scripts..."

  local removed=0

  if [[ -f "$RELOAD_SCRIPT" ]]; then
    rm -f "$RELOAD_SCRIPT" && ((removed++)) && info "Removed: $RELOAD_SCRIPT"
  fi

  if [[ -f "$GENERATOR_SCRIPT" ]]; then
    rm -f "$GENERATOR_SCRIPT" && ((removed++)) && info "Removed: $GENERATOR_SCRIPT"
  fi

  if [[ $removed -eq 0 ]]; then
    info "No scripts found to remove"
  else
    log "Removed $removed script(s)"
  fi
}

remove_hook() {
  log "Removing hook integration..."

  if [[ ! -f "$HOOK_FILE" ]]; then
    info "Hook file not found (nothing to remove)"
    return 0
  fi

  # Remove our reload script entry from hook
  if grep -q "omarchy-tmux-reload" "$HOOK_FILE" 2>/dev/null; then
    sed -i '\|omarchy-tmux-reload|d' "$HOOK_FILE" 2>/dev/null || true
    log "Removed hook integration"
  else
    info "Hook integration not found"
  fi

  # If hook file is now empty (except shebang), remove it
  if [[ -f "$HOOK_FILE" ]]; then
    local line_count=$(grep -cv '^#!/bin/bash' "$HOOK_FILE" 2>/dev/null || echo "0")
    if [[ $line_count -eq 0 ]]; then
      rm -f "$HOOK_FILE"
      info "Removed empty hook file"
    fi
  fi
}

remove_symlink() {
  log "Removing symlink..."

  if [[ -L "$CURRENT_THEME_LINK" ]]; then
    rm -f "$CURRENT_THEME_LINK"
    log "Removed symlink: $CURRENT_THEME_LINK"
  elif [[ -e "$CURRENT_THEME_LINK" ]]; then
    warn "$CURRENT_THEME_LINK exists but is not a symlink (skipping)"
  else
    info "Symlink not found (nothing to remove)"
  fi
}

remove_themes() {
  log "Removing theme profiles..."

  if [[ ! -d "$PERSISTENT_THEMES_DIR" ]]; then
    info "Theme directory not found (nothing to remove)"
    return 0
  fi

  # Count themes
  local theme_count=$(find "$PERSISTENT_THEMES_DIR" -maxdepth 1 -name "*.conf" 2>/dev/null | wc -l)

  if [[ $theme_count -eq 0 ]]; then
    info "No theme profiles found"
    rmdir "$PERSISTENT_THEMES_DIR" 2>/dev/null || true
    return 0
  fi

  # Show what will be deleted
  if [[ $QUIET -eq 0 ]]; then
    echo -e "${CYAN}Theme profiles found:${NC}"
    find "$PERSISTENT_THEMES_DIR" -maxdepth 1 -name "*.conf" -exec basename {} \; | sed 's/^/  • /'
    echo ""
  fi

  if confirm "Delete $theme_count theme profile(s)?"; then
    rm -rf "$PERSISTENT_THEMES_DIR"
    log "Removed theme profiles directory"
  else
    info "Keeping theme profiles at: $PERSISTENT_THEMES_DIR"
  fi
}

check_tmux_running() {
  if tmux list-sessions &>/dev/null 2>&1; then
    warn "tmux is currently running"
    warn "You should reload tmux config after uninstallation:"
    warn "  Run inside tmux: ${CYAN}tmux source-file ~/.config/tmux/tmux.conf${NC}"
    warn "  Or restart all tmux sessions"
    echo ""
  fi
}

show_powerkit_removal() {
  if [[ $QUIET -eq 0 ]]; then
    echo ""
    echo -e "${CYAN}Optional: Remove PowerKit plugin${NC}"
    echo ""
    echo "To completely remove PowerKit from tmux:"
    echo ""
    echo "  1. Edit your tmux.conf:"
    echo -e "     ${YELLOW}nano ~/.config/tmux/tmux.conf${NC}"
    echo ""
    echo "  2. Remove this line:"
    echo -e "     ${YELLOW}set -g @plugin 'fabioluciano/tmux-powerkit'${NC}"
    echo ""
    echo "  3. Inside tmux, uninstall via TPM:"
    echo -e "     Press ${YELLOW}prefix + alt + u${NC} (Ctrl+b Alt+u)"
    echo ""
    echo "  4. Reload tmux config:"
    echo -e "     ${YELLOW}tmux source-file ~/.config/tmux/tmux.conf${NC}"
    echo ""
  fi
}

main() {
  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
    -h | --help) usage ;;
    -q | --quiet)
      QUIET=1
      shift
      ;;
    -y | --yes)
      YES=1
      shift
      ;;
    -k | --keep-themes)
      KEEP_THEMES=1
      shift
      ;;
    -v | --version)
      echo "$VERSION"
      exit 0
      ;;
    *) error "Unknown option: $1
Use --help for usage" ;;
    esac
  done

  # Header
  if [[ $QUIET -eq 0 ]]; then
    echo -e "${RED}"
    cat <<"BANNER"
 ▄██████▄    ▄▄▄▄███▄▄▄▄      ▄████████    ▄████████  ▄████████    ▄█    █▄    ▄██   ▄   
███    ███ ▄██▀▀▀███▀▀▀██▄   ███    ███   ███    ███ ███    ███   ███    ███   ███   ██▄ 
███    ███ ███   ███   ███   ███    ███   ███    ███ ███    █▀    ███    ███   ███▄▄▄███ 
███    ███ ███   ███   ███   ███    ███  ▄███▄▄▄▄██▀ ███         ▄███▄▄▄▄███▄▄ ▀▀▀▀▀▀███ 
███    ███ ███   ███   ███ ▀███████████ ▀▀███▀▀▀▀▀   ███        ▀▀███▀▀▀▀███▀  ▄██   ███ 
███    ███ ███   ███   ███   ███    ███ ▀███████████ ███    █▄    ███    ███   ███   ███ 
███    ███ ███   ███   ███   ███    ███   ███    ███ ███    ███   ███    ███   ███   ███ 
 ▀██████▀   ▀█   ███   █▀    ███    █▀    ███    ███ ████████▀    ███    █▀     ▀█████▀  
                                          ███    ███                                    
BANNER
    echo -e "${NC}"
    echo -e "${RED}                         Tmux Uninstaller v$VERSION${NC}"
    echo ""
  fi

  # Confirmation
  if [[ $YES -eq 0 ]]; then
    echo -e "${YELLOW}This will remove Omarchy Tmux integration from your system.${NC}"
    echo ""
    echo "The following will be removed:"
    echo "  • Omarchy integration from tmux.conf"
    echo "  • Scripts: omarchy-tmux-reload, omarchy-tmux-generator"
    echo "  • Hook from theme-set"
    echo "  • Symlink: omarchy-current-theme.conf"
    [[ $KEEP_THEMES -eq 0 ]] && echo "  • Theme profiles directory"
    echo ""
    echo "The following will NOT be removed:"
    echo "  • Your custom tmux.conf settings"
    echo "  • tmux and TPM"
    echo "  • PowerKit plugin (manual removal required)"
    echo ""

    if ! confirm "Proceed with uninstallation?"; then
      echo ""
      echo -e "${BLUE}Uninstallation cancelled.${NC}"
      exit 0
    fi
    echo ""
  fi

  # Check if tmux is running
  check_tmux_running

  # Perform uninstallation
  remove_from_tmux_conf
  remove_scripts
  remove_hook
  remove_symlink

  if [[ $KEEP_THEMES -eq 0 ]]; then
    remove_themes
  else
    info "Keeping theme profiles as requested"
  fi

  # Success message
  if [[ $QUIET -eq 0 ]]; then
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}     ${GREEN}✓${NC} Uninstallation Complete          ${GREEN}║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""

    if [[ $KEEP_THEMES -eq 1 ]]; then
      echo -e "${CYAN}Theme profiles preserved at:${NC}"
      echo -e "  ${YELLOW}$PERSISTENT_THEMES_DIR${NC}"
      echo ""
    fi

    echo -e "${CYAN}Next steps:${NC}"
    echo ""
    echo "  1. If tmux is running, reload config:"
    echo -e "     ${YELLOW}tmux source-file ~/.config/tmux/tmux.conf${NC}"
    echo ""
    echo "  2. (Optional) Remove PowerKit plugin"
    echo -e "     See instructions below"
    echo ""

    show_powerkit_removal

    echo -e "${GREEN}Thank you for using Omarchy Tmux! 👋${NC}"
    echo ""
  fi
}

main "$@"
