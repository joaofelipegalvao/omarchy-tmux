#!/usr/bin/env bash

# Matte Black Palette
# Based on: https://github.com/tahayvr/matteblack.nvim
declare -A PALETTE=(
  [none]="NONE"
  [bg]="#121212"
  [bg_dark]="#0d0d0d"
  [bg_highlight]="#1e1e1e"
  [bg2]="#2c2c2c"
  [bg3]="#333333"
  [terminal_black]="#262626"

  # Foregrounds
  [fg]="#eaeaea"
  [fg_dark]="#bebebe"
  [fg_gutter]="#2c2c2c"
  [comment]="#8a8a8d"
  [dark5]="#5c6370"

  # Selection
  [selbg]="#262626"
  [selfg]="#eaeaea"

  # Primary accent colors
  [red]="#b91c1c"
  [red1]="#9b1313"
  [orange]="#f59e0b"
  [amber]="#d97706"

  # Extended warm palette
  [yellow]="#fbbf24"
  [gold]="#efbf04"
  [ochre]="#bf9903"
  # Pink/Magenta tones
  [pink]="#f87171"
  [magenta]="#dc2626"
  [magenta2]="#9b1313"

  # Grays
  [gray]="#5c6370"
  [gray1]="#a3a3a3"
  [gray2]="#737373"
  [fg2]="#8a8a8d"
  [fg3]="#bebebe"

  # Blues (adaptados do tema, mantendo consistência)
  [blue0]="#2c2c2c"
  [blue]="#5c6370"
  [cyan]="#a3a3a3"
  [blue1]="#737373"
  [blue2]="#5c6370"
  [blue5]="#a3a3a3"
  [blue6]="#bebebe"
  [blue7]="#1e1e1e"

  # Purples (usando tons do tema)
  [purple]="#dc2626"
  # Greens (adaptados)
  [green]="#efbf04"
  [green1]="#bf9903"
  [green2]="#d97706"
  [teal]="#d97706"

  # Git colors
  [git_change]="#fbbf24"
  [git_add]="#efbf04"
  [git_delete]="#b91c1c"

  # White
  [white]="#ffffff"
)

export PALETTE
