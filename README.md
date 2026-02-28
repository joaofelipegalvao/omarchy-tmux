# Tmux Powerkit for Omarchy

<p align="center">
  <a href="https://omarchy.org" target="_blank">
    <img src="https://img.shields.io/badge/Omarchy-3.4+-7aa2f7?style=flat-square&labelColor=1a1b26&logo=archlinux&logoColor=c0caf5"/>
  </a>
  <a href="https://github.com/fabioluciano/tmux-powerkit" target="_blank">
    <img src="https://img.shields.io/badge/PowerKit-Compatible-7aa2f7?style=flat-square&labelColor=1a1b26&logo=tmux&logoColor=c0caf5"/>
  </a>
  <a href="https://github.com/joaofelipegalvao/omarchy-tmux/blob/main/LICENSE" target="_blank">
    <img src="https://img.shields.io/badge/License-MIT-7aa2f7?style=flat-square&labelColor=1a1b26&logo=github&logoColor=c0caf5"/>
  </a>
</p>

<div align="center">
  
**Seamless [tmux-powerkit](https://github.com/fabioluciano/tmux-powerkit) integration for [Omarchy](https://omarchy.org)**

**17 themes · Instant switching · TPM optional**

<p align="center"><em>tmux updates automatically when switching Omarchy themes with <code>Super + Ctrl + Shift + Space</code></em></p>

</div>

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/joaofelipegalvao/omarchy-tmux/main/install.sh | bash
```

Then reload tmux:

```bash
tmux source-file ~/.config/tmux/tmux.conf
```

## Requirements

* [Omarchy](https://omarchy.org) 3.4+ (hooks support)
* [tmux](https://github.com/tmux/tmux/wiki) 2.9+
* [TPM](https://github.com/tmux-plugins/tpm) (Tmux Plugin Manager)
* git

## How It Works

On every Omarchy theme change:

1. Omarchy writes the theme name to `~/.config/omarchy/current/theme.name`
2. The `theme-set` hook triggers `omarchy-tmux-theme-set`
3. The script maps the theme to a PowerKit equivalent and writes `~/.config/tmux/powerkit-theme.conf`
4. tmux reloads automatically

### Without TPM

PowerKit is installed via `git clone` into `~/.config/tmux/plugins/tmux-powerkit` and loaded directly via `run-shell`. No extra steps needed after install.

PowerKit is kept up to date automatically — the installer adds a `post-update` hook that runs `git pull` on the PowerKit repository whenever you run `omarchy-update`.

### With TPM

If TPM is detected, the installer only adds the theme loader to your `tmux.conf` — no `run-shell` is added to avoid loading PowerKit twice. After install, press `prefix + I` inside tmux to install PowerKit via TPM.

PowerKit updates are managed by TPM (`prefix + U`). The `post-update` hook is not added in this case since `git pull` would conflict with TPM's own update mechanism.

## Supported Themes

<details>
<summary><strong>All 17 stock Omarchy themes are supported out of the box (click to expand)</strong></summary>

**Fully Supported:**

* Catppuccin (latte, mocha)
* Rose Pine (dawn)
* Tokyo Night (night)
* Gruvbox (dark)
* Everforest (dark)
* Kanagawa (dragon)
* Flexoki (light)
* Nord, Osaka-jade, Hackerman
* Ethereal,Matte-black, Miasma
* Ristretto,Vantablack and White

**Unsupported (fallback to Tokyo Night)**
</details>

## Customization

Add any PowerKit options to your `~/.config/tmux/tmux.conf`:

### Quick Examples

```bash
# Plugins
set -g @powerkit_plugins "datetime,battery,cpu,memory,hostname"

# Separator style (normal, rounded, flame, pixel, honeycomb, none)
set -g @powerkit_separator_style "rounded"
set -g @powerkit_edge_separator_style "rounded:all"

# Show plugins only when above threshold
set -g @powerkit_plugin_cpu_show_only_on_threshold "true"
set -g @powerkit_plugin_battery_show_only_on_threshold "true"

# Transparent background
set -g @powerkit_transparent "true"
```

### Available Plugins

```
datetime, battery, cpu, memory, hostname, disk, load,
git, weather, network, wifi, vpn, bluetooth, volume,
kubernetes, terraform, docker, github, packages, ...
```

**Customizations persist** when switching themes!

See [PowerKit Documentation](https://github.com/fabioluciano/tmux-powerkit) for full options.

### Custom Themes

If you install a custom Omarchy theme that has a matching PowerKit theme, you can add it to the `map_theme` function in `~/.local/bin/omarchy-tmux-theme-set`:

```bash
my-custom-theme) echo "powerkit-theme-name|variant" ;;
```

The PowerKit theme name must match an existing theme in [tmux-powerkit/src/themes](https://github.com/fabioluciano/tmux-powerkit/tree/main/src/themes). Unknown themes fall back to `tokyo-night / night`.

## Troubleshooting

**Theme not updating?**

```bash
chmod +x ~/.config/omarchy/hooks/theme-set
chmod +x ~/.local/bin/omarchy-tmux-theme-set
~/.local/bin/omarchy-tmux-theme-set
```

**PowerKit not loading?**

```bash
# Without TPM
git clone --depth 1 https://github.com/fabioluciano/tmux-powerkit.git \
  ~/.config/tmux/plugins/tmux-powerkit

# With TPM — inside tmux
prefix + I
```

**Wrong theme applied?**

```bash
cat ~/.config/omarchy/current/theme.name
cat ~/.config/tmux/powerkit-theme.conf
~/.local/bin/omarchy-tmux-theme-set
tmux source-file ~/.config/tmux/tmux.conf
```

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/joaofelipegalvao/omarchy-tmux/main/uninstall.sh | bash
```

## Acknowledgments

* [@dhh](https://github.com/dhh) — [Omarchy](https://omarchy.org)
* [@fabioluciano](https://github.com/fabioluciano) — [tmux-powerkit](https://github.com/fabioluciano/tmux-powerkit)
* [@bruno-](https://github.com/bruno-) — [TPM](https://github.com/tmux-plugins/tpm)
* All contributors and users who provided feedback

<div align="center">

**[Omarchy](https://omarchy.org)** · **[PowerKit](https://github.com/fabioluciano/tmux-powerkit)** · **[Issues](https://github.com/joaofelipegalvao/omarchy-tmux/issues)**

Made with ❤️ for Omarchy users

⭐ Star this repo if you find it useful!

</div>
