#!/bin/bash
# omarchy-tmux — tmux-powerkit integration for Omarchy
# https://github.com/joaofelipegalvao/omarchy-tmux

set -euo pipefail

readonly POWERKIT_DIR="$HOME/.config/tmux/plugins/tmux-powerkit"
readonly POWERKIT_THEME_CONF="$HOME/.config/tmux/powerkit-theme.conf"
readonly THEME_SET_SCRIPT="$HOME/.local/bin/omarchy-tmux-theme-set"
readonly THEME_SET_HOOK="$HOME/.config/omarchy/hooks/theme-set"
readonly POST_UPDATE_HOOK="$HOME/.config/omarchy/hooks/post-update"
readonly TMUX_CONF="$HOME/.config/tmux/tmux.conf"
readonly OMARCHY_THEME_NAME="$HOME/.config/omarchy/current/theme.name"

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

log() { echo -e "${GREEN}▶${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC} $*" >&2; }
error() {
  echo -e "${RED}✗${NC} $*" >&2
  exit 1
}

# ---------------------------------------------------------------------------
# Theme mapping
# ---------------------------------------------------------------------------
map_theme() {
  local theme="$1"
  local base="tokyo-night"
  local variant="night"

  case "$theme" in
  catppuccin-latte)
    base="catppuccin"
    variant="latte"
    ;;
  catppuccin)
    base="catppuccin"
    variant="mocha"
    ;;
  ethereal)
    base="ethereal"
    variant="default"
    ;;
  everforest)
    base="everforest"
    variant="dark"
    ;;
  flexoki-light)
    base="flexoki"
    variant="light"
    ;;
  gruvbox)
    base="gruvbox"
    variant="dark"
    ;;
  hackerman)
    base="hackerman"
    variant="default"
    ;;
  kanagawa)
    base="kanagawa"
    variant="dragon"
    ;;
  matte-black)
    base="matte-black"
    variant="default"
    ;;
  miasma)
    base="miasma"
    variant="default"
    ;;
  nord)
    base="nord"
    variant="dark"
    ;;
  osaka-jade)
    base="osaka-jade"
    variant="default"
    ;;
  ristretto)
    base="ristretto"
    variant="default"
    ;;
  rose-pine)
    base="rose-pine"
    variant="main"
    ;;
  tokyo-night)
    base="tokyo-night"
    variant="night"
    ;;
  vantablack)
    base="vantablack"
    variant="default"
    ;;
  white)
    base="white"
    variant="default"
    ;;
  *)
    base="tokyo-night"
    variant="night"
    ;;
  esac

  echo "$base|$variant"
}

# ---------------------------------------------------------------------------
# Check dependencies
# ---------------------------------------------------------------------------
check_deps() {
  [[ -d "$HOME/.config/omarchy" ]] ||
    error "Omarchy not found. Visit: https://omarchy.org"

  command -v tmux >/dev/null 2>&1 ||
    error "tmux not found. Install: sudo pacman -S tmux"

  command -v git >/dev/null 2>&1 ||
    error "git not found. Install: sudo pacman -S git"

  log "Dependencies OK"
}

# ---------------------------------------------------------------------------
# Install tmux-powerkit (skip if already installed via TPM)
# ---------------------------------------------------------------------------
install_powerkit() {
  if [[ -d "$POWERKIT_DIR" ]]; then
    log "tmux-powerkit already installed at $POWERKIT_DIR"
    return 0
  fi

  log "Installing tmux-powerkit..."
  mkdir -p "$(dirname "$POWERKIT_DIR")"
  git clone --depth 1 \
    https://github.com/fabioluciano/tmux-powerkit.git \
    "$POWERKIT_DIR"
  log "tmux-powerkit installed"
}

