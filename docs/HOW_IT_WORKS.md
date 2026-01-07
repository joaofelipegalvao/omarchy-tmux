# How It Works

Understanding how **Omarchy Tmux v2.0** integrates with your system.

> **Architecture Change in v2.0**: This version uses [tmux-powerkit](https://github.com/fabioluciano/tmux-powerkit)
> instead of custom theme files, with a symlink-based configuration system.

## Overview

Omarchy Tmux automatically reloads tmux when you change your Omarchy theme, using a **zero-edit symlink architecture**. Your tmux config stays static while the theme content updates dynamically through symlinks.

## Architecture Components

### 1. Static tmux.conf

Your main config at `~/.config/tmux/tmux.conf` contains a single source line:

```bash
source-file ~/.config/omarchy/current/theme/tmux.conf
```

**This line never changes** — it always points to the same symlink path.

### 2. Dynamic Symlink

The path `~/.config/omarchy/current/theme/` is a **symlink** managed by Omarchy:

```bash
~/.config/omarchy/current/theme → ~/.config/omarchy/themes/tokyo-night
```

When you switch themes, Omarchy updates this symlink:

```bash
~/.config/omarchy/current/theme → ~/.config/omarchy/themes/catppuccin
```

### 3. Theme Configs

Each Omarchy theme has its own tmux config:

```bash
~/.config/omarchy/themes/tokyo-night/tmux.conf
~/.config/omarchy/themes/catppuccin/tmux.conf
~/.config/omarchy/themes/gruvbox/tmux.conf
# ... etc for all themes
```

Each config contains:

```bash
# PowerKit Plugin
set -g @plugin 'fabioluciano/tmux-powerkit'

# Theme Configuration
set -g @powerkit_theme 'tokyo-night'
set -g @powerkit_theme_variant 'night'

# Plugins
set -g @powerkit_plugins "datetime,battery,cpu,memory,hostname"

# Visual Options
set -g @powerkit_separator_style "normal"

# Performance
set -g @powerkit_status_interval "5"
```

### 4. Omarchy Hook

The installer adds a hook set `~/.config/omarchy/hooks/theme-set`:

```bash
#!/bin/bash
~/.local/bin/omarchy-tmux-reload
```

and the reload script simply re-sources ***tmux.conf***, which follows the symlink.
This guarantees correctness even if ***Omarchy*** changes how hooks are invoked.

### 5. Reload Script

The reload script at `~/.local/bin/omarchy-tmux-reload`:

```bash
#!/bin/bash
set -euo pipefail

readonly TMUX_CONF="$HOME/.config/tmux/tmux.conf"

# Reload all tmux sessions
if tmux list-sessions &>/dev/null 2>&1; then
  # Reload config
  tmux source-file "$TMUX_CONF" &>/dev/null || true

  # Refresh all clients
  tmux refresh-client -S &>/dev/null || true
fi

exit 0
```

### 6. PowerKit Plugin

[tmux-powerkit](https://github.com/fabioluciano/tmux-powerkit) handles the actual theme rendering:

* Reads theme settings from the config
* Applies colors and styles to tmux status bar
* Renders plugins (datetime, battery, CPU, etc.)
* Manages theme variants (light/dark)

## Complete Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│  User switches Omarchy theme                                    │
│  (e.g. Super + Ctrl + Shift + Space)                            │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│  Omarchy updates symlink:                                       │
│  ~/.config/omarchy/current/theme → themes/NEW_THEME             │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│  Omarchy triggers hook (no arguments):                          │
│  ~/.config/omarchy/hooks/theme-set                              │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│  Hook executes reload script:                                   │
│  ~/.local/bin/omarchy-tmux-reload                               │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│  Reload script sources:                                         │
│  tmux source-file ~/.config/tmux/tmux.conf                      │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│  tmux.conf sources symlink:                                     │
│  source-file ~/.config/omarchy/current/theme/tmux.conf          │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│  Symlink resolves to active theme:                              │
│  ~/.config/omarchy/themes/NEW_THEME/tmux.conf                   │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│  PowerKit reads config and applies theme                        │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│  ✨ New theme visible in all tmux sessions instantly            │
└─────────────────────────────────────────────────────────────────┘
```

## Why PowerKit?

### The v1.0 Architecture (Custom Themes)

The old architecture **also used symlinks** (same concept!), but with custom theme files:

```
omarchy-tmux/
├── themes/
│   ├── catppuccin/
│   │   ├── palettes/macchiato.sh
│   │   ├── status.sh
│   │   └── theme.sh
│   ├── tokyo-night/
│   │   ├── palettes/night.sh
│   │   ├── status.sh
│   │   └── theme.sh
│   └── ... (12 themes total)
└── tmux-themes.tmux  # TPM entry point
```

**How it worked:**

1. ✅ Symlink-based (same as v2.0!)
2. ✅ Auto-reload via hooks (same!)
3. ⚠️ Manual theme creation
4. ⚠️ Limited themes
5. ⚠️ Maintenance burden

### The v2.0 Evolution (PowerKit Integration)

v2.0 keeps the **same symlink architecture** but delegates theme rendering to PowerKit.

**What stayed the same:**

* ✅ Symlink-based configuration
* ✅ Per-theme customization
* ✅ Auto-reload via hooks
* ✅ Zero edits to main tmux.conf

**What improved:**

* ✅ 50+ themes
* ✅ No theme maintenance
* ✅ Consistent styling
* ✅ More features
* ✅ Active development

## Theme Mapping

The installer maps Omarchy themes to PowerKit themes:

```bash
map_theme_to_powerkit() {
  case "$theme" in
    catppuccin-latte)
      base="catppuccin"
      variant="latte"
      ;;
    tokyo-night)
      base="tokyo-night"
      variant="night"
      ;;
    gruvbox-dark)
      base="gruvbox"
      variant="dark"
      ;;
  esac
}
```

Unsupported themes fallback to Tokyo Night.

## File Structure

```
~/.config/
├── tmux/
│   └── tmux.conf
├── omarchy/
│   ├── current/
│   │   └── theme → ../themes/tokyo-night
│   ├── themes/
│   │   ├── tokyo-night/
│   │   │   └── tmux.conf
│   │   └── catppuccin/
│   │       └── tmux.conf
│   └── hooks/
│       └── theme-set

~/.local/bin/
└── omarchy-tmux-reload
```

## Key Insight

**v2.0 is not a rewrite.**

It preserves the proven symlink-based architecture and simply offloads theme rendering to PowerKit, resulting in a cleaner, more scalable, and easier-to-maintain system.

## Learn More

* [PowerKit Documentation](https://github.com/fabioluciano/tmux-powerkit)
* [Omarchy Hooks System](https://omarchy.org/docs/hooks)
* [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)
