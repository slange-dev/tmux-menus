#!/bin/sh
# Always sourced file - Fake bang path to help editors
#
#   Copyright (c) 2022-2025: Jacob.Lundqvist@gmail.com
#   License: MIT
#
#   Part of https://github.com/jaclu/tmux-menus
#
#  Handling tmux env
#
# shellcheck disable=SC2034,SC2154

tmux_get_defaults() {
    #
    #  Defaults for plugin params
    #
    #  Public variables
    #   default_  defaults for tmux config options
    #

    # log_it "tmux_get_defaults()"

    default_trigger_key=\\
    default_no_prefix=No

    default_simple_style_selected=default
    default_simple_style=default
    default_simple_style_border=default
    default_format_title="'#[align=centre]  #{@menu_name} '"

    default_nav_next="-->"
    default_nav_prev="<--"
    default_nav_home="<=="

    if tmux_vers_check 3.2; then
        default_location_x=C
        default_location_y=C
    else
        default_location_x=P
        default_location_y=P
    fi

    default_use_cache=Yes

    default_use_hint_overlays=Yes
    default_show_key_hints=No

    if [ -n "$TMUX_CONF" ]; then
        default_tmux_conf="$TMUX_CONF"
    elif [ -n "$XDG_CONFIG_HOME" ]; then
        default_tmux_conf="$XDG_CONFIG_HOME/tmux/tmux.conf"
    else
        default_tmux_conf="$HOME/.tmux.conf"
    fi

    default_log_file=""
    # log_it "><>   tmux_get_defaults() - done"
}

tmux_is_option_defined() {
    # log_it "><> tmux_is_option_defined($1)"
    tmux_error_handler show-options -gq | grep -q "^$1"
}

tmux_get_option() {
    tgo_option="$1"
    tgo_default="$2"

    # log_it "tmux_get_option($tgo_option, $tgo_default)"

    [ -z "$tgo_option" ] && error_msg "tmux_get_option() param 1 empty!"

    if [ "$TMUX" = "" ]; then
        # this is run standalone, just report the defaults
        echo "$tgo_default"
        return
    elif ! tmux_vers_check 1.8; then
        # before 1.8 no support for user params
        echo "$tgo_default"
        return
    fi

    if tgo_value="$(tmux_error_handler show-options -gvq "$tgo_option" 2>/dev/null)"; then
        [ -z "$tgo_value" ] && ! tmux_is_option_defined "$tgo_option" && {
            #
            #  Since tmux doesn't differentiate between the variable being absent
            #  and being assigned to "", an extra check is done to see if it is
            #  present, if not the default will be used
            #
            tgo_value="$tgo_default"
        }
    else
        #  All other versions correctly fails on unassigned @options
        tgo_value="$tgo_default"
    fi
    echo "$tgo_value"

    unset tgo_option
    unset tgo_default
    unset tgo_value
}

tmux_get_plugin_options() { # cache references
    #
    #  Public variables
    #   cfg_  config variables, either read from tmux or the default
    #
    # log_it "tmux_get_plugin_options()"

    tmux_get_defaults

    cfg_trigger_key="$(tmux_get_option "@menus_trigger" "$default_trigger_key")"
    if normalize_bool_param "@menus_without_prefix" "$default_no_prefix"; then
        cfg_no_prefix=true
    else
        cfg_no_prefix=false
    fi
    if normalize_bool_param "@menus_use_cache" "$default_use_cache"; then
        cfg_use_cache=true
    else
        cfg_use_cache=false
    fi
    if normalize_bool_param "@menus_use_hint_overlays" "$default_use_hint_overlays"; then
        cfg_use_hint_overlays=true
    else
        cfg_use_hint_overlays=false
    fi
    if normalize_bool_param "@menus_show_key_hints" "$default_show_key_hints"; then
        cfg_show_key_hints=true
    else
        cfg_show_key_hints=false
    fi

    if $cfg_use_whiptail; then
        _whiptail_ignore_msg="not used with whiptail"

        cfg_simple_style_selected="$_whiptail_ignore_msg"
        cfg_simple_style="$_whiptail_ignore_msg"
        cfg_simple_style_border="$_whiptail_ignore_msg"
        cfg_format_title="$_whiptail_ignore_msg"
        cfg_mnu_loc_x="$_whiptail_ignore_msg"
        cfg_mnu_loc_y="$_whiptail_ignore_msg"
        unset _whiptail_ignore_msg

        # Whiptail skips any styling
        cfg_nav_next="$default_nav_next"
        cfg_nav_prev="$default_nav_prev"
        cfg_nav_home="$default_nav_home"
    else
        cfg_simple_style_selected="$(tmux_get_option "@menus_simple_style_selected" \
            "$default_simple_style_selected")"
        cfg_simple_style="$(tmux_get_option "@menus_simple_style" \
            "$default_simple_style")"
        cfg_simple_style_border="$(tmux_get_option "@menus_simple_style_border" \
            "$default_simple_style_border")"
        cfg_format_title="$(tmux_get_option "@menus_format_title" \
            "$default_format_title")"

        cfg_nav_next="$(tmux_get_option "@menus_nav_next" "$default_nav_next")"
        cfg_nav_prev="$(tmux_get_option "@menus_nav_prev" "$default_nav_prev")"
        cfg_nav_home="$(tmux_get_option "@menus_nav_home" "$default_nav_home")"
        cfg_mnu_loc_x="$(tmux_get_option "@menus_location_x" "$default_location_x")"
        cfg_mnu_loc_y="$(tmux_get_option "@menus_location_y" "$default_location_y")"
    fi

    cfg_tmux_conf="$(tmux_get_option "@menus_config_file" "$default_tmux_conf")"
    _f="$(tmux_get_option "@menus_log_file" "$default_log_file")"
    [ -z "$cfg_log_file" ] && [ -n "$_f" ] && {
        #  If a debug logfile has been set, the tmux setting will be ignored.
        cfg_log_file="$_f"
    }
    #
    #  Generic plugin setting I use to add Notes to keys that are bound
    #  This makes this key binding show up when doing <prefix> ?
    #  If not set to "Yes", no attempt at adding notes will happen
    #  bind-key Notes were added in tmux 3.1, so should not be used on
    #  older versions!
    #
    if tmux_vers_check 3.1 &&
        normalize_bool_param "@use_bind_key_notes_in_plugins" No; then
        # log_it "><> using notes"
        cfg_use_notes=true
    else
        # log_it "><> ignoring notes"
        cfg_use_notes=false
    fi
    # log_it "  tmux_get_plugin_options() - done"
}

