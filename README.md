# Omarchy Tmux

Tmux themes that automatically sync with [Omarchy](https://omarchy.org) theme changes.

![Demo](assets/demo.gif)

## Features

- All 11 Omarchy themes supported
- Automatic theme synchronization
- Optional Nerd Font icons
- TPM compatible
- Auto-reload via systemd service

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/joaofelipegalvao/omarchy-tmux/main/scripts/omarchy-tmux-install.sh | bash
```

## Manual Installation

### 1. Install Dependencies

```bash
sudo pacman -S tmux inotify-tools git
```

### 2. Install TPM

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

### 3. Clone Plugin

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

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/joaofelipegalvao/omarchy-tmux/main/scripts/omarchy-tmux-uninstall.sh | bash
```

## Requirements

- [Omarchy](https://omarchy.org)
- [Tmux](https://github.com/tmux/tmux/wiki)
- [TPM](https://github.com/tmux-plugins/tpm)
- `inotify-tools` (for auto-reload)

## Configuration

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

## Troubleshooting

### Check monitor service status

```bash
systemctl --user status omarchy-tmux-monitor
```

### View monitor logs

```bash
journalctl --user -u omarchy-tmux-monitor -f
```

### Icons not showing

Install a Nerd Font (Omarchy uses CaskaydiaCove by default) or disable icons.

### Theme not auto-updating

Check if monitor is running:

```bash
pgrep -f omarchy-tmux-monitor
```

Restart service:

```bash
systemctl --user restart omarchy-tmux-monitor
```

## How It Works

1. **Plugin Structure**: Each theme has its own directory with palette, status bar, and theme files
2. **TPM Loader**: `tmux-themes.tmux` is the TPM plugin entry point that loads the appropriate theme
3. **Theme Detection**: The installer creates `tmux.conf` files in each Omarchy theme directory
4. **Auto-reload**: A systemd monitor service watches `~/.config/omarchy/current/theme` symlink
5. **Theme Applied**: When Omarchy switches themes (Super+Ctrl+Shift+Space), tmux automatically reloads

### Generated Files

The installer creates these files in your Omarchy themes:

```bash
~/.config/omarchy/themes/tokyo-night/tmux.conf
~/.config/omarchy/themes/catppuccin/tmux.conf
# ... one for each theme
```

Each contains:

```bash
set -g @plugin 'joaofelipegalvao/omarchy-tmux'
set -g @theme 'tokyo-night'
set -g @theme_variant 'night'
set -g @theme_no_patched_font '0'
```

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Test thoroughly
4. Submit a pull request

## Acknowledgments

- [Omarchy](https://omarchy.org) - The beautiful Arch Linux distribution
- [TPM](https://github.com/tmux-plugins/tpm) - Tmux Plugin Manager
- Community theme creators

---

**Note**: This plugin does not modify Omarchy's core files (in `~/.local/share/omarchy`). All configurations are stored in user-editable locations (`~/.config`).
