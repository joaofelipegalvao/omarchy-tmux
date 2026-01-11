# Installation Guide

This document explains all installation methods for **Omarchy Tmux v2.1+**.

> **Note**: This guide applies to v2.1+, which uses persistent theme profiles.
> If you're using v2.0 or earlier, please migrate first (see [Migrating from v2.0](#migration-from-v20-to-v21)).

---

## Requirements

| Requirement                                | Version | Purpose                              |
| ------------------------------------------ | ------- | ------------------------------------ |
| [Omarchy Linux](https://omarchy.org)       | 3.3+    | Theme system with aether integration |
| [tmux](https://github.com/tmux/tmux/wiki)  | 2.9+    | Terminal multiplexer                 |
| [TPM](https://github.com/tmux-plugins/tpm) | Latest  | Installs PowerKit plugin             |
| git                                        | Any     | Required for TPM                     |

---

## Quick Install (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/joaofelipegalvao/omarchy-tmux/main/scripts/omarchy-tmux-install.sh | bash
```

After installation, within tmux, press:

```
prefix + I
```

This installs **tmux-powerkit** and other TPM-managed plugins.

> **Security Tip**: Always review installation scripts before running them.
> See [Manual Installation](#manual-installation) for a step-by-step approach.

---

## What the Installer Does

1. Checks required dependencies
2. Creates required configuration directories
3. Installs helper scripts and hooks
4. Integrates Omarchy with tmux via a static config block
5. Validates the final setup

> For detailed architecture and file layout, see [HOW_IT_WORK.md](HOW_IT_WORK.md).

---

## Manual Installation

### 1. Install Dependencies

```bash
sudo pacman -S tmux git
```

(Adjust for your distribution if needed.)

### 2. Install TPM

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Or (XDG-compliant):

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

---

## Configuration

### tmux.conf Integration

The installer adds a static integration block to:

```
~/.config/tmux/tmux.conf
```

```bash
# =========================================================================
# Omarchy Tmux Integration (v2.1)
# =========================================================================
source-file ~/.config/tmux/omarchy-current-theme.conf
# End Omarchy Tmux Integration

run '~/.tmux/plugins/tpm/tpm'
```

Do not edit this block manually.

---

## Advanced Options

### Installer Flags

```bash
bash scripts/omarchy-tmux-install.sh -f   # Force reinstall
bash scripts/omarchy-tmux-install.sh -q   # Quiet mode
bash scripts/omarchy-tmux-install.sh -v   # Show version
bash scripts/omarchy-tmux-install.sh -h   # Help
```

### Manual Reload

```bash
tmux source-file ~/.config/tmux/tmux.conf
```

---

## Troubleshooting Installation

If something doesn't work as expected:

* Verify TPM is installed
* Ensure Omarchy version is 3.3+
* Check file permissions in `~/.config/tmux`

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for detailed diagnostics.

---

## Migration from v2.0 to v2.1

v2.1 introduces a new internal layout with **persistent theme profiles**, so migrating from v2.0 requires a few steps.

### Migration Steps

1. **Uninstall v2.0**

```bash
curl -fsSL https://raw.githubusercontent.com/joaofelipegalvao/omarchy-tmux/v2.0.0/scripts/omarchy-tmux-uninstall.sh | bash
```

2. **Install v2.1**

```bash
curl -fsSL https://raw.githubusercontent.com/joaofelipegalvao/omarchy-tmux/main/scripts/omarchy-tmux-install.sh | bash
```

3. **Install plugins in tmux via TPM**

```
prefix + I (Ctrl+b Shift+i)
```

### Notes

* Profiles from v2.0 are not compatible with v2.1 — you’ll start with fresh persistent profiles.
* tmux.conf integration remains static; only the theme profiles layout changes.
* After migrating to v2.1, any edits you make to the new persistent theme profiles
  in ~/.config/tmux/omarchy-themes/ will survive future theme switches.

---

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/joaofelipegalvao/omarchy-tmux/main/scripts/omarchy-tmux-uninstall.sh | bash
```

### Uninstaller Options

```bash
bash scripts/omarchy-tmux-uninstall.sh -y   # Skip confirmation
bash scripts/omarchy-tmux-uninstall.sh -k   # Keep theme profiles
bash scripts/omarchy-tmux-uninstall.sh -q   # Quiet mode
bash scripts/omarchy-tmux-uninstall.sh -v   # Show version
bash scripts/omarchy-tmux-uninstall.sh -h   # Help
```

---

## Need Help?

* Architecture details: [HOW_IT_WORK.md](HOW_IT_WORK.md)
* Troubleshooting: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
* Issues: [https://github.com/joaofelipegalvao/omarchy-tmux/issues](https://github.com/joaofelipegalvao/omarchy-tmux/issues)
