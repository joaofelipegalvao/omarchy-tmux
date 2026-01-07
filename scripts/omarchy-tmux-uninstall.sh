#!/bin/bash
# Omarchy Tmux - PowerKit Uninstaller
# Removes tmux-powerkit integration with Omarchy
# https://github.com/joaofelipegalvao/omarchy-tmux

set -euo pipefail

readonly VERSION="2.0.1"
readonly TMUX_CONF="$HOME/.config/tmux/tmux.conf"
readonly RELOAD_SCRIPT="$HOME/.local/bin/omarchy-tmux-reload"
readonly HOOK_FILE="$HOME/.config/omarchy/hooks/theme-set"
readonly OMARCHY_DIR="$HOME/.config/omarchy"
readonly THEMES_DIR="$OMARCHY_DIR/themes"

QUIET=0
FORCE=0
KEEP_CONFIGS=0
CLEANUP_NEEDED=0

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

log() { [[ $QUIET -eq 0 ]] && echo -e "${GREEN}▶${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC} $*" >&2; }
error() {
  echo -e "${RED}✗${NC} $*" >&2
  exit 1
}
info() { [[ $QUIET -eq 0 ]] && echo -e "${BLUE}ℹ${NC} $*"; }

# Cleanup trap
cleanup() {
  local exit_code=$?
  if [[ $exit_code -ne 0 && $CLEANUP_NEEDED -eq 1 ]]; then
    warn "Uninstallation failed - some changes may be incomplete"
    warn "Check error messages above for details"
    warn "You can safely re-run the uninstaller to retry"
  fi
}
trap cleanup EXIT

usage() {
  cat <<EOF
Omarchy Tmux Uninstaller v$VERSION

Removes tmux-powerkit integration with Omarchy.

Usage: $(basename "$0") [OPTIONS]

Options:
  -h, --help          Show this help
  -q, --quiet         Minimal output
  -f, --force         Skip confirmation prompts
  -k, --keep-configs  Keep generated theme configs (only remove integration)
  -v, --version       Show version
EOF
  exit 0
}

# Confirmation
confirm() {
  [[ $FORCE -eq 1 ]] && return 0

  echo -e "${YELLOW}$1${NC}"
  read -r -p "Continue? [y/N] " response

  case "$response" in
  [yY][eE][sS] | [yY]) ;;
  *)
    echo "Cancelled."
    exit 0
    ;;
  esac
}

# Removal Functions
remove_tmux_integration() {
  log "Removing tmux.conf integration..."

  CLEANUP_NEEDED=1

  [[ ! -f "$TMUX_CONF" ]] && {
    info "tmux.conf not found, skipping"
    return 0
  }

  if ! grep -qE "Omarchy Tmux Integration|omarchy/current/theme/tmux.conf" "$TMUX_CONF"; then
    info "No Omarchy integration found in tmux.conf"
    return 0
  fi

  # Create backup with validation
  local backup="${TMUX_CONF}.backup-$(date +%Y%m%d-%H%M%S)"
  if ! cp "$TMUX_CONF" "$backup"; then
    error "Failed to create backup at $backup
Cannot proceed without backup"
  fi

  if [[ ! -f "$backup" ]]; then
    error "Backup verification failed at $backup"
  fi

  info "Created backup at $backup"

  # Create temp file for safe editing
  local tmp_file
  tmp_file="$(mktemp)"

  # Copy original to temp
  if ! cp "$TMUX_CONF" "$tmp_file"; then
    rm -f "$tmp_file"
    error "Failed to create temporary file"
  fi

  # 1️⃣ Remove managed integration block (v2)
  if ! sed -i '/# Omarchy Tmux Integration/,/# End Omarchy Tmux Integration/d' "$tmp_file"; then
    warn "Could not remove integration block with sed"
    rm -f "$tmp_file"
    error "Failed to process tmux.conf (backup preserved at $backup)"
  fi

  # 2️⃣ Remove stray source-file lines (legacy / broken installs)
  sed -i '\|source-file ~/.config/omarchy/current/theme/tmux.conf|d' "$tmp_file" || true

  # 3️⃣ Ensure TPM init block is correct and isolated
  if grep -q "run '~/.tmux/plugins/tpm/tpm'" "$tmp_file"; then
    sed -i '
      /# Initialize and run tpm/{
        N
        /run '\''~\/\.tmux\/plugins\/tpm\/tpm'\''/!{
          a\
run '\''~\/.tmux\/plugins\/tpm\/tpm'\''
        }
      }
    ' "$tmp_file" || true
  fi

  # 4️⃣ Normalize spacing (max 1 blank line)
  sed -i ':a;N;$!ba;s/\n\{3,\}/\n\n/g' "$tmp_file" || true
  sed -i '${/^$/d;}' "$tmp_file" || true

  # Verify temp file is not empty
  if [[ ! -s "$tmp_file" ]]; then
    rm -f "$tmp_file"
    error "Processed file is empty - keeping original (backup at $backup)"
  fi

  # Replace original with processed file
  if ! mv "$tmp_file" "$TMUX_CONF"; then
    rm -f "$tmp_file"
    error "Failed to update tmux.conf (backup preserved at $backup)"
  fi

  log "Removed Omarchy integration from tmux.conf"
}

