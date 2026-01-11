# How It Works

Understanding how **Omarchy Tmux v2.1** integrates with your system.

> **Architecture note (v2.1)**: This version introduces *persistent theme profiles*, where each theme maintains its own configuration file that survives theme switches.

---

## Overview

Omarchy Tmux integrates Omarchy theme switching with tmux by keeping your main `tmux.conf` static and dynamically loading the active theme through a symlink that points to a **persistent theme profile**.

The result is a system where:

* tmux configuration remains stable
* themes are switched instantly
* user customizations are never overwritten

---

## Architecture Components

### 1. Static tmux.conf

Your main tmux configuration file contains a single, permanent integration line:

```bash
source-file ~/.config/tmux/omarchy-current-theme.conf
```

This line never changes. It always points to the same symlink location.

---

### 2. Dynamic Symlink

The file below is a symlink managed by Omarchy Tmux:

```bash
~/.config/tmux/omarchy-current-theme.conf
```

It always points to the currently active theme profile:

```bash
~/.config/tmux/omarchy-current-theme.conf → ~/.config/tmux/omarchy-themes/tokyo-night.conf
```

When you switch themes, only this symlink is updated.

---

### 3. Persistent Theme Profiles

Each theme has its own configuration file stored in:

```bash
~/.config/tmux/omarchy-themes/
```

Example profiles:

```bash
tokyo-night.conf
catppuccin-mocha.conf
rose-pine-moon.conf
gruvbox-dark.conf
```

Key properties:

* Created once, on first use
* Never regenerated automatically
* Safe to edit directly

These files contain both PowerKit settings and any user customizations.

---

### 4. Theme Generator

The generator script creates theme profiles *on demand* and updates the symlink:

```bash
~/.local/bin/omarchy-tmux-generator
```

Its responsibilities are:

1. Read the current Omarchy theme name
2. Create a theme profile if it does not exist
3. Update the symlink to point to that profile

If a profile already exists, it is left untouched.

---

### 5. Omarchy Hook

Omarchy triggers theme updates through a hook installed at:

```bash
~/.config/omarchy/hooks/theme-set
```

This hook simply calls the reload script whenever the theme changes.

---

### 6. Reload Script

The reload script coordinates updates and tmux refresh:

```bash
~/.local/bin/omarchy-tmux-reload
```

It performs the following steps:

1. Executes the generator (if present)
2. Reloads `tmux.conf` for all running sessions
3. Refreshes tmux clients

---

### 7. PowerKit

[tmux-powerkit](https://github.com/fabioluciano/tmux-powerkit) is responsible for rendering the visual theme:

* Status bar colors and layout
* Plugin rendering (battery, cpu, datetime, etc.)
* Theme variants (light/dark)

Omarchy Tmux only provides configuration; PowerKit handles presentation.

---

## Theme Switching Flow

```
User switches Omarchy theme
        ↓
Omarchy updates theme.name
        ↓
Omarchy triggers theme-set hook
        ↓
Reload script runs
        ↓
Generator ensures profile exists
        ↓
Symlink updated to active profile
        ↓
tmux reloads configuration
        ↓
PowerKit applies the theme
```

---

## Why Persistent Profiles?

### Previous Behavior (v2.0)

In v2.0, theme configurations were regenerated on every theme switch.

This caused:

* Loss of user customizations
* Tight coupling to Omarchy theme directories
* Fragile upgrade paths

---

### Current Behavior (v2.1)

v2.1 introduces standalone, persistent profiles:

* Profiles are created once
* User edits are preserved permanently
* Theme switching is reduced to a symlink update

This makes theme customization safe and predictable.

---

## Customization Model

The intended workflow is simple:

1. Switch to a theme using Omarchy
2. Edit the generated profile in `~/.config/tmux/omarchy-themes/`
3. Reload tmux if needed

You never need to modify symlinks or generator logic manually.

---

## File Layout

```
~/.config/
├── tmux/
│   ├── tmux.conf
│   ├── omarchy-current-theme.conf → omarchy-themes/THEME.conf
│   └── omarchy-themes/
├── omarchy/
│   ├── current/theme.name
│   └── hooks/theme-set

~/.local/bin/
├── omarchy-tmux-reload
└── omarchy-tmux-generator
```

---

## Learn More

* Installation: [INSTALL.md](INSTALL.md)
* Troubleshooting: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
* PowerKit: [https://github.com/fabioluciano/tmux-powerkit](https://github.com/fabioluciano/tmux-powerkit)
