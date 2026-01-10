#!/bin/bash
# Omarchy Tmux - PowerKit Configurator (v2.1.0 - True Persistence)
# Architecture: Persistent Theme Profiles in ~/.config/tmux/omarchy-themes/
# https://github.com/joaofelipegalvao/omarchy-tmux

set -euo pipefail

readonly VERSION="2.1.0"
readonly TMUX_CONF="$HOME/.config/tmux/tmux.conf"
readonly RELOAD_SCRIPT="$HOME/.local/bin/omarchy-tmux-reload"
readonly GENERATOR_SCRIPT="$HOME/.local/bin/omarchy-tmux-generator"
readonly HOOK_FILE="$HOME/.config/omarchy/hooks/theme-set"
readonly OMARCHY_DIR="$HOME/.config/omarchy"
readonly PERSISTENT_THEMES_DIR="$HOME/.config/tmux/omarchy-themes"

QUIET=0
FORCE=0

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
info() { [[ $QUIET -eq 0 ]] && echo -e "${BLUE}ℹ ${NC} $*"; }

usage() {
  cat <<EOF
Omarchy Tmux Installer v$VERSION

Configures tmux-powerkit to work with Omarchy 3.3+.

Usage: $(basename "$0") [OPTIONS]

Options:
  -h, --help     Show this help
  -q, --quiet    Minimal output
  -f, --force    Force reinstall (regenerate all files)
  -v, --version  Show version

Architecture (v2.1):
  ~/.config/tmux/tmux.conf (static)
    ↓ source-file
  ~/.config/tmux/omarchy-current-theme.conf (symlink)
    ↓ points to
  ~/.config/tmux/omarchy-themes/THEME_NAME.conf (persistent profiles)

Changes are PERSISTENT per theme. Edit theme files directly!

EOF
  exit 0
}