# ---------------------------------------------------------------------------
# Create omarchy-tmux-theme-set script
# ---------------------------------------------------------------------------
create_theme_set_script() {
  log "Creating theme-set script..."
  mkdir -p "$(dirname "$THEME_SET_SCRIPT")"

  cat >"$THEME_SET_SCRIPT" <<'SCRIPT'
#!/bin/bash
# omarchy-tmux-theme-set — syncs tmux-powerkit theme with Omarchy
set -euo pipefail

readonly THEME_NAME_FILE="$HOME/.config/omarchy/current/theme.name"
readonly POWERKIT_THEME_CONF="$HOME/.config/tmux/powerkit-theme.conf"
readonly TMUX_CONF="$HOME/.config/tmux/tmux.conf"

[[ -f "$THEME_NAME_FILE" ]] || exit 0

theme=$(cat "$THEME_NAME_FILE" | tr -d '[:space:]')

map_theme() {
  local theme="$1"
  case "$theme" in
    catppuccin-latte)  echo "catppuccin|latte" ;;
    catppuccin)        echo "catppuccin|mocha" ;;
    ethereal)          echo "ethereal|default" ;;
    everforest)        echo "everforest|dark" ;;
    flexoki-light)     echo "flexoki|light" ;;
    gruvbox)           echo "gruvbox|dark" ;;
    hackerman)         echo "hackerman|default" ;;
    kanagawa)          echo "kanagawa|dragon" ;;
    matte-black)       echo "matte-black|default" ;;
    miasma)            echo "miasma|default" ;;
    nord)              echo "nord|dark" ;;
    osaka-jade)        echo "osaka-jade|default" ;;
    ristretto)         echo "ristretto|default" ;;
    rose-pine)         echo "rose-pine|main" ;;
    tokyo-night)       echo "tokyo-night|night" ;;
    vantablack)        echo "vantablack|default" ;;
    white)             echo "white|default" ;;
    *)                 echo "tokyo-night|night" ;;
  esac
}

IFS='|' read -r base variant <<<"$(map_theme "$theme")"

cat >"$POWERKIT_THEME_CONF" <<EOF
set -g @powerkit_theme "$base"
set -g @powerkit_theme_variant "$variant"
EOF

if tmux ls >/dev/null 2>&1; then
  tmux source-file "$TMUX_CONF"
fi
SCRIPT

  chmod +x "$THEME_SET_SCRIPT"
  log "Created $THEME_SET_SCRIPT"
}

