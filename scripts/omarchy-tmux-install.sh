#!/bin/bash
# Omarchy Tmux - PowerKit Configurator
# Configures tmux-powerkit with Omarchy theme auto-sync via symlinks
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
    warn "Installation failed - some changes may be incomplete"
    warn "Check error messages above for details"
    warn "You can safely re-run the installer to retry"
  fi
}
trap cleanup EXIT

usage() {
  cat <<EOF
Omarchy Tmux Installer v$VERSION

Configures tmux-powerkit to auto-sync with Omarchy themes via symlinks.

Usage: $(basename "$0") [OPTIONS]

Options:
  -h, --help     Show this help
  -q, --quiet    Minimal output
  -f, --force    Force reinstall
  -v, --version  Show version

Requirements:
  - Omarchy Linux 3.1+
  - tmux
  - TPM (Tmux Plugin Manager)

Architecture:
  ~/.config/tmux/tmux.conf (static)
    ↓ source-file
  ~/.config/omarchy/current/theme/tmux.conf (symlink)
    ↓ points to
  ~/.config/omarchy/themes/THEME/tmux.conf (generated)

EOF
  exit 0
}

# Dependency Checks
check_deps() {
  local missing=()

  # Check Omarchy
  if [[ ! -d "$OMARCHY_DIR" ]]; then
    error "Omarchy not found at $OMARCHY_DIR
This installer is for Omarchy Linux users.
Visit: https://omarchy.org"
  fi

  # Check Omarchy hooks support
  if [[ ! -d "$(dirname "$HOOK_FILE")" ]]; then
    error "Omarchy hooks directory not found.
Please upgrade to Omarchy 3.1 or later."
  fi

  # Check themes directory
  if [[ ! -d "$THEMES_DIR" ]]; then
    error "Omarchy themes directory not found at $THEMES_DIR"
  fi

  # Check dependencies
  command -v tmux >/dev/null 2>&1 || missing+=("tmux")
  command -v git >/dev/null 2>&1 || missing+=("git")

  if [[ ${#missing[@]} -gt 0 ]]; then
    error "Missing dependencies: ${missing[*]}
Install: sudo pacman -S ${missing[*]}"
  fi

  log "Dependencies OK"
}

check_tpm() {
  local tpm_locations=(
    "$HOME/.config/tmux/plugins/tpm"
    "$HOME/.tmux/plugins/tpm"
  )

  for loc in "${tpm_locations[@]}"; do
    if [[ -d "$loc" ]]; then
      log "TPM found"
      return 0
    fi
  done

  cat <<EOF
${RED}✗${NC} TPM (Tmux Plugin Manager) not found.

Install it:
  ${CYAN}git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm${NC}

Then run this installer again.

Learn more: ${BLUE}https://github.com/tmux-plugins/tpm${NC}
EOF
  exit 1
}

# Theme Mapping
map_theme_to_powerkit() {
  local theme="$1"
  local base variant

  case "$theme" in
  # Catppuccin variants
  catppuccin-latte)
    base="catppuccin"
    variant="latte"
    ;;
  catppuccin | catppuccin-macchiato)
    base="catppuccin"
    variant="macchiato"
    ;;
  catppuccin-frappe)
    base="catppuccin"
    variant="frappe"
    ;;
  catppuccin-mocha)
    base="catppuccin"
    variant="mocha"
    ;;

  # Rose Pine variants
  rose-pine | rose-pine-dawn)
    base="rose-pine"
    variant="dawn"
    ;;
  rose-pine-main)
    base="rose-pine"
    variant="main"
    ;;
  rose-pine-moon)
    base="rose-pine"
    variant="moon"
    ;;

  # Tokyo Night variants
  tokyo-night | tokyo-night-night)
    base="tokyo-night"
    variant="night"
    ;;
  tokyo-night-storm)
    base="tokyo-night"
    variant="storm"
    ;;
  tokyo-night-day)
    base="tokyo-night"
    variant="day"
    ;;

  # Everforest variants
  everforest | everforest-dark)
    base="everforest"
    variant="dark"
    ;;
  everforest-light)
    base="everforest"
    variant="light"
    ;;

  # Gruvbox variants
  gruvbox | gruvbox-dark)
    base="gruvbox"
    variant="dark"
    ;;
  gruvbox-light)
    base="gruvbox"
    variant="light"
    ;;

  # Kanagawa variants
  kanagawa | kanagawa-dragon)
    base="kanagawa"
    variant="dragon"
    ;;
  kanagawa-lotus)
    base="kanagawa"
    variant="lotus"
    ;;

  # Flexoki variants
  flexoki | flexoki-light)
    base="flexoki"
    variant="light"
    ;;
  flexoki-dark)
    base="flexoki"
    variant="dark"
    ;;

  # Nord
  nord)
    base="nord"
    variant="dark"
    ;;

  # Dracula
  dracula | dracula-dark)
    base="dracula"
    variant="dark"
    ;;

  # Solarized variants
  solarized | solarized-dark)
    base="solarized"
    variant="dark"
    ;;
  solarized-light)
    base="solarized"
    variant="light"
    ;;

  # GitHub variants
  github | github-dark)
    base="github"
    variant="dark"
    ;;
  github-light)
    base="github"
    variant="light"
    ;;

  # Ayu variants
  ayu | ayu-dark)
    base="ayu"
    variant="dark"
    ;;
  ayu-light)
    base="ayu"
    variant="light"
    ;;
  ayu-mirage)
    base="ayu"
    variant="mirage"
    ;;

  # Material variants
  material | material-default)
    base="material"
    variant="default"
    ;;
  material-ocean)
    base="material"
    variant="ocean"
    ;;
  material-palenight)
    base="material"
    variant="palenight"
    ;;
  material-lighter)
    base="material"
    variant="lighter"
    ;;

  # Monokai variants
  monokai | monokai-dark)
    base="monokai"
    variant="dark"
    ;;
  monokai-light)
    base="monokai"
    variant="light"
    ;;

  # OneDark
  onedark | onedark-dark)
    base="onedark"
    variant="dark"
    ;;

  # Atom
  atom | atom-dark)
    base="atom"
    variant="dark"
    ;;

  # Cobalt2
  cobalt2)
    base="cobalt2"
    variant="default"
    ;;

  # Darcula
  darcula)
    base="darcula"
    variant="default"
    ;;

  # Horizon
  horizon)
    base="horizon"
    variant="default"
    ;;

  # Iceberg variants
  iceberg | iceberg-dark)
    base="iceberg"
    variant="dark"
    ;;
  iceberg-light)
    base="iceberg"
    variant="light"
    ;;

  # Kiribyte variants
  kiribyte | kiribyte-dark)
    base="kiribyte"
    variant="dark"
    ;;
  kiribyte-light)
    base="kiribyte"
    variant="light"
    ;;

  # Molokai
  molokai | molokai-dark)
    base="molokai"
    variant="dark"
    ;;

  # Moonlight
  moonlight)
    base="moonlight"
    variant="default"
    ;;

  # Night Owl variants
  night-owl | night-owl-default)
    base="night-owl"
    variant="default"
    ;;
  night-owl-light)
    base="night-owl"
    variant="light"
    ;;

  # Oceanic Next variants
  oceanic-next | oceanic-next-default)
    base="oceanic-next"
    variant="default"
    ;;
  oceanic-next-darker)
    base="oceanic-next"
    variant="darker"
    ;;

  # Pastel variants
  pastel | pastel-dark)
    base="pastel"
    variant="dark"
    ;;
  pastel-light)
    base="pastel"
    variant="light"
    ;;

  # Poimandres
  poimandres)
    base="poimandres"
    variant="default"
    ;;

  # Slack
  slack | slack-dark)
    base="slack"
    variant="dark"
    ;;

  # Snazzy
  snazzy)
    base="snazzy"
    variant="default"
    ;;

  # Spacegray
  spacegray | spacegray-dark)
    base="spacegray"
    variant="dark"
    ;;

  # Synthwave
  synthwave | synthwave-84)
    base="synthwave"
    variant="84"
    ;;

  # Vesper
  vesper)
    base="vesper"
    variant="default"
    ;;

  # Unsupported themes (fallback to tokyo-night)
  ethereal | hackerman | matte-black | osaka* | ristretto)
    base="tokyo-night"
    variant="night"
    ;;

  # Unknown (fallback)
  *)
    base="tokyo-night"
    variant="night"
    ;;
  esac

  echo "$base|$variant"
}

