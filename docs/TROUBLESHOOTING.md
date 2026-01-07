# Troubleshooting

Common issues and solutions for **Omarchy Tmux v2.0**.

> **Note**: This guide is for v2.0+ (PowerKit-based configuration generator).  
> If using v1.x, please [migrate first](INSTALL.md#migrating-from-v10).

## Quick Diagnostics

Run these commands to check your setup:

```bash
# 1. Check Omarchy version (must be 3.1+)
ls -la ~/.config/omarchy/hooks
# Directory should exist for v3.1+

# 2. Check tmux version
tmux -V

# 3. Check if symlink exists and is valid
ls -l ~/.config/omarchy/current/theme
# Should point to a theme directory

# 4. Verify symlink target exists
ls -la $(readlink -f ~/.config/omarchy/current/theme)

# 5. Check if current theme has tmux.conf
ls -la ~/.config/omarchy/current/theme/tmux.conf

# 6. Check if hook exists
cat ~/.config/omarchy/hooks/theme-set
# Should contain: ~/.local/bin/omarchy-tmux-reload

# 7. Check if reload script exists
cat ~/.local/bin/omarchy-tmux-reload
# Should be 10-line script

# 8. Check if PowerKit is installed
ls -la ~/.config/tmux/plugins/tmux-powerkit
# or
ls -la ~/.tmux/plugins/tmux-powerkit

# 9. Check tmux.conf integration
grep -A 5 "Omarchy Tmux Integration" ~/.config/tmux/tmux.conf
```

## 1. Theme Not Updating Automatically

### Symptom

You switch Omarchy themes (Super + Ctrl + Shift + Space) but tmux doesn't change.

### Diagnosis Steps

**Step 1: Verify symlink updates**

```bash
# Check current symlink
ls -l ~/.config/omarchy/current/theme
# Note the target: e.g., ../themes/tokyo-night

# Switch theme in Omarchy
# Super + Ctrl + Shift + Space

# Check symlink again
ls -l ~/.config/omarchy/current/theme
# Target should be different now
```

If symlink doesn't update → **Omarchy issue**, not tmux-omarchy issue.

**Step 2: Check if hook exists**

```bash
cat ~/.config/omarchy/hooks/theme-set
```

Should contain:

```bash
#!/bin/bash
~/.local/bin/omarchy-tmux-reload
```

**Step 3: Test hook manually**

```bash
# Run reload script manually
~/.local/bin/omarchy-tmux-reload

# Check exit code
echo $?
# Should be 0
```

**Step 4: Check if tmux is running**

```bash
# List tmux sessions
tmux list-sessions

# If empty, start tmux first
tmux

# Then test theme switching
```

### Solutions

#### Solution 1: Hook not installed

```bash
# Re-run installer
bash install.sh -f
```

#### Solution 2: Hook not executable

```bash
chmod +x ~/.config/omarchy/hooks/theme-set
chmod +x ~/.local/bin/omarchy-tmux-reload
```

#### Solution 3: Reload script missing

```bash
# Recreate reload script
cat > ~/.local/bin/omarchy-tmux-reload <<'SCRIPT'
#!/bin/bash
set -euo pipefail
readonly TMUX_CONF="$HOME/.config/tmux/tmux.conf"
if tmux list-sessions &>/dev/null 2>&1; then
  tmux source-file "$TMUX_CONF" &>/dev/null || true
  tmux refresh-client -S &>/dev/null || true
fi
exit 0
SCRIPT

chmod +x ~/.local/bin/omarchy-tmux-reload
```

#### Solution 4: Multiple tmux servers

```bash
# Kill all tmux servers and restart
tmux kill-server
tmux

# Test theme switching again
```

## 2. PowerKit Not Installed

### Symptom

After installation, tmux status bar looks broken, uses default theme, or shows errors.

### Diagnosis

```bash
# Check if PowerKit exists
ls -la ~/.config/tmux/plugins/tmux-powerkit
# or
ls -la ~/.tmux/plugins/tmux-powerkit
```

If directory doesn't exist → PowerKit not installed.

### Solution

**Method 1: Install via TPM (recommended)**

1. Start tmux: `tmux`
2. Press `prefix + I` (Ctrl+b Shift+i)
3. Wait for installation
4. Reload: `tmux source-file ~/.config/tmux/tmux.conf`

**Method 2: Manual installation**

```bash
# Clone PowerKit
git clone https://github.com/fabioluciano/tmux-powerkit \
  ~/.config/tmux/plugins/tmux-powerkit

# Reload tmux
tmux source-file ~/.config/tmux/tmux.conf
```

**Method 3: Check TPM configuration**

Ensure your tmux.conf has TPM initialization:

```bash
grep -A 2 "run.*tpm" ~/.config/tmux/tmux.conf
```

Should show:

```bash
run '~/.config/tmux/plugins/tpm/tpm'
# or
run '~/.tmux/plugins/tpm/tpm'
```

If missing, add it:

```bash
echo "run '~/.tmux/plugins/tpm/tpm'" >> ~/.config/tmux/tmux.conf
```

## 3. Theme Config Not Found

### Symptom

Error: "Current theme doesn't have tmux.conf" or "No such file or directory"

### Diagnosis

```bash
# Check current theme name
THEME=$(basename $(readlink -f ~/.config/omarchy/current/theme))
echo "Current theme: $THEME"

# Check if config exists
ls -la ~/.config/omarchy/themes/$THEME/tmux.conf
```

### Solutions

#### Solution 1: Regenerate all configs

```bash
bash install.sh -f
```

This regenerates configs for **all** themes.

#### Solution 2: Manually create config

```bash
# Get current theme
THEME=$(basename $(readlink -f ~/.config/omarchy/current/theme))

# Map to PowerKit theme (adjust as needed)
# See: https://github.com/fabioluciano/tmux-powerkit for available themes

cat > ~/.config/omarchy/themes/$THEME/tmux.conf <<'EOF'
# ============================================================================
# Omarchy Tmux Theme: THEME_NAME
# ============================================================================

# PowerKit Plugin
set -g @plugin 'fabioluciano/tmux-powerkit'

# Theme Configuration
set -g @powerkit_theme 'tokyo-night'
set -g @powerkit_theme_variant 'night'

# Plugins (customize as needed)
set -g @powerkit_plugins "datetime,battery,cpu,memory,hostname"

# Visual Options
set -g @powerkit_separator_style "normal"

# Performance
set -g @powerkit_status_interval "5"

# PowerKit keybindings
set -g @powerkit_theme_selector_key "T"
set -g @powerkit_reload_config_key "R"

# ============================================================================
# Custom Configuration
# ============================================================================
EOF

# Adjust theme values above to match your Omarchy theme
```

#### Solution 3: Switch themes once

```bash
# Omarchy should generate config on first switch
# Super + Ctrl + Shift + Space
# Then switch back to desired theme
```

## 4. Broken Symlink

### Symptom

Error: "No such file or directory" or symlink points to non-existent directory.

### Diagnosis

```bash
# Check symlink
ls -l ~/.config/omarchy/current/theme

# Check if target exists
ls -la $(readlink ~/.config/omarchy/current/theme) 2>/dev/null || echo "Target doesn't exist"
```

### Solutions

#### Solution 1: Recreate symlink

```bash
# Remove broken symlink
rm ~/.config/omarchy/current/theme

# List available themes
ls ~/.config/omarchy/themes/

# Create symlink to a theme (replace tokyo-night)
ln -s ~/.config/omarchy/themes/tokyo-night \
  ~/.config/omarchy/current/theme
```

#### Solution 2: Let Omarchy fix it

```bash
# Switch theme via Omarchy (will recreate symlink)
# Super + Ctrl + Shift + Space
```

## 5. tmux.conf Not Configured

### Symptom

Theme doesn't load at all, tmux uses default appearance, no errors shown.

### Diagnosis

```bash
# Check if integration exists
grep "Omarchy Tmux Integration" ~/.config/tmux/tmux.conf
```

If empty → Integration not installed.

### Solutions

#### Solution 1: Run installer

```bash
bash install.sh
```

#### Solution 2: Manual integration

```bash
# Backup current config
cp ~/.config/tmux/tmux.conf ~/.config/tmux/tmux.conf.backup

# Add integration
cat >> ~/.config/tmux/tmux.conf <<'EOF'

# ============================================================================
# Omarchy Tmux Integration (v2.0)
# Theme syncs automatically via symlink - DO NOT EDIT THIS SECTION
# ============================================================================
source-file ~/.config/omarchy/current/theme/tmux.conf
# End Omarchy Tmux Integration

# Initialize and run tpm
run '~/.tmux/plugins/tpm/tpm'
EOF

# Reload
tmux source-file ~/.config/tmux/tmux.conf
```

## 6. Permission Issues

### Symptom

Installation fails with "Permission denied" errors.

### Diagnosis

```bash
# Check directory permissions
ls -la ~/.config/tmux
ls -la ~/.config/omarchy
ls -la ~/.local/bin

# Check file ownership
stat ~/.config/tmux/tmux.conf
stat ~/.config/omarchy/hooks/theme-set
```

### Solutions

```bash
# Fix directory permissions
chmod u+w ~/.config/tmux
chmod u+w ~/.config/omarchy
chmod u+w ~/.local/bin

# Fix file permissions
chmod u+w ~/.config/tmux/tmux.conf
chmod +x ~/.config/omarchy/hooks/theme-set
chmod +x ~/.local/bin/omarchy-tmux-reload

# Retry installation
bash install.sh
```

## 7. TPM Not Found

### Symptom

Installer says "TPM (Tmux Plugin Manager) not found"

### Diagnosis

```bash
# Check both possible locations
ls -la ~/.tmux/plugins/tpm
ls -la ~/.config/tmux/plugins/tpm
```

### Solutions

#### Solution 1: Install TPM (standard location)

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

#### Solution 2: Install TPM (XDG location)

```bash
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
```

#### Solution 3: Fix TPM in tmux.conf

Ensure your tmux.conf has TPM initialization:

```bash
# Add to ~/.config/tmux/tmux.conf
run '~/.tmux/plugins/tpm/tpm'
```

Then restart tmux and press `prefix + I`.

## 8. Omarchy Version Too Old

### Symptom

Installer says "Omarchy hook directory not found" or "version 3.1 is required"

### Diagnosis

```bash
# Check if hooks directory exists
ls -la ~/.config/omarchy/hooks
```

If directory doesn't exist → Omarchy is pre-3.1.

### Solution

**Upgrade Omarchy to 3.1+**

Visit [Omarchy documentation](https://omarchy.org) for upgrade instructions.

v2.0 **requires** Omarchy 3.1+ for hooks support. v1.0 supported older versions.

## 9. Theme Looks Wrong

### Symptom

Theme loads but colors/style don't match Omarchy.

### Possible Causes

**Cause 1: Unsupported theme**

Some Omarchy themes don't have PowerKit equivalents:

- ethereal
- hackerman
- matte-black
- osaka*
- ristretto

These fallback to `tokyo-night`.

**Cause 2: Wrong variant**

```bash
# Check current config
cat ~/.config/omarchy/current/theme/tmux.conf | grep powerkit_theme
```

**Cause 3: Terminal color settings**

Your terminal emulator might override colors.

```bash
# Test in tmux
echo $TERM
# Should be: screen-256color or tmux-256color
```

### Solutions

#### Solution 1: Check theme mapping

See [supported themes list](README.md#supported-themes) to verify your theme is supported.

#### Solution 2: Adjust variant

```bash
# Edit theme config
vim ~/.config/omarchy/current/theme/tmux.conf

# Find and change variant
set -g @powerkit_theme_variant 'dark'  # or 'light', 'storm', etc.
```

Then reload: `tmux source-file ~/.config/tmux/tmux.conf`

#### Solution 3: Fix terminal colors

Add to your shell RC file (~/.bashrc, ~/.zshrc):

```bash
export TERM=screen-256color
```

Or in tmux.conf:

```bash
set -g default-terminal "screen-256color"
```

## 10. Multiple Tmux Servers

### Symptom

Theme updates in one tmux instance but not others.

### Diagnosis

```bash
# List all tmux servers
ps aux | grep tmux

# List all sessions
tmux list-sessions
```

### Solutions

#### Solution 1: Kill all servers

```bash
# Kill all tmux servers
tmux kill-server

# Start fresh
tmux
```

Theme switching should now work globally.

#### Solution 2: Manual reload per session

```bash
# Attach to each session
tmux attach -t SESSION_NAME

# Reload in each
tmux source-file ~/.config/tmux/tmux.conf
```

## 11. Installation Backup Failed

### Symptom

Installer says "Failed to create backup"

### Diagnosis

```bash
# Check disk space
df -h ~/.config

# Check if tmux.conf exists
ls -la ~/.config/tmux/tmux.conf
```

### Solutions

```bash
# Free up space if needed
# Check ~/.config/tmux/ for old backups

ls -la ~/.config/tmux/tmux.conf.backup-*

# Remove old backups if safe
rm ~/.config/tmux/tmux.conf.backup-OLD_DATE

# Manually create backup
cp ~/.config/tmux/tmux.conf \
   ~/.config/tmux/tmux.conf.backup-$(date +%Y%m%d-%H%M%S)

# Retry installation
bash install.sh
```

## 12. Hook Not Triggering

### Symptom

Symlink updates but tmux doesn't reload.

### Diagnosis

```bash
# Test hook manually
bash ~/.config/omarchy/hooks/theme-set
echo "Exit code: $?"

# Check if hook is executable
ls -la ~/.config/omarchy/hooks/theme-set

# Check hook content
cat ~/.config/omarchy/hooks/theme-set
```

### Solutions

#### Solution 1: Make hook executable

```bash
chmod +x ~/.config/omarchy/hooks/theme-set
```

#### Solution 2: Fix hook content

```bash
cat > ~/.config/omarchy/hooks/theme-set <<'HOOK'
#!/bin/bash
# Omarchy theme-set hook
~/.local/bin/omarchy-tmux-reload
HOOK

chmod +x ~/.config/omarchy/hooks/theme-set
```

#### Solution 3: Check Omarchy hook system

```bash
# Verify Omarchy is calling hooks
# (This is Omarchy's responsibility)

# Test by adding debug output temporarily
cat > ~/.config/omarchy/hooks/theme-set <<'HOOK'
#!/bin/bash
echo "Hook triggered at $(date)" >> /tmp/omarchy-hook-debug.log
~/.local/bin/omarchy-tmux-reload
HOOK

# Switch theme and check log
cat /tmp/omarchy-hook-debug.log
```

## Collecting Debug Info

If issues persist, collect this info for a GitHub issue:

```bash
#!/bin/bash
# Debug info collection script

echo "=== System Info ==="
uname -a
echo ""

echo "=== Omarchy Info ==="
ls -la ~/.config/omarchy/hooks/ || echo "Hooks directory missing"
echo ""

echo "=== Tmux Info ==="
tmux -V
echo ""

echo "=== Symlink Status ==="
ls -l ~/.config/omarchy/current/theme
echo ""

echo "=== Symlink Target ==="
ls -la $(readlink -f ~/.config/omarchy/current/theme 2>/dev/null) || echo "Target doesn't exist"
echo ""

echo "=== Current Theme Config ==="
cat ~/.config/omarchy/current/theme/tmux.conf 2>/dev/null || echo "Config missing"
echo ""

echo "=== Hook File ==="
cat ~/.config/omarchy/hooks/theme-set 2>/dev/null || echo "Hook missing"
echo ""

echo "=== Reload Script ==="
cat ~/.local/bin/omarchy-tmux-reload 2>/dev/null || echo "Reload script missing"
echo ""

echo "=== tmux.conf Integration ==="
grep -A 10 "Omarchy Tmux Integration" ~/.config/tmux/tmux.conf 2>/dev/null || echo "Integration missing"
echo ""

echo "=== PowerKit Installation ==="
ls -la ~/.config/tmux/plugins/tmux-powerkit 2>/dev/null || \
ls -la ~/.tmux/plugins/tmux-powerkit 2>/dev/null || \
echo "PowerKit not installed"
echo ""

echo "=== Test Reload Script ==="
~/.local/bin/omarchy-tmux-reload 2>&1 || echo "Reload script failed"
echo "Exit code: $?"
echo ""

echo "=== Generated Themes ==="
find ~/.config/omarchy/themes -name "tmux.conf" 2>/dev/null || echo "No theme configs found"
```

Save output and include in GitHub issue.

## Getting Help

### 1. Check Documentation

- [Installation Guide](INSTALL.md) - Setup instructions
- [How It Works](HOW_IT_WORKS.md) - Architecture deep dive
- [PowerKit Docs](https://github.com/fabioluciano/tmux-powerkit) - PowerKit reference

### 2. Search Existing Issues

[GitHub Issues](https://github.com/joaofelipegalvao/omarchy-tmux/issues)

### 3. Open New Issue

Include:

- Debug info from above
- What you tried
- Error messages (full text)
- Omarchy theme name
- Expected vs actual behavior

### 4. Community Support

- [Omarchy Discord](https://omarchy.org/discord)
- [r/tmux subreddit](https://reddit.com/r/tmux)

## Common Pitfalls

### ❌ Don't edit the integration block

```bash
# DON'T edit this in tmux.conf
# ============================================================================
# Omarchy Tmux Integration (v2.0)
# Theme syncs automatically via symlink - DO NOT EDIT THIS SECTION
# ============================================================================
```

This is static and should never be changed manually.

### ❌ Don't run installer inside tmux

```bash
# EXIT tmux first
exit

# Then run installer
bash install.sh

# Then start tmux
tmux
```

### ❌ Don't forget prefix + I

After installation, you **must** install PowerKit:

```
prefix + I
```

(Ctrl+b Shift+i)

### ❌ Don't mix v1.0 and v2.0

If upgrading, let the installer handle migration. Don't try to keep old files.

---

**Still stuck?** Open an issue with debug info: [GitHub Issues](https://github.com/joaofelipegalvao/omarchy-tmux/issues)
