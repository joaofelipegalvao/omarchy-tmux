# Troubleshooting

Common issues and solutions for **Omarchy Tmux v2.1**.

> **Scope**: This guide applies to v2.1+ (persistent profile architecture).
> If you are on v2.0 or earlier, migrate first using [INSTALL.md](/docs/INSTALL.md#migration-from-v20-to-v21).

---

## Quick Diagnostics

Before diving into specific problems, verify that the core components exist:

```bash
# Omarchy theme detection (3.3+)
cat ~/.config/omarchy/current/theme.name 2>/dev/null || echo "theme.name missing"

# tmux version
tmux -V

# Persistent profiles directory
ls -la ~/.config/tmux/omarchy-themes/ 2>/dev/null

# Current theme symlink
ls -l ~/.config/tmux/omarchy-current-theme.conf 2>/dev/null

# Reload + generator scripts
ls -la ~/.local/bin/omarchy-tmux-{reload,generator} 2>/dev/null
```

If any of these are missing, reinstalling with `-f` usually resolves the issue.

---

## 1. Theme Not Updating Automatically

### Symptoms

* Omarchy theme changes, but tmux stays the same
* Theme only updates after manual reload

### What to Check

1. **Omarchy updates `theme.name`**
2. **The `theme-set` hook exists and is executable**
3. **The reload script runs without errors**

```bash
~/.local/bin/omarchy-tmux-reload
echo $?
```

### Fix

```bash
# Reinstall hooks and scripts
bash omarchy-tmux-install.sh -f

# Ensure executability
chmod +x ~/.config/omarchy/hooks/theme-set
chmod +x ~/.local/bin/omarchy-tmux-{reload,generator}
```

If `theme.name` does not change, the issue is upstream in Omarchy itself.

---

## 2. PowerKit Not Installed

### Symptoms

* Status bar looks default or broken
* PowerKit options have no effect

### Fix (Recommended)

Inside tmux:

```
prefix + I
```

Then reload:

```bash
tmux source-file ~/.config/tmux/tmux.conf
```

Ensure TPM is initialized in `tmux.conf`:

```bash
run '~/.tmux/plugins/tpm/tpm'
# or
run '~/.config/tmux/plugins/tpm/tpm'
```

---

## 3. Theme Profile Not Created

### Symptoms

* Symlink points to a missing file
* Errors about missing `.conf` files

### Fix

```bash
# Run generator manually
~/.local/bin/omarchy-tmux-generator

# Verify profiles
ls ~/.config/tmux/omarchy-themes/
```

Profiles are created **once**, on first use. Existing files are never overwritten.

---

## 4. Broken Symlink

### Symptoms

* `omarchy-current-theme.conf` points to a non-existent file

### Fix

```bash
# Generator always repairs the symlink
~/.local/bin/omarchy-tmux-generator
```

Or switch themes once via Omarchy.

---

## 5. tmux.conf Integration Missing

### Symptoms

* No theme applied at all
* tmux uses default appearance

### Fix

Reinstall integration:

```bash
bash omarchy-tmux-install.sh
```

Or manually ensure this line exists:

```bash
source-file ~/.config/tmux/omarchy-current-theme.conf
```

---

## 6. Permission Errors

### Symptoms

* "Permission denied" during install or reload

### Fix

```bash
chmod u+w ~/.config/tmux ~/.config/omarchy ~/.local/bin
chmod +x ~/.local/bin/omarchy-tmux-{reload,generator}
```

Then rerun the installer.

---

## 7. TPM Not Found

### Symptoms

* Installer warns that TPM is missing

### Fix

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# or
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
```

Restart tmux and press `prefix + I`.

---

## 8. Omarchy Version Too Old

### Symptoms

* `theme.name` file missing

### Explanation

Omarchy Tmux v2.1 requires **Omarchy 3.3+**.

### Options

* Upgrade Omarchy (recommended)
* Use Omarchy Tmux v2.0 if stuck on Omarchy 3.1–3.2

---

## 9. Theme Looks Incorrect

### Possible Causes

* Theme has no PowerKit equivalent (fallback is used)
* Wrong variant in profile
* Terminal overrides colors

### Fix

Edit the active profile:

```bash
nano ~/.config/tmux/omarchy-current-theme.conf
```

Adjust PowerKit options and reload tmux. Changes persist permanently.

---

## 10. Customizations Lost After Theme Switch

> This should **never happen** in v2.1.

### If It Does

* Ensure generator version is v2.1+
* Ensure only one generator script exists

```bash
find ~ -name omarchy-tmux-generator 2>/dev/null
```

Then reinstall with force:

```bash
bash omarchy-tmux-install.sh -f
```

---

## Collecting Debug Info

If opening an issue, include:

* Omarchy version
* tmux version
* Output of `ls -l ~/.config/tmux/omarchy-current-theme.conf`
* Whether PowerKit is installed

Avoid pasting full configs unless requested.

### Quick Debug Info Collection

To quickly gather all relevant info into a single file:

```bash
{
  echo "Theme: $(cat ~/.config/omarchy/current/theme.name 2>/dev/null || echo 'N/A')"
  echo "Symlink: $(readlink ~/.config/tmux/omarchy-current-theme.conf 2>/dev/null || echo 'missing')"
  echo "Generator: $(grep v2.1 ~/.local/bin/omarchy-tmux-generator 2>/dev/null && echo 'v2.1+' || echo 'outdated/missing')"
} | tee omarchy-tmux-debug.txt
```

---

## Common Pitfalls

* ❌ Editing the integration block in `tmux.conf`
* ❌ Running the installer inside tmux
* ❌ Forgetting `prefix + I` after install
* ❌ Mixing v2.0 and v2.1 files

---

## Learn More

* [INSTALL.md](INSTALL.md)
* [HOW_IT_WORK.md](HOW_IT_WORK.md)
* [https://github.com/fabioluciano/tmux-powerkit](https://github.com/fabioluciano/tmux-powerkit)
* [https://github.com/joaofelipegalvao/omarchy-tmux/issues](https://github.com/joaofelipegalvao/omarchy-tmux/issues)
