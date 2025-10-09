#!/bin/bash
# Omarchy Tmux Theme - Installer
# https://github.com/joaofelipegalvao/omarchy-tmux

set -euo pipefail

readonly VERSION="1.0.0"
readonly REPO="https://github.com/joaofelipegalvao/omarchy-tmux.git"
readonly INSTALL_DIR="$HOME/.config/tmux/plugins/omarchy-tmux"
readonly TMUX_CONF="$HOME/.config/tmux/tmux.conf"
readonly MONITOR_SCRIPT="$HOME/.local/bin/omarchy-tmux-monitor"
readonly SYSTEMD_SERVICE="$HOME/.config/systemd/user/omarchy-tmux-monitor.service"
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

  command -v tmux >/dev/null 2>&1 || missing+=("tmux")
  command -v inotifywait >/dev/null 2>&1 || missing+=("inotify-tools")
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

install_monitor() {
  mkdir -p "$(dirname "$MONITOR_SCRIPT")"

  cat >"$MONITOR_SCRIPT" <<'SCRIPT'
#!/bin/bash
set -euo pipefail

readonly THEME_LINK="$HOME/.config/omarchy/current/theme"
readonly THEME_DIR="$(dirname "$THEME_LINK")"
readonly TMUX_CONF="$HOME/.config/tmux/tmux.conf"
readonly LOCKFILE="$HOME/.cache/omarchy-tmux.lock"

mkdir -p "$(dirname "$LOCKFILE")"

# Enhanced lockfile handling with stale detection
if [[ -e "$LOCKFILE" ]]; then
  lock_pid=$(cat "$LOCKFILE" 2>/dev/null || echo "")
  
  if [[ -n "$lock_pid" ]] && kill -0 "$lock_pid" 2>/dev/null; then
    # Check if lockfile is stale (older than 1 hour)
    lock_age=$(($(date +%s) - $(stat -c %Y "$LOCKFILE" 2>/dev/null || echo 0)))
    if [[ $lock_age -lt 3600 ]]; then
      exit 0
    fi
    echo "Warning: Removing stale lockfile (age: ${lock_age}s)" >&2
  fi
  rm -f "$LOCKFILE"
fi

echo $ >"$LOCKFILE"
trap 'rm -f "$LOCKFILE"; pkill -P $ 2>/dev/null || true' EXIT INT TERM

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

# Validate theme link exists
if [[ ! -L "$THEME_LINK" ]]; then
  sleep 5  # Wait for Omarchy to create the symlink
  if [[ ! -L "$THEME_LINK" ]]; then
    echo "Error: Theme symlink not found at $THEME_LINK" >&2
    exit 1
  fi
fi

# Validate theme directory exists
if [[ ! -d "$THEME_DIR" ]]; then
  echo "Error: Theme directory not found at $THEME_DIR" >&2
  exit 1
fi

LAST=$(readlink "$THEME_LINK" 2>/dev/null || echo "")

while IFS= read -r event; do
  [[ "$event" != "theme" ]] && continue
  
  CURRENT=$(readlink "$THEME_LINK" 2>/dev/null || echo "")
  
  if [[ "$CURRENT" != "$LAST" ]]; then
    sleep 0.2
    reload_tmux
    LAST="$CURRENT"
  fi
  
  # Verify directory still exists
  if [[ ! -d "$THEME_DIR" ]]; then
    echo "Warning: Theme directory disappeared, exiting" >&2
    exit 1
  fi
done < <(inotifywait -m -q -e create,delete,moved_to --format '%f' --timeout 86400 "$THEME_DIR" 2>&1)

# If we reach here, timeout occurred - restart monitoring
exec "$0"
SCRIPT

  chmod +x "$MONITOR_SCRIPT"
  log "Created monitor script"
}

setup_service() {
  mkdir -p "$(dirname "$SYSTEMD_SERVICE")"

  cat >"$SYSTEMD_SERVICE" <<EOF
[Unit]
Description=Omarchy Tmux Monitor
After=graphical-session.target

[Service]
Type=simple
ExecStart=$MONITOR_SCRIPT
Restart=always
RestartSec=5

[Install]
WantedBy=default.target
EOF

  if ! command -v systemctl >/dev/null 2>&1; then
    warn "systemctl not found. Run monitor manually: $MONITOR_SCRIPT &"
    return
  fi

  systemctl --user daemon-reload 2>&1 || warn "Failed to reload systemd"
  systemctl --user enable omarchy-tmux-monitor.service 2>&1 || warn "Failed to enable service"
  systemctl --user restart omarchy-tmux-monitor.service 2>&1 || warn "Failed to start service"

  sleep 1

  if systemctl --user is-active --quiet omarchy-tmux-monitor.service 2>/dev/null; then
    log "Service enabled and running"
  else
    warn "Service not running. Check: systemctl --user status omarchy-tmux-monitor"
  fi
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
  install_monitor
  setup_service

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
