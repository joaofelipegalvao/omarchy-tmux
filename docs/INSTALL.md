# Installation Guide

This document explains all installation methods for **Omarchy Tmux v2.0+**.

> **Note**: This guide applies to v2.0+, which integrates with
> [tmux-powerkit](https://github.com/fabioluciano/tmux-powerkit).
> If you're using v1.x, please migrate first (see [Migrating from v1.x](#migrating-from-v1x)).

## Requirements

| Requirement | Version | Purpose |
|------------|---------|---------|
| [Omarchy Linux](https://omarchy.org) | 3.1+ | Theme system with hooks support |
| [tmux](https://github.com/tmux/tmux/wiki) | 2.9+ | Terminal multiplexer |
| [TPM](https://github.com/tmux-plugins/tpm) | Latest | Installs PowerKit plugin |
| git | Any | Required for TPM |

---

## Quick Install (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/joaofelipegalvao/omarchy-tmux/main/scripts/omarchy-tmux-install.sh | bash
````

After installation, within tmux, press:

```
prefix + I
```

This installs **tmux-powerkit** and other TPM-managed plugins.

> **Security Tip**: Always review installation scripts before running them.
> See [Manual Installation](#manual-installation) below for a step-by-step approach.

## What the Installer Does

1. ✅ Checks dependencies (Omarchy 3.1+, tmux, git, TPM)
2. ✅ Generates tmux-powerkit configs for all Omarchy themes
3. ✅ Updates `~/.config/tmux/tmux.conf` with symlink-based integration
4. ✅ Creates reload script at `~/.local/bin/omarchy-tmux-reload`
5. ✅ Installs an Omarchy `theme-set` hook for automatic theme switching
6. ✅ Validates the final setup

## Manual Installation

### 1. Install Dependencies

```bash
sudo pacman -S tmux git
```

(Adjust for your distribution or package manager if needed.)

### 2. Install TPM

If you don't have TPM:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Or for XDG-compliant installs:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
```

### 3. Run the Installer

```bash
git clone https://github.com/joaofelipegalvao/omarchy-tmux /tmp/omarchy-tmux
bash /tmp/omarchy-tmux/scripts/omarchy-tmux-install.sh
```

### 4. Install PowerKit

Inside tmux, press:

```
prefix + I
```

Allow TPM to install PowerKit and dependencies.

### 5. Test Theme Switching

Switch your Omarchy theme:

```
Super + Ctrl + Shift + Space
```

Tmux should update automatically. 🎉

## Configuration

### tmux.conf Integration

The installer adds the following to:

```
~/.config/tmux/tmux.conf
```

```bash
# ============================================================================
# Omarchy Tmux Integration (v2.0)
# Theme syncs automatically via symlink - DO NOT EDIT THIS SECTION
# ============================================================================
source-file ~/.config/omarchy/current/theme/tmux.conf
# End Omarchy Tmux Integration

# Initialize and run tpm
run '~/.tmux/plugins/tpm/tpm'
```

This block is **static** — do not edit it manually.

### Per-Theme Customization

Each theme has its own tmux config:

```bash
~/.config/omarchy/themes/tokyo-night/tmux.conf
~/.config/omarchy/themes/catppuccin/tmux.conf
# ...
```

Example:

```bash
# ~/.config/omarchy/themes/tokyo-night/tmux.conf

# PowerKit Plugin
set -g @plugin 'fabioluciano/tmux-powerkit'

# Theme
set -g @powerkit_theme 'tokyo-night'
set -g @powerkit_theme_variant 'night'

# Plugins
set -g @powerkit_plugins "datetime,battery,cpu,memory,hostname"

# Visual Options
set -g @powerkit_separator_style "normal"

# Performance
set -g @powerkit_status_interval "5"

# Keybindings
set -g @powerkit_theme_selector_key "T"
set -g @powerkit_reload_config_key "R"

# ============================================================================
# Your Custom Configuration
# ============================================================================
```

Custom edits here **persist across theme switches**.

## Advanced Options

### Installer Flags

```bash
# Force reinstall (regenerate all theme configs)
bash scripts/omarchy-tmux-install.sh -f

# Quiet mode (minimal output)
bash scripts/omarchy-tmux-install.sh -q

# Help
bash scripts/omarchy-tmux-install.sh -h
```

### PowerKit Controls

```bash
# Status bar plugins
set -g @powerkit_plugins "datetime,battery,cpu,memory,hostname,weather"

# Separator styles: normal | arrow | slant
set -g @powerkit_separator_style "arrow"

# Refresh interval (seconds)
set -g @powerkit_status_interval "10"

# Custom keybindings
set -g @powerkit_theme_selector_key "T"
set -g @powerkit_reload_config_key "R"
```

See the [PowerKit documentation](https://github.com/fabioluciano/tmux-powerkit) for full options.

### Manual Reload

To reload tmux manually:

```bash
tmux source-file ~/.config/tmux/tmux.conf
```

Optional keybinding:

```bash
bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"
```

## Troubleshooting Installation

### TPM Not Found

```bash
ls -la ~/.tmux/plugins/tpm
ls -la ~/.config/tmux/plugins/tpm
```

If missing:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

### Permission Issues

Check folders:

```bash
ls -la ~/.config/tmux
ls -la ~/.config/omarchy
```

If needed:

```bash
chmod u+w ~/.config/tmux
chmod u+w ~/.config/omarchy
```

### Theme Config Missing

Re-run installer with:

```bash
bash scripts/omarchy-tmux-install.sh -f
```

Or switch theme once.

## Migrating from v1.x

### 1. Uninstall v1.x

```bash
curl -fsSL https://raw.githubusercontent.com/joaofelipegalvao/omarchy-tmux/v1.0.0/scripts/omarchy-tmux-uninstall.sh | bash
```

### 2. Clean Up Old Files

```bash
rm -rf ~/.config/tmux/plugins/omarchy-tmux
```

(Older systemd services are no longer relevant in v2.0.)

### 3. Install v2.0+

```bash
curl -fsSL https://raw.githubusercontent.com/joaofelipegalvao/omarchy-tmux/main/scripts/omarchy-tmux-install.sh | bash
```

Inside tmux:

```
prefix + I
```

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/joaofelipegalvao/omarchy-tmux/main/scripts/omarchy-tmux-uninstall.sh | bash
```

Options:

- `-k`, `--keep-configs` — keep generated theme configs
- `-f`, `--force` — skip confirmations
- `-q`, `--quiet` — quiet output

## Need Help?

- Read [HOW_IT_WORK.md](HOW_IT_WORK.md) for deep architecture details
- Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- Open an issue on GitHub:
  [https://github.com/joaofelipegalvao/omarchy-tmux/issues](https://github.com/joaofelipegalvao/omarchy-tmux/issues)
