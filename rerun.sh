#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2039

function _rerun_usage()
{
  cat <<\USAGE
usage: rerun [<option>]

Quicker re-running of previous run commands/scripts, sensitive to current-working directory.

Maintains a list of shell command lines for the local directory,
and allows editing and recalling them for re-running.
Why use this? Sometimes several non-trivial command lines are used in a directory
for running non-trivial tasks. Recalling and editing them using the shell command line editing is not so flexible.

Default usage:
  rerun : open editor on .rerun.sh file in current working directory.

OPTIONS:

  -s|--source : source the script (default is execute it)

  -e|--edit: edit only, do not run

  -r|--run: no edit, just re-run

  -y|--yes: assume yes to question if you want to rerun

  -v, --version: show version
USAGE
}

function rerun()
{
#  echo "rerun $*"
#  set -x
  _rerun_yes=false
  _rerun_source_command=false
  local ret
  local unset_x=:

  local optspec=":ehrsxy-:"
  local OPTIND=1
  local cmd=()
  local options_seen=""
  while getopts "$optspec" optchar; do
#    echo "optchar=$optchar"
    case "${optchar}" in
      e) option=edit;;
      h) option=help;;
      r) option=run;;
      s) option=source;;
      x) option=trace;;
      y) option=yes;;
      -) option="${OPTARG}";;
      *)
        _rerun_error "Unknown option: --$optchar"
        _rerun_usage
        return 1
        ;;
#          if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" != ":" ]; then
#              echo "Unknown option --${OPTARG}" >&2
#          fi
#          ;;
    esac

    if [[ "$options_seen" = *" $option "* ]]; then
      continue
    fi
#    echo "option=$option"
    case "$option" in
      edit)
        cmd+=(_rerun_cmd_edit)
        ;;
      run)
        cmd+=(_rerun_cmd_run)
        ;;
      source)
        _rerun_source_command=true
        ;;
      yes)
        _rerun_yes=true
        ;;
      help)
        _rerun_usage >&2
        return 2
        ;;
      trace)
        unset_x='set +x'
        set -x
        ;;
      *)
        _rerun_error "Unknown arguments: $*"
        _rerun_usage
        return 3
        ;;
    esac
    options_seen+=" $option "
  done
  case "${#cmd[*]}" in
  0) cmd+=(_rerun_cmd_edit_then_run);;
  1) true;;
  *)
    _rerun_error "Incompatible options: $*"
    _rerun_usage
    return 1
    ;;
  esac
  "${cmd[0]}"
  ret=$?
  eval "$unset_x"
  return "$ret"
}

function _rerun_cmd_run()
{
  _rerun_get_file
  _rerun_run_file
}

function _rerun_cmd_edit_then_run()
{
  _rerun_get_file
  _rerun_edit_file
  if $_rerun_yes || _rerun_confirm_run_file; then
    _rerun_run_file
  fi
}

function _rerun_cmd_edit()
{
  _rerun_get_file
  _rerun_edit_file
}

function _rerun_get_file()
{
  RERUN_FILE=$(pwd)/.rerun.sh
  touch "$RERUN_FILE"
}


function _rerun_edit_file()
{
    if [ "${EDITOR:-}" = "" ]; then
      local e
      for e in nano vim vi; do
        if which "$e" &>/dev/null; then
          EDITOR="$e"
          break
        fi
      done
      if [ "${EDITOR:-}" = "" ]; then
        _rerun_error "EDITOR environment variable not defined, and nano, vim, vi not found."
        return 1
      fi
    fi
    "$EDITOR" "$RERUN_FILE"
}

function _rerun_confirm_run_file()
{
  local answer
  if read -r -p "Execute [$RERUN_FILE] [n]? " answer; then
    case "$answer" in
      [yY]|[yY][eE][sS]) return 0;;
    esac
  fi
  return 1
}

function _rerun_run_file()
{
  if $_rerun_source_command; then
    echo "Sourcing: \"$RERUN_FILE\""
    # shellcheck disable=SC1090
    source "$RERUN_FILE"
  else
    chmod +x "$RERUN_FILE"
    echo "Executing: \"$RERUN_FILE\""
    "$RERUN_FILE"
  fi
}

# Displays version
function _rerun_version()
{
  echo "run version 0.9.0"
}

# Displays the given error.
# Used for common error output.
function _rerun_error()
{
  (>&2 echo -e "run error: $1")
}

# Displays the given warning.
# Used for common warning output.
function _rerun_warning()
{
  (>&2 echo -e "run warning: $1")
}
