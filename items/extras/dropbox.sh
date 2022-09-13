#!/bin/sh
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.0.1 2022-06-30
#
#   Directly control Spotify
#

#  shellcheck disable=SC2034
#  Directives for shellcheck directly after bang path are global

# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ITEMS_DIR="$(dirname "$CURRENT_DIR")"
SCRIPT_DIR="$(dirname "$ITEMS_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

menu_name="Dropbox"
req_win_width=1
req_win_height=1


this_menu="$CURRENT_DIR/dropbox.sh"
reload="; run-shell '$this_menu'"
open_menu="run-shell '$ITEMS_DIR"

prefix="run-shell 'dropbox "
suffix=" > /dev/null' ; run-shell '$this_menu'"


#
#  Argh this uses reverse boolean logic
#   1 is running
#   0 is not running
#
is_dropbox_running() {
    dropbox running && return 1
    if [ "$(dropbox status)" = "Syncing..." ]; then
	return 1  # it is terminating
    else
	return 0
    fi
}


# if run with param, assume it is a toggle action
[ -n "$1" ] && toggle_status $1


if is_dropbox_running; then
    tgl_lbl="sTop"
    tgl_act="stop"
else
    tgl_lbl="sTart"
    tgl_act="start"
fi


t_start="$(date +'%s')"

# shellcheck disable=SC2154
tmux display-menu                                                   \
    -T "#[align=centre] $menu_name "                                \
    -x "$menu_location_x" -y "$menu_location_y"                     \
                                                                    \
    "Back to Main menu"  Home  "$open_menu/main.sh'"                \
    "Back to Extras"     Left  "$open_menu/extras.sh'"              \
    ""                                                              \
    "Status"    s  "display \"$(dropbox status)\" ;                 \
                    run-shell '$this_menu'"                         \
    "$tgl_lbl"  t   "run-shell \"./dropbox_toggle.sh $tgl_act\""    \
    ""                                                              \
    "Help  -->"  H  "$open_menu/help.sh $CURRENT_DIR/dropbox.sh'"


ensure_menu_fits_on_screen