# Omarchy Tmux
<div align="center">
  
Tmux themes that automatically sync with [Omarchy](https://omarchy.org) theme changes.

![Demo](assets/demo.gif)

Watch how tmux automatically updates when switching Omarchy themes with `Super + Ctrl + Shift + Space`
</div>

## Features

- All 12 Omarchy themes supported
- Automatic theme synchronization
- Optional Nerd Font icons
- TPM compatible
- Auto-reload via systemd service

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/joaofelipegalvao/omarchy-tmux/main/scripts/omarchy-tmux-install.sh | bash
```

Then inside tmux, press `prefix + I` (Ctrl+b Shift+i) to install plugins.

> **Security Tip**: Always review scripts before running. See [Installation Guide](docs/INSTALL.md) for manual installation.

## Requirements

- [Omarchy](https://omarchy.org)
- [Tmux](https://github.com/tmux/tmux/wiki)
- [TPM](https://github.com/tmux-plugins/tpm)
- `inotify-tools` (for auto-reload)
- `systemd --user` support

## Documentation

- **[Installation Guide](docs/INSTALL.md)** - Detailed installation instructions and configuration
- **[How It Works](docs/HOW_IT_WORKS.md)** - Architecture and technical details
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues and solutions

## Quick Configuration

### Disable Icons

If you prefer a cleaner look without icons, you can disable them.

Edit `~/.config/omarchy/themes/[theme]/tmux.conf`:

```bash
set -g @theme_no_patched_font '1'
```

**Example without icons:**

[![No icons preview](https://i.postimg.cc/5yn1ndYg/screenshot-2025-10-09-19-41-44.png)](https://postimg.cc/PvpB57Mv)


### Manual Reload

```bash
tmux source-file ~/.config/tmux/tmux.conf
```

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/joaofelipegalvao/omarchy-tmux/main/scripts/omarchy-tmux-uninstall.sh | bash
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
