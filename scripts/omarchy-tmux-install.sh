#!/bin/bash
# Omarchy Tmux Theme - Installer
# https://github.com/joaofelipegalvao/omarchy-tmux

set -euo pipefail

readonly VERSION="1.0.0"
readonly REPO="https://github.com/joaofelipegalvao/omarchy-tmux.git"
readonly INSTALL_DIR="$HOME/.config/tmux/plugins/omarchy-tmux"
readonly TMUX_CONF="$HOME/.config/tmux/tmux.conf"
readonly UPDATE_SCRIPT="$HOME/.local/bin/omarchy-tmux-hook"
readonly HOOK_FILE="$HOME/.config/omarchy/hooks/theme-set"
readonly OMARCHY_DIR="$HOME/.config/omarchy"
readonly THEMES_DIR="$OMARCHY_DIR/themes"

QUIET=0
FORCE=0

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

DEBUG_LOG="${DEBUG_LOG:-}"
[[ -n "$DEBUG_LOG" ]] && exec 2>>"$DEBUG_LOG"

log() { [[ $QUIET -eq 0 ]] && echo -e "${GREEN}▶${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC} $*" >&2; }
error() {
  echo -e "${RED}✗${NC} $*" >&2
  exit 1
}
info() { [[ $QUIET -eq 0 ]] && echo -e "${BLUE}󰋼${NC} $*"; }

usage() {
  cat <<EOF
Omarchy Tmux Theme Installer v$VERSION

Usage: $(basename "$0") [OPTIONS]

Options:
  -h, --help     Show this help
  -q, --quiet    Minimal output
  -f, --force    Force reinstall
  -v, --version  Show version

Environment:
  DEBUG_LOG      Path to debug log file (optional)

EOF
  exit 0
}

check_deps() {
  local missing=()

  if [[ ! -d "$OMARCHY_DIR" ]]; then
    error "Omarchy not found at $OMARCHY_DIR"
  fi

  if [[ ! -d "$(dirname $HOOK_FILE)" ]]; then
    error "Omarchy hook directory not found, version 3.1 is required"
  fi

  command -v tmux >/dev/null 2>&1 || missing+=("tmux")
  command -v git >/dev/null 2>&1 || missing+=("git")

  if [[ ${#missing[@]} -gt 0 ]]; then
    error "Missing dependencies: ${missing[*]}\nInstall: sudo pacman -S ${missing[*]}"
  fi

  log "Dependencies OK"
}

check_tpm() {
  local tpm_dir="$HOME/.config/tmux/plugins/tpm"
  local tpm_alt_dir="$HOME/.tmux/plugins/tpm"

  if [[ -d "$tpm_dir" ]] || [[ -d "$tpm_alt_dir" ]]; then
    log "TPM found"
    return 0
  fi

  cat <<EOF
${RED}✗${NC} TPM (Tmux Plugin Manager) not found.

Install it with:
  ${CYAN}git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm${NC}

Or follow official instructions:
  ${BLUE}https://github.com/tmux-plugins/tpm${NC}

Then run this installer again.
EOF
  exit 1
}

install_plugin() {
  mkdir -p "$(dirname "$INSTALL_DIR")"

  if [[ -d "$INSTALL_DIR/.git" ]]; then
    log "Updating plugin..."
    if git -C "$INSTALL_DIR" pull --quiet 2>&1; then
      log "Plugin updated"
    else
      warn "Update failed, using current version"
    fi
  elif [[ -d "$INSTALL_DIR" ]]; then
    if [[ $FORCE -eq 1 ]]; then
      log "Removing existing installation..."
      rm -rf "$INSTALL_DIR"
      log "Installing plugin..."
      if ! git clone --quiet --depth 1 "$REPO" "$INSTALL_DIR" 2>&1; then
        error "Clone failed"
      fi
    else
      log "Plugin already exists (use -f to reinstall)"
    fi
  else
    log "Installing plugin..."
    if ! git clone --quiet --depth 1 "$REPO" "$INSTALL_DIR" 2>&1; then
      error "Clone failed"
    fi
  fi
}

install_hook() {
  if [[ -f "$HOOK_FILE" ]]; then
    # If the hook isn't enabled, first attempt to rename it from the sample
    if [[ -f "${HOOK_FILE}.sample" ]]; then
      mv "${HOOK_FILE}.sample" "${HOOK_FILE}"
    # Otherwise, add an empty bash script
    else
      echo '#!/bin/bash' >$HOOK_FILE
    fi
  fi

  if ! grep -q 'omarchy-tmux-hook' $HOOK_FILE; then
    echo "$UPDATE_SCRIPT \$1" >>$HOOK_FILE
  fi
}

detect_theme_config() {
  local theme="$1"
  local base variant

  case "$theme" in
  catppuccin-latte)
    base="catppuccin"
    variant="latte"
    ;;

  catppuccin)
    base="catppuccin"
    variant="macchiato"
    ;;
  rose-pine)
    base="rose-pine"
    variant="dawn"
    ;;

  tokyo-night)
    base="tokyo-night"
    variant="night"
    ;;

  everforest | everforest-dark-hard)
    base="everforest"
    variant="dark-hard"
    ;;

  gruvbox | gruvbox-dark)
    base="gruvbox"
    variant="dark"
    ;;
  kanagawa | kanagawa-wave)
    base="kanagawa"
    variant="wave"
    ;;

  osaka-jade)
    base="osaka"
    variant="jade"
    ;;

  flexoki-light)
    base="flexoki"
    variant="light"
    ;;

  ethereal)
    base="ethereal"
    variant="ethereal"
    ;;

  hackerman)
    base="hackerman"
    variant="hackerman"
    ;;

  matte-black | nord | ristretto)
    base="$theme"
    variant="$theme"
    ;;

  *-*-*)
    base="${theme%-*}"
    variant="${theme##*-}"
    ;;

  *-*)
    base="${theme%-*}"
    variant="${theme#*-}"
    ;;

  *)
    base="$theme"
    variant=""
    ;;
  esac

  # Validate output
  if [[ -z "$base" ]]; then
    return 1
  fi

  echo "$base|$variant"
}

