#!/bin/sh
# Also works before the Home Manager command has been installed.
exec qs -p "${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/island/src" "$@"
