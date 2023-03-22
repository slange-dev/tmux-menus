#!/bin/sh
#
#   Copyright (c) 2022-2023: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Split display
#

#  shellcheck disable=SC2034
#  Directives for shellcheck directly after bang path are global

# shellcheck disable=SC1007
CURRENT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SCRIPT_DIR="$(dirname "$CURRENT_DIR")/scripts"

# shellcheck disable=SC1091
. "$SCRIPT_DIR/utils.sh"

menu_name="Split view"
full_path_this="$CURRENT_DIR/$(basename $0)"
req_win_width=33
req_win_height=15

reload="; run-shell \"$full_path_this\""
open_menu="run-shell '$CURRENT_DIR"

t_start="$(date +'%s')"

# shellcheck disable=SC2154
$TMUX_BIN display-menu \
    -T "#[align=centre] $menu_name " \
    -x "$menu_location_x" -y "$menu_location_y" \
    \
    "Back to Main menu  <--" Left "$open_menu/main.sh'" \
    "-#[align=centre,nodim]----  Split Pane  ----" "" "" \
    "    Left" l "split-window -hb  -c '#{pane_current_path}' $reload" \
    "<P> Right" % "split-window -h   -c '#{pane_current_path}' $reload" \
    "    Above" a "split-window -vb  -c '#{pane_current_path}' $reload" \
    "<P> Below" \" "split-window -v   -c '#{pane_current_path}' $reload" \
    "-#[align=centre,nodim]---  Split Window  ---" "" "" \
    "    Left" L "split-window -fhb -c '#{pane_current_path}' $reload" \
    "    Right" R "split-window -fh  -c '#{pane_current_path}' $reload" \
    "    Above" A "split-window -fvb -c '#{pane_current_path}' $reload" \
    "    Below" B "split-window -fv  -c '#{pane_current_path}' $reload" \
    "" \
    "Help  -->" H "$open_menu/help_split.sh $full_path_this'"

ensure_menu_fits_on_screen
