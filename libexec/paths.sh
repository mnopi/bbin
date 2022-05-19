#!/bin/sh

#
# Posix Paths ($PATH, $MANPATH, $INFOPATH) Helpers

#######################################
# add/prepend directory to $PATH removing previous entries
# Globals:
#   PATH
# Arguments:
#   1   directory to add
# Returns:
#   1   parameter null or not set
#######################################
path_add() { path_pop "${1?}"; PATH="$1:${PATH:-:${PATH}}"; }

#######################################
# add/prepend directory to $PATH removing previous entries if directory exists
# Arguments:
#   1   directory to add
# Returns:
#   1   parameter null or not set
#######################################
path_add_exist() { path_pop "${1?}"; [ ! -d "$1" ] || path_add "$1"; }

#######################################
# add/prepend $PROJECT_DIR/sbin:$PROJECT_DIR/bin:$PROJECT_DIR/libexec to $PATH removing previous entries if exist
# Globals:
#   PATH
#   PROJECT_DIR
# Arguments:
#   None
#######################################
path_add_exist_project() {
  [ ! "${PROJECT_DIR-}" ] \
    || { path_add_exist "${PROJECT_DIR}/bin"; path_add_exist "${PROJECT_DIR}/sbin"; };
}

#######################################
# add/prepend $1/sbin:$1/bin:$1/libexec to $PATH to $PATH removing previous entries if exist
# Globals:
#   PATH
# Arguments:
#   1   directory
# Returns:
#   1   parameter null or not set
#######################################
path_add_exist_sbin_bin_libexec() {
  path_add_exist "${1?}/libexec"; path_add_exist "${1?}/bin"; path_add_exist "${1}/sbin";
}

#######################################
# append directory to $PATH removing previous entry
# Globals:
#   PATH
# Arguments:
#   1   directory to append
# Returns:
#   1   parameter null or not set
#######################################
path_append() { path_pop "${1?}"; PATH="${PATH:-${PATH}:}$1"; }

#######################################
# append directory to $PATH removing previous entry
# Arguments:
#   1   directory to append
# Returns:
#   1   parameter null or not set
#######################################
path_append_exist() { path_pop "${1?}"; [ ! -d "$1" ] || path_append "$1"; }

#######################################
# remove duplicates from $PATH
# Globals:
#   PATH
# Arguments:
#   None
#######################################
path_dedup() { PATH="$(echo "${PATH}" | tr ':' '\n' | uniq | tr '\n' ':' | sed 's/:$//')"; }

#######################################
# is directory in $PATH
# Globals:
#   PATH
# Arguments:
#   1   directory to check
# Returns:
#   0 if directory in $PATH
#   1 if directory not in $PATH, parameter null or parameter not set
#######################################
path_in() {
  case ":${PATH}:" in
    *:"${1?}":*) return 0 ;;
    *) return 1 ;;
  esac
}

#######################################
# removes directory from $PATH
# Globals:
#   PATH
# Arguments:
#   1   directory to remove
# Returns:
#   1   parameter null or not set
#######################################
path_pop() {
  PATH="$(! path_in "${1?}" || echo "${PATH}" | tr ':' '\n' | uniq | grep -v "$1" | tr '\n' ':' | sed 's/:$//')";
}
