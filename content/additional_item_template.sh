#!/bin/sh
#
#  Copyright (c) 2025: Jacob.Lundqvist@gmail.com
#  License: MIT
#
#  Part of https://github.com/jaclu/tmux-menus
#
#  Template additional item, copy this into additional_items and modify!
#

static_content() {

    set -- \
        0.0 M Left "Back to Additional items $nav_prev" "$f_additional_items_index" \
        0.0 M Left "Back to Main menu        $nav_home" main.sh \
        0.0 S \
        0.0 T "*** Replace this line with one or more lines of custom contnent! ***"

    menu_generate_part 1 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="My Adidtional Menu"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh

# An additional items menu must define menu_key & menu_label,
# in order to be listed in the additional_items index menu

# Since this will be used to point to this menu from the index,
# it is recommended to use uppercase in order to follow the conventions in this plugin,
# but anything goes!
# If a "special" char is used it might need to be prefixed with \
menu_key="?"
menu_label="My additional menu" # short description of this menu