remove_reload_script() {
  log "Removing reload script..."

  if [[ ! -f "$RELOAD_SCRIPT" ]]; then
    info "Reload script not found, skipping"
    return 0
  fi

  # Verify it's our script before removing
  if ! grep -q "Omarchy Tmux Reload Script" "$RELOAD_SCRIPT" 2>/dev/null; then
    warn "Found script at $RELOAD_SCRIPT but it's not managed by omarchy-tmux"
    warn "Skipping removal (remove manually if needed)"

    if [[ $QUIET -eq 0 ]]; then
      echo ""
      read -r -p "Show script content? [y/N] " show_content
      if [[ "$show_content" =~ ^[yY]$ ]]; then
        echo -e "${CYAN}Content of $RELOAD_SCRIPT:${NC}"
        head -n 10 "$RELOAD_SCRIPT"
        echo "..."
      fi
    fi
    return 0
  fi

  if ! rm -f "$RELOAD_SCRIPT"; then
    warn "Failed to remove reload script at $RELOAD_SCRIPT"
    warn "You may need to remove it manually"
    return 1
  fi

  log "Removed $RELOAD_SCRIPT"
}

remove_hook() {
  log "Removing Omarchy hook..."

  [[ ! -f "$HOOK_FILE" ]] && {
    info "Hook file not found, skipping"
    return 0
  }

  if ! grep -q 'omarchy-tmux-reload' "$HOOK_FILE"; then
    info "Hook not installed, skipping"
    return 0
  fi

  # Create backup with validation
  local backup="${HOOK_FILE}.backup-$(date +%Y%m%d-%H%M%S)"
  if ! cp "$HOOK_FILE" "$backup"; then
    warn "Failed to create backup at $backup"
    warn "Proceeding without backup"
  else
    if [[ ! -f "$backup" ]]; then
      warn "Backup verification failed"
    else
      info "Created backup at $backup"
    fi
  fi

  # Create temp file
  local tmp_file
  tmp_file="$(mktemp)"

  if ! cp "$HOOK_FILE" "$tmp_file"; then
    rm -f "$tmp_file"
    error "Failed to create temporary file"
  fi

  # Remove our hook entry
  if ! sed -i '/omarchy-tmux-reload/d' "$tmp_file"; then
    rm -f "$tmp_file"
    warn "Failed to remove hook entry"
    return 1
  fi

  # Check if hook file would be empty (only shebang and comments)
  if [[ $(grep -vE '^#!/bin/bash|^#|^$' "$tmp_file" | wc -l) -eq 0 ]]; then
    rm -f "$tmp_file"

    if ! rm -f "$HOOK_FILE"; then
      warn "Failed to remove empty hook file"
      return 1
    fi

    log "Removed empty hook file"
  else
    # Other hooks remain, just update the file
    if ! mv "$tmp_file" "$HOOK_FILE"; then
      rm -f "$tmp_file"
      warn "Failed to update hook file"
      return 1
    fi

    log "Removed hook entry (other hooks remain)"
  fi
}

