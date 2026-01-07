# Changelog

All notable changes to Omarchy Tmux will be documented in this file.

# [2.0.0](https://github.com/joaofelipegalvao/omarchy-tmux/compare/v1.0.0...v2.0.0) (2026-01-07)

* feat!: migrate from standalone plugin to PowerKit integration ([867f4b9](https://github.com/joaofelipegalvao/omarchy-tmux/commit/867f4b95896560f94ecfc5f970c6287084cffca3))

### BREAKING CHANGES

* Complete architecture overhaul from v1 standalone plugin to v2 PowerKit integration.

#### Architecture Changes

* Removed git clone plugin installation (`~/.config/tmux/plugins/omarchy-tmux`)
* Removed standalone plugin system in favor of tmux-powerkit
* Changed from plugin installation to configuration generator
* Theme configs generated per-theme instead of plugin-based
* Main config uses static source-file pointing to Omarchy's symlink
* Symlink-based theme switching (no file regeneration needed)

#### Migration Path

* v1 plugin directory no longer used (can be safely removed)
* v1 integration blocks automatically cleaned up from tmux.conf
* Automatic backup creation before modifications (`tmux.conf.backup-TIMESTAMP`)
* No manual intervention required - installer handles migration
* Legacy v1 blocks removed via sed during configure_tmux()

#### Theme Support Expansion

* **40+ themes with 60+ variants** via `map_theme_to_powerkit()` function
* **Catppuccin**: latte, macchiato, frappe, mocha
* **Rose Pine**: dawn, main, moon
* **Tokyo Night**: night, storm, day
* **Everforest**: dark, light
* **Gruvbox**: dark, light
* **Kanagawa**: dragon, lotus
* **Flexoki**: light, dark
* **Solarized**: dark, light
* **GitHub**: dark, light
* **Ayu**: dark, light, mirage
* **Material**: default, ocean, palenight, lighter
* **Monokai**: dark, light
* **Iceberg**: dark, light
* **Kiribyte**: dark, light
* **Night Owl**: default, light
* **Oceanic Next**: default, darker
* **Pastel**: dark, light
* Plus: Nord, Dracula, OneDark, Atom, Cobalt2, Darcula, Horizon, Molokai, Moonlight, Poimandres, Slack, Snazzy, Spacegray, Synthwave 84, Vesper
* **Unsupported (fallback to tokyo-night)**: ethereal, hackerman, matte-black, osaka*, ristretto

#### Generated Config Structure

Each theme gets a `tmux.conf` with:

* PowerKit plugin declaration
* Theme and variant configuration
* Default plugins: `datetime,battery,cpu,memory,hostname`
* Visual options: `separator_style`, `status_interval`
* Custom keybindings: `T` (theme selector), `R` (reload config)
* Editable custom configuration section

#### Installer Improvements

* **Enhanced validation**: Permission checks, directory validation, backup creation
* **Cleanup trap**: Warns on failed installations with rollback guidance
* **Progress tracking**: Counts generated/skipped/failed configs
* **Error handling**: Detailed error messages with actionable suggestions
* **Backup system**: Automatic timestamped backups before modifications
* **Options**: `-q` (quiet), `-f` (force regenerate), `-v` (version), `-h` (help)
* **ASCII banner**: Visual branding with architecture explanation
* **Validation step**: `validate_setup()` checks symlinks and theme configs

#### Script Changes

* **Removed**: `omarchy-tmux-hook` (git clone, theme monitoring, lockfile logic)
* **Added**: `omarchy-tmux-reload` (simple 10-line tmux reload script)
* **Hook**: Single line addition to `theme-set` hook instead of complex monitoring
* **No lockfiles**: Removed synchronization complexity
* **No git operations**: Pure configuration management

#### Configuration Changes

* **PowerKit options**: `@powerkit_theme`, `@powerkit_theme_variant`
* **No more**: `@theme`, `@theme_variant`, `@theme_no_patched_font`
* **Integration block**: Clearly marked v2.0 section with edit warnings
* **Anchor-based insertion**: Inserts before TPM init for proper load order
* **Fallback**: Appends complete block if anchor not found

#### Functions

* `map_theme_to_powerkit()`: 400+ line theme mapping logic
* `generate_theme_configs()`: Creates tmux.conf per theme directory
* `configure_tmux()`: Modifies main tmux.conf with backup
* `create_reload_script()`: Generates simple reload script
* `install_hook()`: Adds reload call to Omarchy hook
* `validate_setup()`: Checks symlinks and generated configs
* `cleanup()`: Trap for failed installation warnings

#### User Experience

* Theme switching now instant (symlink change + reload)
* Per-theme customization persists across theme changes
* Clear installation steps with color-coded output
* Detailed success message with next steps
* Troubleshooting guidance for validation warnings
* Lists unsupported themes with fallback explanation

#### Impact

* **Full breaking change**: v1 configurations incompatible
* **No plugin repo**: No longer clones git repository
* **TPM requirement**: Must install PowerKit via TPM after setup
* **Per-theme configs**: Each theme has persistent customizable config
* **Symlink architecture**: Omarchy controls active theme via symlink
* **Migration automatic**: Just run v2 installer over v1 installation

# [1.0.0](https://github.com/joaofelipegalvao/omarchy-tmux/releases/tag/v1.0.0) (2025-6-10)

### Features

* initial release of Omarchy Tmux Theme ([6eabbfd](https://github.com/joaofelipegalvao/omarchy-tmux/commit/6eabbfdc1fdcebe93ddd5f55ee058a253553987b))

* add automatic theme config generation for Omarchy themes ([97bc399](https://github.com/joaofelipegalvao/omarchy-tmux/commit/97bc3993a72bfbfb9dd3811af2e4fde5a1b9ada5))

* implement Omarchy hook integration for theme changes ([09faa17](https://github.com/joaofelipegalvao/omarchy-tmux/commit/09faa1799c14675b93ac0ddfd34077291a700bb6))

### Theme Support

Automatic detection and configuration for:

* Catppuccin (latte, macchiato)
* Gruvbox (dark)
* Rose Pine (dawn)
* Tokyo Night (night)
* Everforest (dark-hard)
* Kanagawa (wave)
* Flexoki (light)
* Osaka (jade)
* Ethereal
* Hackerman
* Matte Black
* Nord
* Ristretto

### Implementation Details

* **Installation**: Git clone plugin to `~/.config/tmux/plugins/omarchy-tmux`
* **Theme Detection**: Automatic base/variant detection via `detect_theme_config()`
* **Config Generation**: Creates `tmux.conf` per theme in `~/.config/omarchy/themes/THEME/`
* **Hook System**: Integrates with Omarchy 3.1+ hooks via `theme-set` hook
* **Reload Script**: `omarchy-tmux-hook` triggers tmux reload on theme changes
* **TPM Integration**: Adds plugin declaration and source-file to main tmux.conf
* **Dependency Checks**: Validates Omarchy 3.1+, tmux, git, and TPM installation
* **Options**: `-q` (quiet), `-f` (force reinstall), `-v` (version), `-h` (help)
* **Debug Support**: Optional DEBUG_LOG environment variable for troubleshooting
