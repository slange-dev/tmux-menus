#!/bin/sh
#
#   Copyright (c) 2022-2024: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Help about splitting the view
#

dynamic_content() {
    # Things that change dependent on various states

    if [ -z "$prev_menu" ]; then
        error_msg "$current_script was called without notice of what called it"
    fi

    set -- \
        0.0 M Left "Back to Previous menu $nav_prev" "$prev_menu" \
        0.0 M Home "Back to Main menu     $nav_home" main.sh

    menu_generate_part 1 "$@"
}


static_content() {
    set -- \
        0.0 S \
        0.0 T "-#[align=centre,nodim]----  Commands for buffer list  ----" \
        0.0 T "-Enter  Paste selected buffer" \
        0.0 T "-Up     Select previous buffer" \
        0.0 T "-Down   Select next buffer" \
        2.6 T "-C-s    Search by name or content" \
        2.6 T "-n      Repeat last search forwards" \
        3.5 T "-N      Repeat last search backwards" \
        2.6 T "-t      Toggle if buffer is tagged" \
        2.6 T "-T      Tag no buffers" \
        2.6 T "-C-t    Tag all buffers" \
        2.7 T "-p      Paste selected buffer" \
        2.7 T "-P      Paste tagged buffers" \
        2.6 T "-d      Delete selected buffer" \
        2.6 T "-D      Delete tagged buffers" \
        3.2 T "-e      Open the buffer in an editor" \
        2.6 T "-f      Enter a format to filter items" \
        2.6 T "-O      Change sort field" \
        3.1 T "-r      Reverse sort order" \
        2.6 T "-v      Toggle preview" \
        0.0 T "-q      Exit mode"

    menu_generate_part 2 "$@"
}

#===============================================================
#
#   Main
#
#===============================================================

prev_menu="$(realpath "$1")"
menu_name="Help Paste buffers - Select"

#  Full path to tmux-menux plugin
D_TM_BASE_PATH="$(dirname -- "$(dirname -- "$(realpath "$0")")")"

# shellcheck source=scripts/dialog_handling.sh
. "$D_TM_BASE_PATH"/scripts/dialog_handling.sh
