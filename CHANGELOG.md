# Changelog

All notable changes to Omarchy Tmux will be documented in this file.

# [2.1.3](https://github.com/joaofelipegalvao/omarchy-tmux/compare/v2.1.2...v2.1.3) (2026-01-13)

### Features

* **Full Theme Support**: Added missing theme mappings for 11 themes that previously fell back to Tokyo Night
* **Theme Mappings Added**: cobalt2, darcula, horizon, kiribyte, molokai, moonlight, poimandres, slack, snazzy, spacegray, vesper
* **Synthwave Support**: Added synthwave wildcard to properly handle the "84" variant

### Technical Changes

* Updated `map_theme()` function with explicit mappings for all PowerKit themes
* Now supports all 38 themes from the tmux-powerkit repository
* Fallback to Tokyo Night only applies to truly unsupported themes

# [2.1.2](https://github.com/joaofelipegalvao/omarchy-tmux/compare/v2.1.1...v2.1.2) (2026-01-12)

### Features

* **Custom Theme Support**: Added dedicated mappings for 5 custom themes ([8df0b0a](https://github.com/joaofelipegalvao/omarchy-tmux/commit/8df0b0ae05458f0ec47fb0d93342e1136f46ac1c))
  * ethereal → ethereal (default)
  * osaka-jade → osaka-jade (default)
  * hackerman → hackerman (default)
  * matte-black → matte-black (default)
  * ristretto → ristretto (default)

### Improvements

* Simplified fallback logic - only unknown themes fall back to Tokyo Night
* Version bumped to 2.1.2
* Cleaner theme mapping structure

# [2.1.1](https://github.com/joaofelipegalvao/omarchy-tmux/compare/v2.1.0...v2.1.1) (2026-01-11)

### Bug Fixes

* **Quiet Mode Fix**: Fixed log() and info() functions to properly respect the --quiet flag ([7348541](https://github.com/joaofelipegalvao/omarchy-tmux/commit/7348541ad412a208e87ab490c7efe6d34746122b))
* Fixed issue where one-line function syntax caused premature exit with `set -euo pipefail`
* Fixed invalid syntax that prevented the script from running correctly

# [2.1.0](https://github.com/joaofelipegalvao/omarchy-tmux/compare/v2.0.0...v2.1.0) (2026-01-10)

### Features

* **Persistent Theme Profiles**: Complete redesign from symlink-switching to per-theme persistent configuration files ([omarchy-tmux-install.sh](https://github.com/joaofelipegalvao/omarchy-tmux/commit/7eea9f52b177480f6ca4ad8dd2b84f1f4d314bdd))

### BREAKING CHANGES

* Theme customizations now persist across theme switches instead of being overwritten

#### Architecture Evolution: v2.0 → v2.1

**v2.0 Architecture (Overwriting)**:

* Single `~/.config/omarchy/themes/THEME/tmux.conf` per theme
* Regenerated on every theme switch
* Symlink pointed to active theme directory
* User customizations lost on theme change

**v2.1 Architecture (Persistent Profiles)**:

* Centralized theme profiles in `~/.config/tmux/omarchy-themes/`
* Theme configs created ONCE and never regenerated
* Symlink `omarchy-current-theme.conf` points to persistent profile
* User customizations preserved permanently per theme

#### Key Improvements

**Persistent Configuration**

* Theme profiles in `~/.config/tmux/omarchy-themes/THEME_NAME.conf`
* Profiles created only if they don't exist (no overwrites)
* User customizations survive theme switches and returns
* Each theme maintains its own configuration state

**Simplified Generator Logic**

* Generator checks file existence before creating
* Only creates missing theme profiles
* Updates symlink to point to current theme's persistent file
* No more destructive regeneration

**Enhanced User Experience**

* Clear documentation in generated profiles explaining persistence
* Profiles marked as "PERSISTENT THEME PROFILE" with usage instructions
* Users encouraged to edit profiles directly at known location
* Customizations clearly separated and preserved

**Installation Improvements**

* Generator script version-tagged (v2.1.0) for upgrade detection
* Force flag (`-f`) respects existing profiles (only regenerates generator)
* Better backup handling before tmux.conf modifications
* TPM initialization line automatically moved to end of config if present

**Configuration Management**

* Removes obsolete v2.0 integration blocks automatically
* Detects and preserves existing TPM run lines
* Cleaner integration block with v2.1 marker
* Timestamped backups before any modifications

**Validation Enhancements**

* Checks for Omarchy 3.3+ theme.name file
* Validates generator script executability
* Verifies persistent themes directory existence
* Provides clear warnings for missing components

#### Technical Changes

**Generator Script (`omarchy-tmux-generator`)**

* Version bumped to v2.1.0
* Added existence check: `if [[ ! -f "$theme_file" ]]`
* Removes profile regeneration logic
* Simplified to symlink management + conditional creation
* Header comments explain persistence model

**Installation Flow**

* Creates persistent themes directory upfront
* Generates initial theme config via generator
* Continues gracefully if initial generation fails
* Hook system unchanged (still uses `omarchy-tmux-reload`)

**File Structure Changes**

```
~/.config/tmux/
├── tmux.conf (static, sources symlink)
├── omarchy-current-theme.conf (symlink to active profile)
└── omarchy-themes/
    ├── tokyo-night.conf (persistent, user-editable)
    ├── catppuccin-mocha.conf (persistent, user-editable)
    ├── gruvbox-dark.conf (persistent, user-editable)
    └── ... (one file per theme, created on first use)
```

**Theme Profile Format**
Each profile contains:

* Header documentation explaining persistence
* PowerKit plugin declaration
* Theme and variant configuration
* Default plugin set (datetime, battery, cpu, memory, hostname)
* Visual options (separator style, status interval)
* Keybindings (T for theme selector, R for reload)
* Editable custom configuration section

**Backwards Compatibility**

* Automatically migrates from v2.0 by creating persistent profiles
* Old theme directories in `~/.config/omarchy/themes/` no longer used
* Integration blocks in tmux.conf updated automatically
* No manual intervention required

#### Impact Summary

* **User Benefit**: Theme customizations finally persist - edit once, keep forever
* **Developer Benefit**: Simpler codebase without regeneration complexity
* **Migration**: Seamless - v2.0 users just run v2.1 installer
* **Customization**: Direct file editing at `~/.config/tmux/omarchy-themes/`
* **Performance**: Faster theme switching (no config regeneration overhead)

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
