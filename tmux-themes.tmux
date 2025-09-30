#!/usr/bin/env bash

# Multi-theme tmux plugin
PLUGIN_VERSION=2.0.0
THEME_OPTION="@theme"
THEME_VARIANT_OPTION="@theme_variant"
STATUS_CONTENT_OPTION="@theme_status_content"
NO_PATCHED_FONT_OPTION="@theme_no_patched_font"
DATE_FORMAT_OPTION="@theme_date_format"
TIME_FORMAT_OPTION="@theme_time_format"

_current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

__cleanup() {
  unset -v PLUGIN_VERSION THEME_OPTION THEME_VARIANT_OPTION
  unset -v STATUS_CONTENT_OPTION NO_PATCHED_FONT_OPTION
  unset -v DATE_FORMAT_OPTION TIME_FORMAT_OPTION
  unset -v _current_dir
  unset -f __load __cleanup __setup_time_date_formats __load_palette __load_theme __load_status
}

__setup_time_date_formats() {
  local date_format=$(tmux show-option -gqv "$DATE_FORMAT_OPTION")
  local time_format=$(tmux show-option -gqv "$TIME_FORMAT_OPTION")
  
  if [ -n "$time_format" ]; then
    tmux set-environment -g THEME_TIME_FORMAT "$time_format"
  elif [ "$(tmux show-option -gqv "clock-mode-style")" == '12' ]; then
    tmux set-environment -g THEME_TIME_FORMAT "%I:%M %p"
  else
    tmux set-environment -g THEME_TIME_FORMAT "%H:%M"
  fi

  if [ -z "$date_format" ]; then
    tmux set-environment -g THEME_DATE_FORMAT "%Y-%m-%d"
  else
    tmux set-environment -g THEME_DATE_FORMAT "$date_format"
  fi
}

__load() {
  local theme=$(tmux show-option -gqv "$THEME_OPTION")
  theme=${theme:-"catppuccin"}
  
  local variant=$(tmux show-option -gqv "$THEME_VARIANT_OPTION")
  variant=${variant:-"macchiato"}
  
  local status_content=$(tmux show-option -gqv "$STATUS_CONTENT_OPTION")
  status_content=${status_content:-"1"}
  
  local no_patched_font=$(tmux show-option -gqv "$NO_PATCHED_FONT_OPTION")
  
  # Define paths
  local palette_file="$_current_dir/themes/${theme}/palettes/${variant}.sh"
  local theme_file="$_current_dir/themes/${theme}/theme.sh"
  local status_file
  
  if [ "$no_patched_font" == "1" ]; then
    status_file="$_current_dir/themes/${theme}/status-no-icons.sh"
  else
    status_file="$_current_dir/themes/${theme}/status.sh"
  fi
  
  # Load palette
  if [ ! -f "$palette_file" ]; then
    echo "Error: Palette file not found at $palette_file"
    return 1
  fi
  
  echo "Loading ${theme^} ${variant^} palette..."
  source "$palette_file"
  
  # Verificar se PALETTE foi carregado
  if [ ${#PALETTE[@]} -eq 0 ]; then
    echo "Error: PALETTE array is empty after loading palette file"
    return 1
  fi
  
  # Load base theme
  if [ ! -f "$theme_file" ]; then
    echo "Error: Theme file not found at $theme_file"
    return 1
  fi
  
  echo "Loading ${theme^} base theme..."
  source "$theme_file"
  
  # Setup time/date formats
  __setup_time_date_formats
  
  # Load status bar
  if [ "$status_content" != "0" ]; then
    if [ -f "$status_file" ]; then
      if [ "$no_patched_font" == "1" ]; then
        echo "Loading ${theme^} status bar (no icons)..."
      else
        echo "Loading ${theme^} status bar (with icons)..."
      fi
      source "$status_file"
    else
      echo "Warning: Status file not found at $status_file"
    fi
  fi
  
  echo "${theme^} ${variant^} theme loaded successfully!"
}

__load
__cleanup