# ---------------------------------------------------------------------------
# Configure tmux.conf
# ---------------------------------------------------------------------------
configure_tmux() {
  log "Configuring tmux.conf..."
  mkdir -p "$(dirname "$TMUX_CONF")"
  touch "$TMUX_CONF"

  # Check if already configured
  if grep -q "powerkit-theme.conf" "$TMUX_CONF" 2>/dev/null; then
    log "tmux.conf already configured"
    return 0
  fi

  # Detect TPM
  local has_tpm=0
  if grep -q "run.*tpm/tpm" "$TMUX_CONF" 2>/dev/null ||
    [[ -d "$HOME/.config/tmux/plugins/tpm" ]] ||
    [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
    has_tpm=1
  fi

  # Backup if exists
  if [[ -s "$TMUX_CONF" ]]; then
    cp "$TMUX_CONF" "${TMUX_CONF}.backup-$(date +%Y%m%d-%H%M%S)"
  fi

  # Check if powerkit already declared via @plugin
  local has_powerkit_plugin=0
  if grep -q "fabioluciano/tmux-powerkit" "$TMUX_CONF" 2>/dev/null; then
    has_powerkit_plugin=1
  fi

  if [[ $has_tpm -eq 1 ]]; then
    # TPM user: add theme loader before the TPM run line
    sed -i "\|run.*tpm/tpm|i # Load omarchy-tmux theme\nif-shell \"[ -f ~/.config/tmux/powerkit-theme.conf ]\" \"source-file ~/.config/tmux/powerkit-theme.conf\"\n" \
      "$TMUX_CONF" 2>/dev/null || true
    if [[ $has_powerkit_plugin -eq 0 ]]; then
      warn "Add 'set -g @plugin fabioluciano/tmux-powerkit' to your tmux.conf and press prefix + I"
    fi
  else
    # No TPM: add theme loader
    # Only add run-shell if powerkit not already declared
    if [[ $has_powerkit_plugin -eq 1 ]]; then
      cat >>"$TMUX_CONF" <<'EOF'

# omarchy-tmux — load powerkit theme
if-shell "[ -f ~/.config/tmux/powerkit-theme.conf ]" \
  "source-file ~/.config/tmux/powerkit-theme.conf"
EOF
    else
      cat >>"$TMUX_CONF" <<'EOF'

# omarchy-tmux — load powerkit theme
if-shell "[ -f ~/.config/tmux/powerkit-theme.conf ]" \
  "source-file ~/.config/tmux/powerkit-theme.conf"

# Load powerkit plugin
if-shell "[ -f ~/.config/tmux/plugins/tmux-powerkit/tmux-powerkit.tmux ]" \
  "run-shell ~/.config/tmux/plugins/tmux-powerkit/tmux-powerkit.tmux"
EOF
    fi
  fi

  log "tmux.conf configured"
}

# ---------------------------------------------------------------------------
# Install hooks
# ---------------------------------------------------------------------------
install_hooks() {
  log "Installing hooks..."
  mkdir -p "$(dirname "$THEME_SET_HOOK")"
  mkdir -p "$(dirname "$POST_UPDATE_HOOK")"

  # theme-set hook
  if [[ ! -f "$THEME_SET_HOOK" ]]; then
    printf '#!/bin/bash\n' >"$THEME_SET_HOOK"
    chmod +x "$THEME_SET_HOOK"
  fi

  if ! grep -q "omarchy-tmux-theme-set" "$THEME_SET_HOOK" 2>/dev/null; then
    echo "$THEME_SET_SCRIPT" >>"$THEME_SET_HOOK"
    log "theme-set hook installed"
  else
    log "theme-set hook already installed"
  fi

  # post-update hook (auto-update powerkit)
  if [[ ! -f "$POST_UPDATE_HOOK" ]]; then
    printf '#!/bin/bash\n' >"$POST_UPDATE_HOOK"
    chmod +x "$POST_UPDATE_HOOK"
  fi

  if ! grep -q "tmux-powerkit" "$POST_UPDATE_HOOK" 2>/dev/null; then
    cat >>"$POST_UPDATE_HOOK" <<'EOF'

# omarchy-tmux — update tmux-powerkit
if [[ -d "$HOME/.config/tmux/plugins/tmux-powerkit/.git" ]]; then
  git -C "$HOME/.config/tmux/plugins/tmux-powerkit" pull --ff-only
fi
EOF
    log "post-update hook installed"
  else
    log "post-update hook already installed"
  fi
}

# ---------------------------------------------------------------------------
# Generate initial theme config
# ---------------------------------------------------------------------------
generate_initial_theme() {
  log "Generating initial theme config..."
  "$THEME_SET_SCRIPT" || warn "Could not generate initial theme — switch themes once to apply"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
  echo ""
  echo -e "${CYAN}omarchy-tmux${NC}"
  echo -e "${CYAN}tmux-powerkit integration for Omarchy${NC}"
  echo ""

  check_deps
  install_powerkit
  create_theme_set_script
  configure_tmux
  install_hooks
  generate_initial_theme

  echo ""
  echo -e "${GREEN}✓ Installation complete!${NC}"
  echo ""
  echo -e "Next steps:"
  echo -e "  1. Reload tmux: ${YELLOW}tmux source-file ~/.config/tmux/tmux.conf${NC}"
  if grep -q "run.*tpm/tpm" "$TMUX_CONF" 2>/dev/null; then
    echo -e "  2. Install PowerKit via TPM: ${YELLOW}prefix + I${NC}"
  fi
  echo -e "  3. Switch themes and watch tmux sync automatically!"
  echo ""
}

main "$@"