# Generate Theme Configs
generate_theme_configs() {
  log "Generating theme configs..."

  local count=0
  local skipped=0
  local failed=0

  # Process ONLY existing theme directories created by Omarchy
  for theme_dir in "$THEMES_DIR"/*; do
    [[ ! -d "$theme_dir" ]] && continue

    local theme_name=$(basename "$theme_dir")
    local tmux_file="$theme_dir/tmux.conf"

    # Skip if already exists and not forcing
    if [[ -f "$tmux_file" && $FORCE -eq 0 ]]; then
      ((skipped++)) || true
      continue
    fi

    # Verify write permission
    if [[ ! -w "$theme_dir" ]]; then
      warn "Cannot write to $theme_dir (skipping $theme_name)"
      ((failed++)) || true
      continue
    fi

    # Map theme to PowerKit
    local theme_config=$(map_theme_to_powerkit "$theme_name")
    IFS='|' read -r base variant <<<"$theme_config"

    # Generate tmux.conf for this theme
    if ! cat >"$tmux_file" <<EOF; then
# ============================================================================
# Omarchy Tmux Theme: $theme_name
# Auto-generated by omarchy-tmux installer
# PowerKit Theme: $base${variant:+ ($variant)}
# ============================================================================

# PowerKit Plugin
set -g @plugin 'fabioluciano/tmux-powerkit'

# Theme Configuration
set -g @powerkit_theme '$base'
EOF
      warn "Failed to write config for $theme_name"
      ((failed++)) || true
      continue
    fi

    if [[ -n "$variant" ]]; then
      echo "set -g @powerkit_theme_variant '$variant'" >>"$tmux_file"
    fi

    cat >>"$tmux_file" <<'EOF'

# Plugins (customize as needed)
set -g @powerkit_plugins "datetime,battery,cpu,memory,hostname"

# Visual Options
set -g @powerkit_separator_style "normal"

# Performance
set -g @powerkit_status_interval "5"

# PowerKit keybindings
# Avoid conflicts with tmux default bindings (e.g. prefix + r)
set -g @powerkit_theme_selector_key "T"
set -g @powerkit_reload_config_key "R"

# ============================================================================
# Custom Configuration
# Add your tmux customizations below this line
# ============================================================================
EOF

    # Verify file was created successfully
    if [[ ! -f "$tmux_file" ]]; then
      warn "Config file creation failed for $theme_name"
      ((failed++)) || true
      continue
    fi

    ((count++)) || true
  done

  if [[ $count -gt 0 ]]; then
    log "Generated $count theme config(s)"
  fi

  if [[ $skipped -gt 0 ]]; then
    info "Skipped $skipped existing config(s) (use -f to regenerate)"
  fi

  if [[ $failed -gt 0 ]]; then
    warn "Failed to generate $failed config(s) (check permissions)"
  fi

  if [[ $count -eq 0 && $skipped -eq 0 ]]; then
    warn "No themes found in $THEMES_DIR"
  fi
}

# Configure Main Tmux Config
configure_tmux() {
  log "Configuring main tmux.conf..."

  CLEANUP_NEEDED=1

  local conf_dir
  conf_dir="$(dirname "$TMUX_CONF")"

  # Create directory with validation
  if ! mkdir -p "$conf_dir"; then
    error "Failed to create directory: $conf_dir"
  fi

  # Check write permission
  if [[ ! -w "$conf_dir" ]]; then
    error "Cannot write to $conf_dir
Check permissions and try again"
  fi

  # Create file if doesn't exist
  if [[ ! -f "$TMUX_CONF" ]]; then
    if ! touch "$TMUX_CONF"; then
      error "Failed to create $TMUX_CONF"
    fi
  fi

  local source_line="source-file ~/.config/omarchy/current/theme/tmux.conf"
  local anchor='^# Initialize and run tpm'

  # Already configured
  if grep -qF "$source_line" "$TMUX_CONF" 2>/dev/null; then
    log "Omarchy integration already configured"
    return 0
  fi

  # Create backup
  local backup="${TMUX_CONF}.backup-$(date +%Y%m%d-%H%M%S)"
  if ! cp "$TMUX_CONF" "$backup"; then
    error "Failed to create backup at $backup"
  fi
  info "Created backup at $backup"

  # Remove legacy v1 blocks if any
  sed -i '/# Omarchy Tmux integration/,/# End Omarchy Tmux integration/d' "$TMUX_CONF" 2>/dev/null || true

  # Ensure TPM plugin declaration exists
  if ! grep -q "set -g @plugin 'tmux-plugins/tpm'" "$TMUX_CONF" 2>/dev/null; then
    cat >>"$TMUX_CONF" <<'EOF'

# tpm plugin
set -g @plugin 'tmux-plugins/tpm'
EOF
  fi

  if grep -q "$anchor" "$TMUX_CONF"; then
    local tmp_file
    tmp_file="$(mktemp)"

    if ! awk '
      !inserted && /^# Initialize and run tpm/ {
        print "# ============================================================================"
        print "# Omarchy Tmux Integration (v2.0)"
        print "# Theme syncs automatically via symlink - DO NOT EDIT THIS SECTION"
        print "# ============================================================================"
        print "source-file ~/.config/omarchy/current/theme/tmux.conf"
        print "# End Omarchy Tmux Integration"
        print ""
        inserted = 1
      }
      { print }
    ' "$TMUX_CONF" >"$tmp_file"; then
      rm -f "$tmp_file"
      error "Failed to process tmux.conf with awk"
    fi

    if ! mv "$tmp_file" "$TMUX_CONF"; then
      rm -f "$tmp_file"
      error "Failed to update tmux.conf"
    fi
  else
    # Fallback: append clean block at end
    cat >>"$TMUX_CONF" <<'EOF'

# ============================================================================
# Omarchy Tmux Integration (v2.0)
# Theme syncs automatically via symlink - DO NOT EDIT THIS SECTION
# ============================================================================
source-file ~/.config/omarchy/current/theme/tmux.conf
# End Omarchy Tmux Integration

# Initialize and run tpm
run '~/.tmux/plugins/tpm/tpm'
EOF
  fi

  log "Configured tmux.conf with Omarchy integration"
}

# Reload Script
create_reload_script() {
  log "Creating reload script..."

  local script_dir
  script_dir="$(dirname "$RELOAD_SCRIPT")"

  # Create directory with validation
  if ! mkdir -p "$script_dir"; then
    error "Failed to create directory: $script_dir"
  fi

  # Check write permission
  if [[ ! -w "$script_dir" ]]; then
    error "Cannot write to $script_dir"
  fi

  if ! cat >"$RELOAD_SCRIPT" <<'SCRIPT'; then
#!/bin/bash
# Omarchy Tmux Reload Script
# Called by Omarchy when theme changes
# Simply reloads tmux to pick up the new symlink target

set -euo pipefail

readonly TMUX_CONF="$HOME/.config/tmux/tmux.conf"

# Reload all tmux sessions
if tmux list-sessions &>/dev/null 2>&1; then
  # Reload config
  tmux source-file "$TMUX_CONF" &>/dev/null || true
  
  # Refresh all clients
  tmux refresh-client -S &>/dev/null || true
fi

exit 0
SCRIPT
    error "Failed to create reload script"
  fi

  if ! chmod +x "$RELOAD_SCRIPT"; then
    error "Failed to make reload script executable"
  fi

  log "Created reload script"
}

# Install Hook
install_hook() {
  log "Installing Omarchy hook..."

  local hook_dir
  hook_dir="$(dirname "$HOOK_FILE")"

  # Verify directory exists and is writable
  if [[ ! -d "$hook_dir" ]]; then
    error "Hook directory not found: $hook_dir
Omarchy may not be properly installed"
  fi

  if [[ ! -w "$hook_dir" ]]; then
    error "Cannot write to $hook_dir
Check permissions and try again"
  fi

  # Create hook file if doesn't exist
  if [[ ! -f "$HOOK_FILE" ]]; then
    if ! cat >"$HOOK_FILE" <<'HOOK'; then
#!/bin/bash
# Omarchy theme-set hook
HOOK
      error "Failed to create hook file"
    fi
  fi

  # Ensure hook is executable
  if [[ ! -x "$HOOK_FILE" ]]; then
    if ! chmod +x "$HOOK_FILE"; then
      error "Failed to make hook executable"
    fi
    log "Made hook file executable"
  fi

  # Add our reload script to hook
  if ! grep -q 'omarchy-tmux-reload' "$HOOK_FILE"; then
    echo "$RELOAD_SCRIPT" >>"$HOOK_FILE"
    log "Hook installed"
  else
    log "Hook already installed"
  fi
}

# Validation
validate_setup() {
  log "Validating setup..."

  local current_link="$OMARCHY_DIR/current/theme"

  # Check if current theme symlink exists
  if [[ ! -L "$current_link" ]]; then
    warn "Current theme symlink not found at $current_link"
    warn "Omarchy may not be fully configured"
    return 1
  fi

  # Check if target exists
  if [[ ! -e "$current_link" ]]; then
    warn "Current theme symlink is broken"
    return 1
  fi

  # Check if theme has tmux.conf
  local theme_tmux="$current_link/tmux.conf"
  if [[ ! -f "$theme_tmux" ]]; then
    warn "Current theme doesn't have tmux.conf"
    warn "Run this installer again or switch themes to generate it"
    return 1
  fi

  log "Setup validated successfully"
  return 0
}

# Main
main() {
  # Parse arguments
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
    *) error "Unknown option: $1
Use --help for usage" ;;
    esac
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
    echo -e "${CYAN}                           Tmux PowerKit Installer${NC}"
    echo ""
    echo -e "${CYAN}Architecture:${NC}"
    echo "  Static tmux.conf sources symlink"
    echo "  → Omarchy controls active theme"
    echo "  → No config editing on theme change"
    echo ""
  fi

  # Install
  check_deps
  check_tpm
  generate_theme_configs
  configure_tmux
  create_reload_script
  install_hook

  # Validate
  local validation_ok=0
  validate_setup && validation_ok=1 || validation_ok=0

  # Success message
  if [[ $QUIET -eq 0 ]]; then
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}     ${GREEN}✓${NC} Installation Complete            ${GREEN}║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    echo ""
    echo "  1. Start tmux:"
    echo -e "     ${YELLOW}tmux${NC}"
    echo ""
    echo "  2. Install PowerKit via TPM:"
    echo -e "     Press ${YELLOW}prefix + I${NC} (Ctrl+b Shift+i)"
    echo "     "
    echo "  3. Wait for installation to complete"
    echo ""
    echo "  4. Test theme switching:"
    echo -e "     ${YELLOW}Super + Ctrl + Shift + Space${NC}"
    echo "     → tmux updates automatically!"
    echo ""
    echo -e "${CYAN}How it works:${NC}"
    echo -e "  • Your tmux.conf sources: ${YELLOW}~/.config/omarchy/current/theme/tmux.conf${NC}"
    echo "  • This is a symlink that Omarchy controls"
    echo "  • When theme changes, symlink updates → tmux reloads"
    echo ""
    echo -e "${YELLOW}Unsupported (fallback to tokyo-night):${NC}"
    echo "  ⚠  ethereal, hackerman, matte-black, osaka, ristretto"
    echo ""
    echo -e "${CYAN}Customization:${NC}"
    echo "  Edit per-theme configs:"
    echo -e "  ${YELLOW}~/.config/omarchy/themes/THEME_NAME/tmux.conf${NC}"
    echo "  "
    echo "  Changes persist across theme switches!"
    echo ""

    if [[ $validation_ok -eq 0 ]]; then
      echo -e "${YELLOW}⚠ Note:${NC} Setup validation had warnings."
      echo "  This is usually fine - just switch themes once to generate configs."
      echo ""
    fi

    echo -e "${GREEN}Enjoy your enhanced tmux! 🎉${NC}"
    echo ""
  fi
}

main "$@"
