#!/bin/sh
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Move a pane
#

dynamic_content() {
    if tmux_error_handler display-message -p '#{pane_marked_set}' | grep -q '1'; then
        set -- \
            2.1 C m "Swap current pane with marked" "swap-pane $menu_reload" \
            else
        set --
    fi
    menu_generate_part 2 "$@"
}

static_content() {
    set -- \
        0.0 M Left "Back to Handling Pane $nav_prev" panes.sh \
        0.0 M Home "Back to Main menu     $nav_home" main.sh \
        1.7 S

    menu_generate_part 1 "$@"

    set -- \
        1.7 C p "Swap pane with prev" "swap-pane -U $menu_reload" \
        1.7 C n "Swap pane with next" "swap-pane -D $menu_reload" \
        1.7 E o "Move to other win/ses" "$d_scripts/act_choose_tree.sh P M" \
        0.0 S \
        2.4 E w "Break pane to a new window" "$d_scripts/break_pane.sh" \
        1.7 S \
        1.7 M O "Key hints - Move to other $nav_next" \
        "$d_hints/choose-tree.sh $f_current_script" \
        1.7 M H "Help, explaining move     $nav_next" \
        "$d_help/help_pane_move.sh $f_current_script"

    menu_generate_part 3 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

menu_name="Move Pane"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
