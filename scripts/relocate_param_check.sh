#!/bin/sh
# shellcheck disable=SC2034
#  Directives for shellcheck directly after bang path are global
#
#   Copyright (c) 2022: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#   Version: 1.2.6 2022-04-21
#
#   Common stuff for relocate_pane.sh & relocate_windows.sh
#   Validate parameters
#

param_check() {
    item_type="$1"

    case "$item_type" in

        "W" | "P" ) : ;;  # Valid parameters

        * )
            # NEEDS TESTING
            error_msg "param_check($1) First param must be W or P!" 1

    esac


    action="$2"

    case "$action" in

        "M" ) : ;;  # Valid parameters

        "L" )
            if [ "$item_type" = "P" ]; then
                # NEEDS TESTING
                error_msg "param_check() Panes can not be linked!" 1
            fi
            ;;

        * )
            # NEEDS TESTING
            error_msg "param_check($1,$2) 2nd param must be L or M Indicating move or link action" 1
            ;;

    esac


    #
    #  inputs:
    #    with pane idx:      =main:1.%13
    #    with window idx:    =main:3.
    #    without window idx: =main:
    #
    raw_dest="$3"


    if [ -z "$raw_dest" ] ; then
        # NEEDS TESTING
        error_msg "param_check() - no destination param (\$3) given!" 1
    fi


    cur_ses="$(tmux display-message -p '#S')"
    dest="${raw_dest#*=}"  # skipping initial =
    dest_ses="${dest%%:*}" # up to first colon excluding it

    win_pane="${dest#*:}"  # after first colon
    dest_win_idx="${win_pane%%.*}"   # up to first dot excluding it
    dest_pane_idx="${win_pane#*.}"

    #  Used by
    #    relocate_window.sh  $dest_ses $dest_win_idx
    #    relocate_pane.sh   $dest_ses $dest_win_idx.${dest_pane_idx}"

    log_it "param_check($*) - item_type [$item_type] action [$action] cur_ses [$cur_ses] dest [$dest] win_pane [$win_pane] dest_ses [$dest_ses] dest_win_idx [$dest_win_idx] dest_pane_idx [$dest_pane_idx]"
}
