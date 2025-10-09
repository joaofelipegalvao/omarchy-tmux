# Installation Guide

This document explains all installation methods for **Omarchy Tmux**.

## Requirements

- [Omarchy](https://omarchy.org)
- [Tmux](https://github.com/tmux/tmux/wiki)
- [TPM](https://github.com/tmux-plugins/tpm)
- `inotify-tools`
- `systemd --user` support (for auto-reload)

## Quick Install (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/joaofelipegalvao/omarchy-tmux/main/scripts/omarchy-tmux-install.sh | bash
```

## Security Tip: Always review scripts before running

```bash
git clone https://github.com/joaofelipegalvao/omarchy-tmux ~/.config/tmux/plugins/omarchy-tmux
bash ~/.config/tmux/plugins/omarchy-tmux/scripts/omarchy-tmux-install.sh
```

## Manual Installation

### 1. Install Dependencies

```bash
sudo pacman -S tmux inotify-tools git
```

### 2. Install TPM

```bash
git clone <https://github.com/tmux-plugins/tpm> ~/.tmux/plugins/tpm
```

### 3. Clone the plugin

```bash
git clone https://github.com/joaofelipegalvao/omarchy-tmux ~/.config/tmux/plugins/omarchy-tmux
```

### 4. Configure Tmux

Add to `~/.config/tmux/tmux.conf`:

```bash
# Load current Omarchy theme
source-file ~/.config/omarchy/current/theme/tmux.conf

# TPM (keep at bottom)
set -g @plugin 'tmux-plugins/tpm'
run '~/.tmux/plugins/tpm/tpm'
```

### 5. Install Plugins

Inside tmux, press `prefix + I` (Ctrl+b Shift+i)

### 6. Setup Auto-reload (Optional)

The installer automatically creates and enables a systemd service for auto-reload.

To manually check or restart:

```bash
# Check status
systemctl --user status omarchy-tmux-monitor

# Restart
systemctl --user restart omarchy-tmux-monitor

# View logs
journalctl --user -u omarchy-tmux-monitor -f
```

### Disable Icons

Edit theme config in `~/.config/omarchy/themes/[theme]/tmux.conf`:

```bash
set -g @theme_no_patched_font '1'
```

### Manual Reload

```bash
tmux source-file ~/.config/tmux/tmux.conf
```

Or press `prefix + r` if configured.

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/joaofelipegalvao/omarchy-tmux/main/scripts/omarchy-tmux-uninstall.sh | bash
```
