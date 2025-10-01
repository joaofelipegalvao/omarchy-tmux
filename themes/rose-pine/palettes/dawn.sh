#!/usr/bin/env bash

# Rosé Pine Dawn Palette for tmux
# https://rosepinetheme.com/palette/dawn/
declare -A PALETTE=(
  [none]="NONE"

  # Backgrounds
  [bg]="#faf4ed"           # Base
  [bg_dark]="#fffaf3"      # Surface
  [bg_highlight]="#f2e9e1" # Overlay
  [bg2]="#f4ede8"          # Highlight Low
  [bg3]="#cecacd"          # Highlight High

  # Foregrounds
  [fg]="#575279"           # Text
  [fg_dark]="#6e6a86"      # Extra (not official, derived)
  [fg_gutter]="#f2e9e1"    # Overlay reused
  [comment]="#9893a5"      # Muted
  [dark5]="#797593"        # Subtle

  # Selection
  [selbg]="#dfdad9"        # Highlight Med
  [selfg]="#575279"

  # Main palette accents
  [red]="#b4637a"          # Love
  [orange]="#ea9d34"       # Gold (warm yellow/orange)
  [yellow]="#ea9d34"       # Gold (alias)
  [pink]="#d7827e"         # Rose (alias)
  [rose]="#d7827e"         # Rose (explicit)
  [magenta]="#907aa9"      # Iris
  [blue]="#56949f"         # Foam
  [cyan]="#56949f"         # Foam (alias)
  [green]="#286983"        # Pine
  [teal]="#56949f"         # Foam (extra alias)

  # Grays
  [gray]="#9893a5"         # Muted
  [gray1]="#797593"        # Subtle
  [gray2]="#6e6a86"        # Derived darker fg

  # Git colors (mapped from accents)
  [git_add]="#56949f"      # Foam
  [git_change]="#d7827e"   # Rose
  [git_delete]="#b4637a"   # Love

  # Terminal helpers
  [terminal_black]="#575279"
  [white]="#faf4ed"
)

export PALETTE
