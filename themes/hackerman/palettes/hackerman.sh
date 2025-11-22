#!/usr/bin/env bash

# Hackerman Palette (from Aether Neovim theme)
declare -A PALETTE=(
  [none]="NONE"

  # Monotones
  [base00]="#0B0C16" # background
  [base01]="#6a6e95"
  [base02]="#0B0C16"
  [base03]="#6a6e95"
  [base04]="#85E1FB"
  [base05]="#ddf7ff"
  [base06]="#ddf7ff"
  [base07]="#85E1FB"

  # Accents
  [red]="#50f872" # variables, errors
  [orange]="#85ff9d"
  [yellow]="#50f7d4"
  [green]="#4fe88f"
  [aqua]="#7cf8f7"
  [blue]="#829dd4"
  [purple]="#86a7df"
  [brown]="#a4ffec"
  [white]="#ffffff"

  # Aliases for tmux consistency
  [bg]="#0B0C16"
  [bg_dim]="#0B0C16"
  [bg_dark]="#0B0C16"
  [bg_highlight]="#6a6e95"
  [fg]="#ddf7ff"
  [fg_gutter]="#6a6e95"
  [comment]="#6a6e95"
  [cyan]="#7cf8f7"
  [magenta]="#86a7df"
  [white]="#ddf7ff"
  [black]="#0B0C16"

  # Git colors
  [git_add]="#4fe88f"
  [git_change]="#50f7d4"
  [git_delete]="#50f872"
)

export PALETTE
