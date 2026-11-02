# Island experiment

Baseline: `334aebf4b92eae75e307ee413f3c712c2700cb99`, preserved on `main`.
Branch: `redesign/dynamic-island-visual-overhaul`. The baseline worktree was clean;
Quickshell loaded and Niri validated. Known baseline issues were a Mako ownership
conflict, SVG warnings, and unverified synthetic pointer tests.

Runtime: Quickshell 0.3.1 runs `/etc/nixos/quickshell/shell.qml` with
`qs -p /etc/nixos/quickshell --no-duplicate --daemonize`. Niri reads
`~/.config/niri/config.kdl`, linked to `/etc/nixos/niri/config.kdl`.
Outputs: DP-3 (2560x1440 at 0,0), HDMI-A-1 (1920x1080 at 2560,665), scale 1.

## Rollback

In `/etc/nixos`, run `git status --short` first. Preserve any later edits in
reviewed local commits before switching. With a clean tree:

```sh
git switch main
qs -p /etc/nixos/quickshell kill
qs -p /etc/nixos/quickshell --no-duplicate --daemonize
```

If `main` has subsequently advanced, use
`git switch -c restore/pre-redesign 334aebf4b92eae75e307ee413f3c712c2700cb99`
instead. The experiment remains on its named branch. Return with
`git switch redesign/dynamic-island-visual-overhaul` and the same restart commands.
QML normally reloads automatically; a full restart also clears session-only
notification history. Do not run the baseline and experiment simultaneously.

## Mako correction

The old installed profile still includes `fr.emersion.mako.service`, which
activates `mako.service` over D-Bus. Mako actually owned the notification bus.
Removing its package from source and disabling autostart did not remove that
activation route. The unit is now stopped and masked; Home Manager declares
the same mask. No NixOS rebuild was performed.

This runtime mask survives a Git switch deliberately: the original Quickshell
backend also benefits from it. To restore Mako as well, stop Quickshell, run
`systemctl --user unmask mako.service`, then `systemctl --user start mako.service`.
If Home Manager has applied the declaration, remove/revert it before its next
activation too. Never deliberately run both notification servers.

## Review

Super+Space: launcher; Super+V: clipboard; Super+N: notifications. The speaker
opens audio; the power button opens session actions. Escape closes interactive
content. Avoid confirming destructive session actions during review.
Existing IPC targets `launcher`, `notifications`, `audio`, `power` remain.

Geometry samples verify interpolation and settling; cropped static images verify
layout only. Animation feel should also be reviewed interactively on both monitors.
