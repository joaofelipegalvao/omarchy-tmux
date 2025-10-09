# How It Works

Understanding how **Omarchy Tmux** integrates with your system.

## Overview

Omarchy Tmux automatically reloads tmux when you change your Omarchy theme.

When the Omarchy theme symlink updates, a lightweight monitor detects it and triggers a tmux reload.

## Architecture

### 1. Theme Directories

Each theme (e.g., `tokyo-night`, `catppuccin`) contains a `tmux.conf` generated during installation.

### 2. TPM Plugin

`tmux-themes.tmux` acts as the TPM entry point.  
It loads the theme defined in the current Omarchy configuration.

### 3. Systemd Monitor

The installer adds a user service:

```
omarchy-tmux-monitor.service
```

which watches:

```
~/.config/omarchy/current/theme
```

and runs:

```bash
tmux source-file ~/.config/tmux/tmux.conf
```

### 4. Seamless Integration

When Omarchy switches themes (`Super + Ctrl + Shift + Space`),  
tmux instantly reloads to match the new palette.

## Generated Files

The installer creates the following per theme:

```bash
~/.config/omarchy/themes/tokyo-night/tmux.conf
~/.config/omarchy/themes/catppuccin/tmux.conf
# ... for all 11 themes
```

Each file defines:

```bash
set -g @plugin 'joaofelipegalvao/omarchy-tmux'
set -g @theme 'tokyo-night'
set -g @theme_variant 'night'
set -g @theme_no_patched_font '0'
```

## Service Overview

```bash
# Check status
systemctl --user status omarchy-tmux-monitor

# Restart service
systemctl --user restart omarchy-tmux-monitor

# View logs
journalctl --user -u omarchy-tmux-monitor -f
```

The monitor is lightweight and runs only when the user session is active.

## Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│   User switches Omarchy theme (Super+Ctrl+Shift+Space)      │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  Omarchy updates symlink:                                   │
│  ~/.config/omarchy/current/theme → new-theme                │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  inotifywait detects change                                 │
│  (via omarchy-tmux-monitor.service)                         │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  Monitor script triggers:                                   │
│  tmux source-file ~/.config/tmux/tmux.conf                  │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  Tmux loads new theme from:                                 │
│  ~/.config/omarchy/current/theme/tmux.conf                  │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  ✨ Theme applied instantly to all tmux sessions            │
└─────────────────────────────────────────────────────────────┘
```
