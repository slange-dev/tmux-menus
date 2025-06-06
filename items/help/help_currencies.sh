#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   General Help
#

static_content() {
    if [ -z "$prev_menu" ]; then
        error_msg "$bn_current_script was called without notice of what called it"
    fi
    set -- \
        0.0 M Left "Back to Previous menu  $nav_prev" "$prev_menu" \
        0.0 M Home "Back to Main menu      $nav_home" main.sh \
        0.0 S \
        0.0 T "-#[nodim]Even if due to font or screen settings," \
        0.0 T "-#[nodim]the symbol isn't visible, this should" \
        0.0 T "-#[nodim]still be able to paste it in."

    if $cfg_use_whiptail; then
        set -- "$@" \
            0.0 T " " \
            0.0 T "When using whiptail it is not possible" \
            0.0 T "to paste directly into the pane." \
            0.0 T "Instead a tmux buffer is used." \
            0.0 T " " \
            0.0 T "Please note that this buffer might become" \
            0.0 T "invalid if another menu is selected" \
            0.0 T "before pasting!" \
            0.0 T " " \
            0.0 T "Once one or more currencies have been selected," \
            0.0 T "cancel this menu. Then, when back in the pane," \
            0.0 T "use <prefix> ] to paste the key(-s)."
    fi
    menu_generate_part 1 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

[ -n "$1" ] && prev_menu="$(realpath "$1")"
menu_name="Help Currency symbols"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname "$(dirname "$(dirname "$(realpath "$0")")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