generate_theme_configs() {
  if [[ ! -d "$THEMES_DIR" ]]; then
    warn "Themes dir not found at $THEMES_DIR"
    return
  fi

  local count=0
  local theme_name tmux_file base variant config

  for theme_dir in "$THEMES_DIR"/*; do
    [[ ! -d "$theme_dir" ]] && continue

    theme_name=$(basename "$theme_dir")
    tmux_file="$theme_dir/tmux.conf"

    [[ -f "$tmux_file" ]] && continue

    if ! config=$(detect_theme_config "$theme_name"); then
      warn "Failed to detect config for theme: $theme_name"
      continue
    fi

    IFS='|' read -r base variant <<<"$config"

    cat >"$tmux_file" <<EOF
set -g @plugin 'joaofelipegalvao/omarchy-tmux'
set -g @theme '$base'
EOF

    if [[ -n "$variant" ]]; then
      echo "set -g @theme_variant '$variant'" >>"$tmux_file"
    fi

    echo "set -g @theme_no_patched_font '0'" >>"$tmux_file"

    ((count++)) || true
  done

  if [[ $count -gt 0 ]]; then
    log "Created $count theme config(s)"
  else
    log "Theme configs already exist"
  fi
}

configure_tmux() {
  mkdir -p "$(dirname "$TMUX_CONF")"
  touch "$TMUX_CONF"

  local omarchy_source="source-file ~/.config/omarchy/current/theme/tmux.conf"
  local tpm_plugin="set -g @plugin 'tmux-plugins/tpm'"

  if grep -qF "$omarchy_source" "$TMUX_CONF" 2>/dev/null; then
    log "Omarchy integration already configured"
    return 0
  fi

  if grep -q "# Omarchy Tmux integration" "$TMUX_CONF" 2>/dev/null; then
    sed -i '/# Omarchy Tmux integration/,/# End Omarchy Tmux integration/d' "$TMUX_CONF"
  fi

  if ! grep -qF "$tpm_plugin" "$TMUX_CONF" 2>/dev/null; then
    cat >>"$TMUX_CONF" <<'EOF'

set -g @plugin 'tmux-plugins/tpm'
EOF
  fi

  local tpm_init_line=""
  if grep -qF "run '~/.config/tmux/plugins/tpm/tpm'" "$TMUX_CONF" 2>/dev/null; then
    tpm_init_line="run '~/.config/tmux/plugins/tpm/tpm'"
  elif grep -qF 'run "~/.config/tmux/plugins/tpm/tpm"' "$TMUX_CONF" 2>/dev/null; then
    tpm_init_line='run "~/.config/tmux/plugins/tpm/tpm"'
  elif grep -qF "run '~/.tmux/plugins/tpm/tpm'" "$TMUX_CONF" 2>/dev/null; then
    tpm_init_line="run '~/.tmux/plugins/tpm/tpm'"
  elif grep -qF 'run "~/.tmux/plugins/tpm/tpm"' "$TMUX_CONF" 2>/dev/null; then
    tpm_init_line='run "~/.tmux/plugins/tpm/tpm"'
  fi

  if [[ -n "$tpm_init_line" ]]; then
    log "Inserting Omarchy integration before TPM init..."

    awk -v marker="$tpm_init_line" '
      !inserted && index($0, marker) {
        print ""
        print "# Omarchy Tmux integration"
        print "source-file ~/.config/omarchy/current/theme/tmux.conf"
        print "# End Omarchy Tmux integration"
        print ""
        inserted = 1
      }
      { print }
    ' "$TMUX_CONF" >"$TMUX_CONF.tmp"

    # Validate awk output
    if [[ ! -s "$TMUX_CONF.tmp" ]]; then
      rm -f "$TMUX_CONF.tmp"
      error "Failed to update tmux.conf - empty output"
    fi

    mv "$TMUX_CONF.tmp" "$TMUX_CONF"
  else
    # TPM init not found, add both at the end
    log "TPM init not found, adding integration at end..."
    cat >>"$TMUX_CONF" <<'EOF'

# Omarchy Tmux integration
source-file ~/.config/omarchy/current/theme/tmux.conf
# End Omarchy Tmux integration

run '~/.config/tmux/plugins/tpm/tpm'
EOF
  fi

  log "Configured tmux.conf"
}

install_update_script() {
  # Ensure the dir exists
  mkdir -p $(dirname $UPDATE_SCRIPT)
  cat >"$UPDATE_SCRIPT" <<'SCRIPT'
#!/bin/bash
set -euo pipefail

readonly THEME="$1"
readonly THEME_DIR="$HOME/.config/omarchy/themes/$THEME"
readonly TMUX_CONF="$HOME/.config/tmux/tmux.conf"
readonly LOCKFILE="$HOME/.cache/omarchy-tmux.lock"

reload_tmux() {
  if ! tmux list-sessions &>/dev/null; then
    return
  fi

  local pane_count
  pane_count=$(tmux list-panes -a 2>/dev/null | wc -l || echo "0")

  if [[ $pane_count -gt 0 ]]; then
    tmux source-file "$TMUX_CONF" &>/dev/null || true
    tmux refresh-client -S &>/dev/null || true
  fi
}

# Validate theme directory exists
if [[ ! -d "$THEME_DIR" ]]; then
  echo "Error: Theme directory not found at $THEME_DIR" >&2
  exit 1
fi

# Verify directory still exists
if [[ ! -d "$THEME_DIR" ]]; then
  echo "Warning: Theme directory disappeared, exiting" >&2
  exit 1
fi

reload_tmux
SCRIPT

  chmod +x "$UPDATE_SCRIPT"
  log "Created monitor script"
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
    -v | --version)
      echo "$VERSION"
      exit 0
      ;;
    *) error "Unknown option: $1\nUse --help for usage" ;;
    esac
  done

  [[ $QUIET -eq 0 ]] && echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
  [[ $QUIET -eq 0 ]] && echo -e "${BLUE}║${NC}         ${BLUE}Omarchy Tmux Installer${NC}         ${BLUE}║${NC}"
  [[ $QUIET -eq 0 ]] && echo -e "${BLUE}╚════════════════════════════════════════╝${NC}\n"

  check_deps
  check_tpm
  install_plugin
  generate_theme_configs
  configure_tmux
  install_update_script
  install_hook

  if [[ $QUIET -eq 0 ]]; then
    echo -e "\n${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}        ${GREEN}✓${NC} Installation Complete         ${GREEN}║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}\n"
    echo "Next steps:"
    echo "  1. Start/restart tmux"
    echo "  2. Press 'prefix + I' (Ctrl+b Shift+i) to install plugins"
    echo "  3. Change theme with Super+Shift+Ctrl+Space"
    echo ""
  fi
}

main "$@"
