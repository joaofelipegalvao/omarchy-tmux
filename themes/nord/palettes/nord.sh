#!/usr/bin/env bash

# Nord Palette
declare -A PALETTE=(
  [none]="NONE"
  
  # Polar Night (backgrounds)
  [nord0]="#2e3440"   # bg (darkest)
  [nord1]="#3b4252"   # bg_dark
  [nord2]="#434c5e"   # bg_highlight
  [nord3]="#4c566a"   # comment/brightblack
  
  # Snow Storm (foregrounds)
  [nord4]="#d8dee9"   # fg_dark
  [nord5]="#e5e9f0"   # fg
  [nord6]="#eceff4"   # fg_bright (brightest)
  
  # Frost (blues/cyans)
  [nord7]="#8fbcbb"   # teal/cyan (para hostname)
  [nord8]="#88c0d0"   # cyan_bright
  [nord9]="#81a1c1"   # blue
  [nord10]="#5e81ac"  # blue_dark
  
  # Aurora (accent colors)
  [nord11]="#bf616a"  # red
  [nord12]="#d08770"  # orange
  [nord13]="#ebcb8b"  # yellow
  [nord14]="#a3be8c"  # green
  [nord15]="#b48ead"  # purple/magenta
  
  # Aliases para facilitar uso
  [bg]="#2e3440"
  [bg_dark]="#3b4252"
  [bg_highlight]="#434c5e"
  [fg_gutter]="#4c566a"
  [comment]="#4c566a"
  [brightblack]="#4c566a"
  
  [fg]="#e5e9f0"
  [fg_dark]="#d8dee9"
  [white]="#eceff4"
  
  [cyan]="#8fbcbb"
  [blue]="#81a1c1"
  [blue_dark]="#5e81ac"
  
  [red]="#bf616a"
  [orange]="#d08770"
  [yellow]="#ebcb8b"
  [green]="#a3be8c"
  [magenta]="#b48ead"
  [purple]="#b48ead"
  
  # Terminal colors (para compatibilidade)
  [black]="#2e3440"
  [terminal_black]="#4c566a"
  
  # Git colors
  [git_add]="#a3be8c"
  [git_change]="#ebcb8b"
  [git_delete]="#bf616a"
)

export PALETTE