remove_theme_configs() {
  [[ $KEEP_CONFIGS -eq 1 ]] && {
    info "Keeping theme configs (--keep-configs flag)"
    return 0
  }

  log "Removing generated theme configs..."
  local count=0
  local failed=0

  for theme_dir in "$THEMES_DIR"/*; do
    [[ ! -d "$theme_dir" ]] && continue

    local theme_name=$(basename "$theme_dir")
    local tmux_file="$theme_dir/tmux.conf"

    if [[ ! -f "$tmux_file" ]]; then
      continue
    fi

    # Verify it's our generated file
    if ! grep -q "Auto-generated by omarchy-tmux installer" "$tmux_file" 2>/dev/null; then
      continue
    fi

    # Create backup of the config
    local backup="${tmux_file}.backup-$(date +%Y%m%d-%H%M%S)"
    if ! cp "$tmux_file" "$backup" 2>/dev/null; then
      warn "Could not backup config for $theme_name"
    fi

    if ! rm -f "$tmux_file"; then
      warn "Failed to remove config for $theme_name"
      ((failed++)) || true
      continue
    fi

    ((count++)) || true
  done

  if [[ $count -gt 0 ]]; then
    log "Removed $count theme config(s)"
    if [[ $QUIET -eq 0 ]]; then
      info "Backups created with .backup-* extension"
    fi
  else
    info "No auto-generated configs found"
  fi

  if [[ $failed -gt 0 ]]; then
    warn "Failed to remove $failed config(s)"
  fi
}

check_powerkit_plugin() {
  local locations=(
    "$HOME/.config/tmux/plugins/tmux-powerkit"
    "$HOME/.tmux/plugins/tmux-powerkit"
  )

  for dir in "${locations[@]}"; do
    if [[ -d "$dir" ]]; then
      if [[ $QUIET -eq 0 ]]; then
        echo ""
        warn "PowerKit plugin still installed at:"
        warn "  $dir"
        echo ""
        echo -e "${CYAN}To remove PowerKit plugin:${NC}"
        echo "  1. Start tmux"
        echo -e "  2. Press ${YELLOW}prefix + Alt + u${NC}"
        echo "  3. Select 'tmux-powerkit'"
        echo ""
        echo -e "${CYAN}Or remove manually:${NC}"
        echo -e "  ${YELLOW}rm -rf $dir${NC}"
        echo ""
      fi
      return 0
    fi
  done
}

# Summary
show_summary() {
  [[ $QUIET -eq 1 ]] && return 0

  echo ""
  echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║${NC}     ${GREEN}✓${NC} Uninstallation Complete         ${GREEN}║${NC}"
  echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
  echo ""

  # Show backup locations
  if compgen -G "${TMUX_CONF}.backup-*" >/dev/null 2>&1; then
    echo -e "${CYAN}Backups created:${NC}"
    echo -e "  ${YELLOW}${TMUX_CONF}.backup-*${NC}"
  fi

  if compgen -G "${HOOK_FILE}.backup-*" >/dev/null 2>&1; then
    echo -e "  ${YELLOW}${HOOK_FILE}.backup-*${NC}"
  fi

  if compgen -G "$THEMES_DIR/*/tmux.conf.backup-*" >/dev/null 2>&1; then
    echo -e "  ${YELLOW}$THEMES_DIR/*/tmux.conf.backup-*${NC}"
  fi

  echo ""

  check_powerkit_plugin

  echo -e "${CYAN}What was removed:${NC}"
  echo "  • Omarchy integration from tmux.conf"
  echo "  • Reload script ($RELOAD_SCRIPT)"
  echo "  • Theme change hook"
  if [[ $KEEP_CONFIGS -eq 0 ]]; then
    echo "  • Auto-generated theme configs"
  fi

  echo ""
  echo -e "${CYAN}What remains:${NC}"
  echo "  • Your custom tmux.conf settings"
  echo "  • TPM and other plugins"
  if [[ $KEEP_CONFIGS -eq 1 ]]; then
    echo "  • Theme configs (--keep-configs was used)"
  fi

  echo ""
  echo -e "${GREEN}Tmux will continue to work normally.${NC}"
  echo ""
}

# Main
main() {
  while [[ $# -gt 0 ]]; do
    case $1 in
    -h | --help) usage ;;
    -q | --quiet) QUIET=1 ;;
    -f | --force) FORCE=1 ;;
    -k | --keep-configs) KEEP_CONFIGS=1 ;;
    -v | --version)
      echo "$VERSION"
      exit 0
      ;;
    *) error "Unknown option: $1
Use --help for usage" ;;
    esac
    shift
  done

  # Header
  if [[ $QUIET -eq 0 ]]; then
    echo -e "${BLUE}"
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
    echo -e "${CYAN}                           Tmux PowerKit Uninstaller${NC}"
    echo ""
  fi

  confirm "This will remove Omarchy-tmux integration.
Backups will be created for all modified files."

  remove_tmux_integration
  remove_reload_script
  remove_hook
  remove_theme_configs

  show_summary
}

main "$@"
