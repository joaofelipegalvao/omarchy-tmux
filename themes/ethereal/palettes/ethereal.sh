#!/usr/bin/env bash

# Ethereal Palette (extracted from Neovim theme)
declare -A PALETTE=(
  [none]="NONE"

  # Backgrounds
  [bg]="#060B1E"
  [bg_dark]="#060B1E"
  [bg_dark1]="#060B1E"
  [bg_highlight]="#060B1E"

  # Foregrounds
  [fg]="#ffcead"
  [fg_dark]="#F99957"
  [fg_gutter]="#6d7db6"

  # Blues
  [blue]="#7d82d9"
  [blue0]="#264f78"
  [blue1]="#7d82d9"
  [blue2]="#7d82d9"
  [blue5]="#a3bfd1"
  [blue6]="#b4f9f8"
  [blue7]="#1e3a5f"

  # Other colors
  [white]="#ffffff"
  [cyan]="#a3bfd1"
  [teal]="#a3bfd1"
  [comment]="#6d7db6"
  [dark3]="#6d7db6"
  [dark5]="#F99957"

  [green]="#92a593"
  [green1]="#92a593"
  [green2]="#92a593"

  [magenta]="#c89dc1"
  [magenta2]="#8e93de"

  [orange]="#faaaa9"
  [purple]="#c89dc1"

  [red]="#ED5B5A"
  [red1]="#ED5B5A"

  [yellow]="#E9BB4F"

  [terminal_black]="#6d7db6"

  # Special
  [special_char]="#f7dc9c"

  # Git (Neovim generates these, so we mirror)
  [git_add]="#92a593"
  [git_delete]="#ED5B5A"
  [git_change]="#faaaa9"
)

export PALETTE