check_deps() {
  local missing=()

  # Check Omarchy
  if [[ ! -d "$OMARCHY_DIR" ]]; then
    error "Omarchy not found at $OMARCHY_DIR
This installer is for Omarchy Linux users.
Visit: https://omarchy.org"
  fi

  # Check for aether (3.3+ indicator)
  if [[ ! -f "$OMARCHY_DIR/current/theme.name" ]]; then
    warn "Theme name file not found - this may be an older Omarchy version"
    warn "Expected: $OMARCHY_DIR/current/theme.name"
  fi

  # Check dependencies
  command -v tmux >/dev/null 2>&1 || missing+=("tmux")

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
      log "TPM found at $loc"
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

create_generator_script() {
  log "Creating persistent theme generator..."

  local script_dir="$(dirname "$GENERATOR_SCRIPT")"
  mkdir -p "$script_dir"
  mkdir -p "$PERSISTENT_THEMES_DIR"

  # Check if script exists and is current version
  if [[ -f "$GENERATOR_SCRIPT" && $FORCE -eq 0 ]]; then
    if grep -q "v2.1.0" "$GENERATOR_SCRIPT" 2>/dev/null; then
      info "Generator script already up to date"
      return 0
    fi
  fi

  cat >"$GENERATOR_SCRIPT" <<'GENERATOR'
#!/bin/bash
# Omarchy Tmux Theme Generator (v2.1.0)
# Generates and maintains persistent theme profiles
set -euo pipefail

readonly OMARCHY_DIR="$HOME/.config/omarchy"
readonly THEME_NAME_FILE="$OMARCHY_DIR/current/theme.name"
readonly PERSISTENT_THEMES_DIR="$HOME/.config/tmux/omarchy-themes"
readonly CURRENT_THEME_LINK="$HOME/.config/tmux/omarchy-current-theme.conf"

detect_theme() {
  local theme_name=""
  
  # Try reading from theme.name file
  if [[ -f "$THEME_NAME_FILE" ]]; then
    theme_name=$(cat "$THEME_NAME_FILE" | tr -d '[:space:]' 2>/dev/null || echo "")
  fi
  
  # Fallback to default
  echo "${theme_name:-tokyo-night}"
}

map_theme() {
  local theme="$1"
  local base="tokyo-night"
  local variant="night"
  
  case "$theme" in
    # Catppuccin variants
    catppuccin-latte)
      base="catppuccin"; variant="latte" ;;
    catppuccin|catppuccin-macchiato)
      base="catppuccin"; variant="macchiato" ;;
    catppuccin-frappe)
      base="catppuccin"; variant="frappe" ;;
    catppuccin-mocha)
      base="catppuccin"; variant="mocha" ;;
    
    # Rose Pine variants
    rose-pine|rose-pine-dawn)
      base="rose-pine"; variant="dawn" ;;
    rose-pine-main)
      base="rose-pine"; variant="main" ;;
    rose-pine-moon)
      base="rose-pine"; variant="moon" ;;
    
    # Tokyo Night variants
    tokyo-night|tokyo-night-night)
      base="tokyo-night"; variant="night" ;;
    tokyo-night-storm)
      base="tokyo-night"; variant="storm" ;;
    tokyo-night-day)
      base="tokyo-night"; variant="day" ;;
    
    # Everforest variants
    everforest|everforest-dark)
      base="everforest"; variant="dark" ;;
    everforest-light)
      base="everforest"; variant="light" ;;
    
    # Gruvbox variants
    gruvbox|gruvbox-dark)
      base="gruvbox"; variant="dark" ;;
    gruvbox-light)
      base="gruvbox"; variant="light" ;;
    
    # Kanagawa variants
    kanagawa|kanagawa-dragon)
      base="kanagawa"; variant="dragon" ;;
    kanagawa-lotus)
      base="kanagawa"; variant="lotus" ;;
    
    # Flexoki variants
    flexoki|flexoki-light)
      base="flexoki"; variant="light" ;;
    flexoki-dark)
      base="flexoki"; variant="dark" ;;
    
    # Nord
    nord)
      base="nord"; variant="dark" ;;
    
    # Dracula
    dracula|dracula-dark)
      base="dracula"; variant="dark" ;;
    
    # Solarized variants
    solarized|solarized-dark)
      base="solarized"; variant="dark" ;;
    solarized-light)
      base="solarized"; variant="light" ;;
    
    # GitHub variants
    github|github-dark)
      base="github"; variant="dark" ;;
    github-light)
      base="github"; variant="light" ;;
    
    # Ayu variants
    ayu|ayu-dark)
      base="ayu"; variant="dark" ;;
    ayu-light)
      base="ayu"; variant="light" ;;
    ayu-mirage)
      base="ayu"; variant="mirage" ;;
    
    # Material variants
    material|material-default)
      base="material"; variant="default" ;;
    material-ocean)
      base="material"; variant="ocean" ;;
    material-palenight)
      base="material"; variant="palenight" ;;
    material-lighter)
      base="material"; variant="lighter" ;;
    
    # Other themes with generic handling
    monokai*|onedark*|atom*|iceberg*|night-owl*|oceanic-next*|pastel*)
      base=$(echo "$theme" | cut -d'-' -f1)
      variant=$(echo "$theme" | cut -s -d'-' -f2-)
      variant=${variant:-dark}
      ;;
    
    # Unsupported themes (fallback)
    ethereal|hackerman|matte-black|osaka*|ristretto)
      base="tokyo-night"; variant="night" ;;
    
    # Unknown (fallback)
    *)
      base="tokyo-night"; variant="night" ;;
  esac
  
  echo "$base|$variant"
}

# Main execution
theme_name=$(detect_theme)
theme_file="$PERSISTENT_THEMES_DIR/$theme_name.conf"

# Create persistent theme file ONLY if it doesn't exist
if [[ ! -f "$theme_file" ]]; then
  IFS='|' read -r base variant <<<"$(map_theme "$theme_name")"
  
  cat >"$theme_file" <<EOF
# ============================================================================
# Omarchy Tmux Theme: $theme_name
# PowerKit Theme: $base${variant:+ ($variant)}
# ============================================================================
# 
# PERSISTENT THEME PROFILE
# This file is yours to customize! Your changes will persist across theme
# switches - when you return to this theme, your customizations remain.
#
# ============================================================================

# PowerKit Plugin
set -g @plugin 'fabioluciano/tmux-powerkit'

# Theme Configuration
set -g @powerkit_theme '$base'
EOF
  
  if [[ -n "$variant" ]]; then
    echo "set -g @powerkit_theme_variant '$variant'" >>"$theme_file"
  fi
  
  cat >>"$theme_file" <<'EOF'