tmux_error_handler() { # cache references
    #
    #  Detects any errors reported by tmux commands and gives notification
    #
    the_cmd="$*"

    $teh_debug && log_it "><> tmux_error_handler($the_cmd)"

    if $cfg_use_cache; then
        d_errors="$d_cache"
    else
        d_errors="$d_tmp"
    fi
    # ensure it exists
    [ ! -d "$d_errors" ] && mkdir -p "$d_errors"
    f_tmux_err="$d_errors"/tmux-err
    $teh_debug && log_it "><>teh $TMUX_BIN $*"
    $TMUX_BIN "$@" 2>"$f_tmux_err" && rm -f "$f_tmux_err"
    $teh_debug && log_it "><>teh cmd done [$?]"
    [ -s "$f_tmux_err" ] && {
        #
        #  First save the error to a named file
        #
        base_fname="$(tr -cs '[:alnum:]._' '_' <"$f_tmux_err")"
        [ -z "$base_fname" ] && base_fname="tmux-error"
        f_error_log="$d_errors/error-$base_fname"
        unset base_fname

        [ -f "$f_error_log" ] && {
            _i=1
            f_error_log="${f_error_log}-$_i"
            while [ -f "$f_error_log" ]; do
                _i=$((_i + 1))
                f_error_log="${f_tmux_err}-$_i"
                [ "$_i" -gt 1000 ] && {
                    error_msg "Aborting runaway loop - _i=$_i"
                }
            done
            unset _i
        }
        (
            echo "\$TMUX_BIN $the_cmd"
            echo
            cat "$f_tmux_err"
        ) >"$f_error_log"

        if $teh_debug; then
            log_it "$(
                printf "tmux cmd failed:\n\n%s\n" "$(cat "$f_error_log")"
            )"
        else
            log_it "saved error to: $f_error_log"
            error_msg "$(
                printf "tmux cmd failed:\n\n%s\n
                \nThe full error message has been saved in:\n%s
                \nFull path:\n%s\n" \
                    "$(cat "$f_error_log")" \
                    "$(relative_path "$f_error_log")" \
                    "$f_error_log"
            )"
        fi
        unset f_error_log
        return 1
    }
    unset the_cmd
    teh_debug=false
    return 0
}

tmux_select_menu_handler() {
    # support old env variable, cam be deleted eventually 241220
    [ -n "$FORCE_WHIPTAIL_MENUS" ] && TMUX_MENU_HANDLER="$FORCE_WHIPTAIL_MENUS"

    #
    # If an older version is used, or TMUX_MENU_HANDLER is 1/2
    # set cfg_use_whiptail true
    #
    if ! tmux_vers_check 3.0; then
        if command -v whiptail >/dev/null; then
            cfg_alt_menu_handler=whiptail
            log_it "tmux below 3.0 - using: whiptail"
        elif command -v dialog >/dev/null; then
            cfg_alt_menu_handler=dialog
            log_it "tmux below 3.0 - using: dialog"
        else
            error_msg "Neither whiptail or dialog found, plugin aborted"
        fi
        cfg_use_whiptail=true
    elif [ "$TMUX_MENU_HANDLER" = 1 ]; then
        _cmd=whiptail
        if command -v "$_cmd" >/dev/null; then
            cfg_alt_menu_handler="$_cmd"
        else
            error_msg "$_cmd not available, plugin aborted"
        fi
        cfg_use_whiptail=true
        log_it "$_cmd is selected due to TMUX_MENU_HANDLER=1"
        unset _cmd
    elif [ "$TMUX_MENU_HANDLER" = 2 ]; then
        _cmd=dialog
        if command -v "$_cmd" >/dev/null; then
            cfg_alt_menu_handler="$_cmd"
        else
            error_msg "$_cmd not available, plugin aborted"
        fi
        cfg_use_whiptail=true
        log_it "$_cmd is selected due to TMUX_MENU_HANDLER=2"
        unset _cmd
    else
        cfg_use_whiptail=false
    fi
}

