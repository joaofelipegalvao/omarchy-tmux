# Troubleshooting

Common issues and fixes for **Omarchy Tmux**.

## 1. Theme not updating automatically

### Check monitor service status

```bash
systemctl --user status omarchy-tmux-monitor
```

### View monitor logs

```bash
journalctl --user -u omarchy-tmux-monitor -f
```

### Theme not auto-updating

Check if monitor is running:

```bash
pgrep -f omarchy-tmux-monitor
```

Restart service:

```bash
systemctl --user restart omarchy-tmux-monitor
```

## 2. Verify plugin installation

Make sure the plugin directory exists:

```bash
ls -la ~/.config/tmux/plugins/omarchy-tmux
```

Check TPM installation:

```bash
ls -la ~/.tmux/plugins/tpm
```

---

If issues persist, open a [GitHub Issue](https://github.com/joaofelipegalvao/omarchy-tmux/issues)

with:

- your OS and shell
- tmux -V output
- systemctl --user status omarchy-tmux-monitor
- the output of ls ~/.config/omarchy/current/theme
