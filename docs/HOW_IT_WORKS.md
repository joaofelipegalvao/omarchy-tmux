# How It Works

Understanding how **Omarchy Tmux** integrates with your system.

## Overview

Omarchy Tmux automatically reloads tmux when you change your Omarchy theme.

When the Omarchy sets the theme, it calls an installed hook which triggers
a tmux reload.

## Architecture

### 1. Theme Directories

Each theme (e.g., `tokyo-night`, `catppuccin`) contains a `tmux.conf` generated during installation.

### 2. TPM Plugin

`tmux-themes.tmux` acts as the TPM entry point.  
It loads the theme defined in the current Omarchy configuration.

### 3. Omarchy Hook

The installer adds a hook to ~/.config/omarchy/hooks/theme-set which
gets called whenever the theme changes.

This hook runs:
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

## Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│   User switches Omarchy theme (Super+Ctrl+Shift+Space)      │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  Omarchy calls hooks:                                       │
│  ~/.config/omarchy/hooks/theme-set <new-theme>              │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│ Installed hook in ~/.local/bin/omarchy-tmux-hook is called  │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│  Hook triggers:                                             │
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