#---------------------------------------------------------------
#
#   tmux version related support functions
#
#---------------------------------------------------------------

tmux_vers_check() {
    _v_comp="$1" # Desired minimum version to check against
    # log_it "><> tmux_vers_ok($_v_comp) $0"

    # Retrieve and cache the current tmux version on the first call
    if [ -z "$tpt_current_vers" ] || [ -z "$tpt_current_vers_i" ]; then
        tpt_retrieve_running_tmux_vers
    fi

    $cfg_use_cache && {
        [ -z "$cached_ok_tmux_versions" ] && [ -f "$f_cache_known_tmux_vers" ] && {
            #
            # get known good/bad versions if this hasn't been sourced yet
            #
            # shellcheck source=/dev/null
            . "$f_cache_known_tmux_vers"
        }
        case "$cached_ok_tmux_versions $tvc_v_ref " in
        *"$_v_comp "*) return 0 ;;
        *) ;;
        esac
        case "$cached_bad_tmux_versions" in
        *"$_v_comp "*) return 1 ;;
        *) ;;
        esac
    }

    # Compare numeric parts first for quick decisions.
    _i_comp="$(tpt_digits_from_string "$_v_comp")"
    [ "$_i_comp" -lt "$tpt_current_vers_i" ] && {
        cache_add_ok_vers "$_v_comp"
        return 0
    }
    [ "$_i_comp" -gt "$tpt_current_vers_i" ] && {
        cache_add_bad_vers "$_v_comp"
        return 1
    }

    # Compare suffixes only if numeric parts are equal.
    _suf="$(tpt_tmux_vers_suffix "$_v_comp")"
    # - If no suffix is required or suffix matches, return success
    [ -z "$_suf" ] || [ "$_suf" = "$tpt_current_vers_suffix" ] && {
        cache_add_ok_vers "$_v_comp"
        return 0
    }
    # If the desired version has a suffix but the running version doesn't, fail
    [ -n "$_suf" ] && [ -z "$tpt_current_vers_suffix" ] && {
        cache_add_bad_vers "$_v_comp"
        return 1
    }
    # Perform lexicographical comparison of suffixes only if necessary
    [ "$(printf '%s\n%s\n' "$_suf" "$tpt_current_vers_suffix" |
        LC_COLLATE=C sort | head -n 1)" = "$_suf" ] && {
        cache_add_ok_vers "$_v_comp"
        return 0
    }
    # If none of the above conditions are met, the version is insufficient
    cache_add_bad_vers "$_v_comp"
    return 1
}

tpt_retrieve_running_tmux_vers() {
    #
    # If the variables defining the currently used tmux version needs to
    # be accessed before the first call to tmux_vers_ok this can be called.
    #
    # log_it "tpt_retrieve_running_tmux_vers()"
    tpt_current_vers="$($TMUX_BIN -V | cut -d' ' -f2)"
    tpt_current_vers_i="$(tpt_digits_from_string "$tpt_current_vers")"
    tpt_current_vers_suffix="$(tpt_tmux_vers_suffix "$tpt_current_vers")"
}

# Extracts all numeric digits from a string, ignoring other characters.
# Example inputs and outputs:
#   "tmux 1.9" => "19"
#   "1.9a"     => "19"
tpt_digits_from_string() {
    # the first sed removes -rc suffixes, to avoid anny numerical rc like -rc1 from
    # being included in the int extraction
    _i="$(echo "$1" | sed 's/-rc[0-9]*//' | tr -cd '0-9')" # Use 'tr' to keep only digits
    echo "$_i"
}

# Extracts any alphabetic suffix from the end of a version string.
# If no suffix exists, returns an empty string.
# Example inputs and outputs:
#   "3.2"  => ""
#   "3.2a" => "a"
tpt_tmux_vers_suffix() {
    echo "$1" | sed 's/.*[0-9]\([a-zA-Z]*\)$/\1/'
}

#===============================================================
#
#   Main
#
#===============================================================

#
#  I use an env var TMUX_BIN to point at the current tmux, defined in my
#  tmux.conf, to pick the version matching the server running.
#  This is needed when checking backward compatibility with various versions.
#  If not found, it is set to whatever is in the path, so should have no negative
#  impact. In all calls to tmux I use TMUX_BIN instead in the rest of this
#  plugin.
#

[ -z "$TMUX_BIN" ] && TMUX_BIN="tmux"

if [ -n "$TMUX" ]; then
    tmux_pid="$(echo "$TMUX" | cut -d',' -f2)"
else
    # was run outside tmux
    tmux_pid="-1"
fi

teh_debug=false
cfg_alt_menu_handler=""

tmux_select_menu_handler

# log_it "scripts/utils/tmux.sh - completed"