# Plugins (customize as needed)
set -g @powerkit_plugins "datetime,battery,cpu,memory,hostname"

# Visual Options
set -g @powerkit_separator_style "normal"

# Performance
set -g @powerkit_status_interval "5"

# PowerKit keybindings
set -g @powerkit_theme_selector_key "T"
set -g @powerkit_reload_config_key "R"

# ============================================================================
EOF
fi

# Update symlink to point to current theme's persistent profile
ln -sf "$theme_file" "$CURRENT_THEME_LINK"

exit 0
GENERATOR

  chmod +x "$GENERATOR_SCRIPT" || error "Failed to make generator executable"
  log "Created generator script"
}

configure_tmux() {
  log "Configuring main tmux.conf..."

  local conf_dir="$(dirname "$TMUX_CONF")"
  mkdir -p "$conf_dir" || error "Failed to create $conf_dir"

  # Create file if doesn't exist
  if [[ ! -f "$TMUX_CONF" ]]; then
    touch "$TMUX_CONF" || error "Failed to create $TMUX_CONF"
  fi

  local source_line="source-file ~/.config/tmux/omarchy-current-theme.conf"

  # Check if already configured
  if grep -qF "$source_line" "$TMUX_CONF" 2>/dev/null; then
    log "Omarchy integration already configured"
    return 0
  fi

  # Create backup
  if [[ -s "$TMUX_CONF" ]]; then
    local backup="${TMUX_CONF}.backup-$(date +%Y%m%d-%H%M%S)"
    cp "$TMUX_CONF" "$backup" && info "Created backup at $backup"
  fi

  # Remove old v2.0 blocks if present
  sed -i '/# Omarchy Tmux Integration (v2.0)/,/# End Omarchy Tmux Integration/d' "$TMUX_CONF" 2>/dev/null || true

  # Check if user already has TPM run line
  local has_tpm_run=0
  if grep -q "run.*tpm/tpm" "$TMUX_CONF" 2>/dev/null; then
    has_tpm_run=1
    # Remove existing TPM run lines (we'll add it back at the end)
    sed -i '/# Initialize and run tpm/d' "$TMUX_CONF" 2>/dev/null || true
    sed -i '\|run.*tpm/tpm|d' "$TMUX_CONF" 2>/dev/null || true
    info "Found existing TPM initialization - will move to end"
  fi

  # Add integration block
  cat >>"$TMUX_CONF" <<'EOF'

# ============================================================================
# Omarchy Tmux Integration (v2.1)
# Theme profiles persist in ~/.config/tmux/omarchy-themes/
# Current theme syncs via symlink - DO NOT EDIT THIS SECTION
# ============================================================================
source-file ~/.config/tmux/omarchy-current-theme.conf
# End Omarchy Tmux Integration
EOF

  # Add TPM run line at the end if user had it
  if [[ $has_tpm_run -eq 1 ]]; then
    cat >>"$TMUX_CONF" <<'EOF'

# Initialize and run tpm
run '~/.tmux/plugins/tpm/tpm'
EOF
    info "TPM initialization moved to end of config"
  fi

  log "Configured tmux.conf with Omarchy integration"
}

create_reload_script() {
  log "Creating reload script..."

  local script_dir="$(dirname "$RELOAD_SCRIPT")"
  mkdir -p "$script_dir" || error "Failed to create $script_dir"

  cat >"$RELOAD_SCRIPT" <<'SCRIPT'
#!/bin/bash
# Omarchy Tmux Reload Script (v2.1.0)
# Called by Omarchy when theme changes
set -euo pipefail

readonly GENERATOR="$HOME/.local/bin/omarchy-tmux-generator"
readonly TMUX_CONF="$HOME/.config/tmux/tmux.conf"

# Regenerate current theme config
if [[ -x "$GENERATOR" ]]; then
  "$GENERATOR" &>/dev/null || true
fi

# Reload tmux if running
if tmux list-sessions &>/dev/null 2>&1; then
  tmux source-file "$TMUX_CONF" &>/dev/null || true
  tmux refresh-client -S &>/dev/null || true
fi

exit 0
SCRIPT

  chmod +x "$RELOAD_SCRIPT" || error "Failed to make reload script executable"
  log "Created reload script"
}

