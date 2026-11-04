# Moving development to the laptop

Publication is pending GitHub authentication on the desktop. NixOS origin is
`git@github.com:AlisoneQ/NixOS-config.git`; the shell repository must be created
privately and its verified URL recorded before cloning. Do not substitute an
unverified/public repository. No laptop has been configured remotely.

## Fetch the projects

After publication succeeds, use the verified shell URL supplied by the desktop:

```sh
mkdir -p "$HOME/Projects"
printf 'Verified shell Git URL: '
read -r ISLAND_REPO_URL
git clone "$ISLAND_REPO_URL" "$HOME/Projects/quickshell-island"
sudo git clone --branch redesign/dynamic-island-visual-overhaul \
  git@github.com:AlisoneQ/NixOS-config.git /etc/nixos
```

If `/etc/nixos` already exists, **do not clone over it**. First inspect
`git -C /etc/nixos status` and preserve local configuration/hardware changes.
With the correct remote, branch and a clean tree, update using:

```sh
git -C "$HOME/Projects/quickshell-island" pull --ff-only
sudo git -C /etc/nixos fetch origin
sudo git -C /etc/nixos switch redesign/dynamic-island-visual-overhaul
sudo git -C /etc/nixos pull --ff-only
```

Root may not have your SSH credentials. If root fetch/clone authentication fails,
clone/fetch as your user into a new checkout, review it, and copy it to /etc/nixos
using sudo after preserving the existing configuration. Do not copy private keys
to root or overwrite the existing laptop hardware configuration.

## Essential laptop-only safety checks

Flake outputs are `desktop` and `laptop`; both currently declare hostname
`fortepian`. Select **laptop** explicitly. Its existing hardware file has different
disk UUIDs from desktop but has not been verified on the physical laptop.

Before changing anything, record the working system and retain your current
`/etc/nixos` configuration in a separate backup. Generate a comparison file:

```sh
readlink -f /run/current-system
readlink -f /nix/var/nix/profiles/system
findmnt / /boot
lsblk -f
sudo nixos-generate-config --show-hardware-config > /tmp/laptop-hardware.nix
diff -u /etc/nixos/hosts/laptop/hardware-configuration.nix /tmp/laptop-hardware.nix
```

Review and integrate real laptop hardware data before building. Never use
`hosts/desktop/hardware-configuration.nix`. Check root, boot and swap UUIDs,
encryption/filesystems, CPU platform and kernel modules. The laptop host currently
declares Limine and `/boot` on a vfat partition. Compare against the laptop's
already working bootloader configuration; if it differs, retain the working
bootloader settings and stop to reconcile configuration. Do not install/replace
bootloaders to match this repository.

The personal account is currently `alisoneq` in both host user definitions,
Home Manager mappings in flake.nix, and home.username in home.nix. If your laptop
account differs, change these consistently first. Shell checkout and command
paths derive from Home Manager homeDirectory/xdg.configHome, not a fixed username.

## Evaluate, build, activate

Only after the hardware and bootloader checks:

```sh
cd /etc/nixos
git add hosts/laptop/hardware-configuration.nix # only if reviewed/replaced
nix eval --raw .#nixosConfigurations.laptop.config.system.build.toplevel.drvPath
nixos-rebuild build --flake .#laptop
sudo nixos-rebuild dry-activate --flake .#laptop
sudo nixos-rebuild switch --flake .#laptop
```

Inspect the dry activation plan before switch; don't continue on unexpected
bootloader/session changes. No flake update is needed. User interface changes
must be made in the standalone checkout; it is linked out-of-store and not copied
into an immutable source package. Personal appearance JSON stays writable at
`${XDG_CONFIG_HOME:-$HOME/.config}/quickshell-island-appearance.json`.

## Session and checks

Login to the existing Niri session. The configured tty1 login starts niri-session;
do not start a second Niri inside the current graphical session. Home Manager
installs dependencies and masks Mako; Niri starts one shell through
`/etc/nixos/niri/island.sh`. The laptop Niri file is generated at rebuild time from
the common config with the desktop HDMI-A-2 override and local monitor.kdl include
disabled. Outputs otherwise
use native automatic modes. QML changes remain live; laptop Niri edits need a
Home Manager/NixOS activation.

```sh
readlink -f "$HOME/.config/quickshell/island"
quickshell-island ipc call compositor status
quickshell-island ipc call appearance status
quickshell-island ipc call network status
quickshell-island ipc call bluetooth status
nmcli device status
systemctl is-active NetworkManager bluetooth
busctl --user status org.freedesktop.Notifications
quickshell-island log -t 40
```

Expected source is `$HOME/Projects/quickshell-island`. Mod+Tab opens launcher,
Mod+Space dashboard, Mod+V clipboard, Mod+N history. For an intentional shell-only
restart (session notification history resets):

```sh
quickshell-island kill
quickshell-island --daemonize
```

Do not run another notification daemon alongside it. If the convenience command
is not installed yet, use `sh /etc/nixos/niri/island.sh` with the same arguments.
See the shell repository's docs/connectivity.md: Wi-Fi/BlueZ laptop behavior is
untested, and secure new-device Bluetooth pairing remains incomplete.

## Recovery

Do not reboot just to test. If switch breaks the graphical session, use another
TTY (Ctrl+Alt+F2), login and run `sudo nixos-rebuild switch --rollback`. If the
machine cannot boot, select the previously working generation in its existing
boot menu. Preserve generations and the previous configuration. Restore/revert
only reviewed source changes before rebuilding; no reset/GC/EFI cleanup needed.