install_hook() {
  log "Installing Omarchy hook..."

  local hook_dir="$(dirname "$HOOK_FILE")"

  # Verify hook directory exists
  if [[ ! -d "$hook_dir" ]]; then
    warn "Hook directory not found: $hook_dir"
    warn "Creating it now (may require Omarchy restart)"
    mkdir -p "$hook_dir" || error "Failed to create hook directory"
  fi

  # Create hook file if doesn't exist
  if [[ ! -f "$HOOK_FILE" ]]; then
    cat >"$HOOK_FILE" <<'HOOK'
#!/bin/bash
# Omarchy theme-set hook
HOOK
    chmod +x "$HOOK_FILE" || error "Failed to make hook executable"
  fi

  # Ensure hook is executable
  [[ ! -x "$HOOK_FILE" ]] && chmod +x "$HOOK_FILE"

  # Add reload script to hook if not present
  if ! grep -q 'omarchy-tmux-reload' "$HOOK_FILE" 2>/dev/null; then
    echo "$RELOAD_SCRIPT" >>"$HOOK_FILE"
    log "Hook installed"
  else
    log "Hook already installed"
  fi
}

validate_setup() {
  log "Validating setup..."

  local issues=0

  # Check if generator script exists and is executable
  if [[ ! -x "$GENERATOR_SCRIPT" ]]; then
    warn "Generator script not executable"
    ((issues++))
  fi

  # Check if persistent themes directory exists
  if [[ ! -d "$PERSISTENT_THEMES_DIR" ]]; then
    warn "Persistent themes directory not found"
    ((issues++))
  fi

  # Try to detect current theme
  local theme_name_file="$OMARCHY_DIR/current/theme.name"
  if [[ ! -f "$theme_name_file" ]]; then
    warn "Current theme name file not found at $theme_name_file"
    warn "This is expected on older Omarchy versions"
    ((issues++))
  fi

  if [[ $issues -eq 0 ]]; then
    log "Setup validated successfully"
    return 0
  else
    warn "Setup validation found $issues issue(s)"
    return 1
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
    echo -e "${CYAN}                    Tmux PowerKit Installer v$VERSION${NC}"
    echo ""
    echo -e "${CYAN}New Architecture (v2.1):${NC}"
    echo "  ✓ Works with Omarchy 3.3+"
    echo "  ✓ Persistent theme profiles"
    echo "  ✓ No themes directory needed"
    echo ""
  fi

  # Installation steps
  check_deps
  check_tpm
  create_generator_script

  # Generate initial theme config
  if [[ -x "$GENERATOR_SCRIPT" ]]; then
    log "Generating initial theme configuration..."
    "$GENERATOR_SCRIPT" || warn "Initial theme generation failed (will retry on theme change)"
  fi

  configure_tmux
  create_reload_script
  install_hook

  # Validation
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
    echo ""
    echo "  3. Wait for installation to complete"
    echo ""
    echo "  4. Test theme switching:"
    echo -e "     ${YELLOW}Super + Ctrl + Shift + Space${NC}"
    echo "     → tmux updates automatically!"
    echo ""
    echo -e "${CYAN}How it works:${NC}"
    echo -e "  • Your tmux.conf sources: ${YELLOW}~/.config/tmux/omarchy-current-theme.conf${NC}"
    echo -e "  • This symlink points to: ${YELLOW}~/.config/tmux/omarchy-themes/THEME.conf${NC}"
    echo -e "  • Each theme has its own persistent profile"
    echo -e "  • Your customizations are preserved per theme!"
    echo ""
    echo -e "${CYAN}Customization:${NC}"
    echo -e "  Edit theme profiles directly:"
    echo -e "  ${YELLOW}~/.config/tmux/omarchy-themes/THEME_NAME.conf${NC}"
    echo ""
    echo -e "  Changes persist when you return to that theme!"
    echo ""

    if [[ $validation_ok -eq 0 ]]; then
      echo -e "${YELLOW}⚠ Note:${NC} Setup validation had warnings."
      echo "  This is usually fine - switch themes once to complete setup."
      echo ""
    fi

    echo -e "${GREEN}Enjoy your enhanced tmux! 🎉${NC}"
    echo ""
  fi
}

main "$@"
