#!/usr/bin/env bash
# shellcheck disable=SC2155,SC2046

. paths.sh
# TODO: lo helps quitárselos como están ya que separo el bats del bats.sh
# <html><h2>Bats Description Array</h2>
# <p><strong><code>$BATS_ARRAY</code></strong> created by bats::array() with $BATS_TEST_DESCRIPTION.</p>
# </html>
export BATS_ARRAY=()

# Command Executed (variable set by: bats).
#
export BATS_COMMAND

# Bats Core executable path
#
export BATS_EXECUTABLE="$(brew --prefix bats-core)/bin/bats"

# <html><h2>Array with Bats Libs Functions and Helper Functions Provided by bats/bats.sh</h2>
# <p><strong><code>$BATS_FUNCTIONS</code></strong> created by bats::array() with $BATS_TEST_DESCRIPTION.</p>
# </html>
export BATS_FUNCTIONS=()

# Gather the output of failing *and* passing tests as files in directory (variable set by: bats).
#
export BATS_GATHER

# <html><h2>Saved $INFOPATH on First Suite Test Start</h2>
# <p><strong><code>$BATS_INFOPATH</code></strong></p>
# </html>
export BATS_INFOPATH="${INFOPATH}"

# <html><h2>Saved $MANPATH on First Suite Test Start</h2>
# <p><strong><code>$BATS_MANPATH</code></strong></p>
# </html>
export BATS_MANPATH="${MANPATH}"

# Directory to write report files (variable set by: bats).
#
export BATS_OUTPUT

# <html><h2>Saved $PATH on First Suite Test Start</h2>
# <p><strong><code>$BATS_PATH</code></strong></p>
# </html>
export BATS_PATH="${PATH}"

# Path to the test directory, passed as argument or found by 'bats' (variable set by: bats).
#
export BATS_TEST_DIR

# Array of tests found (variable set by: bats).
#
export BATS_TESTS

# <html><h2>Bats Remote and Local Repository Array</h2>
# <p><strong><code>$BATS_REMOTE</code></strong> created by bats::remote(), [0] repo, [1] remote.</p>
# </html>
export BATS_REMOTE=()

# <html><h2>Test File Basename Without Suffix .bats</h2>
# <p><strong><code>$BATS_TEST_BASENAME</code></strong> from $BATS_TEST_FILENAME.</p>
# </html>
export BATS_TEST_BASENAME="$(basename "${BATS_TEST_FILENAME-}" .bats)"

# Path to the test directory, passed as argument or found by 'bats' (variable set by: bats).
#
export BATS_TEST_DIR

# Array of tests found (variable set by: bats).
#
export BATS_TESTS

# <html><h2>Git Top Path</h2>
# <p><strong><code>$BATS_TOP</code></strong> contains the git top directory using $PWD.</p>
# </html>
export BATS_TOP="$(git rev-parse --show-toplevel 2>/dev/null || true)"

# <html><h2>Git Top Basename</h2>
# <p><strong><code>$BATS_TOP_NAME</code></strong> basename of git top directory when sourced from a git dir.</p>
# </html>
export BATS_BASENAME="${BATS_TOP##*/}"

export INFOPATH

export MANPATH

#######################################
# Restores $PATH to $BATS_PATH and sources .envrc.
# Globals:
#   PATH
# Arguments:
#  None
#######################################
bats::env() {
  bats::cd
  PATH="${BATS_PATH}"
  MANPATH="${BATS_MANPATH}"
  INFOPATH="${BATS_INFOPATH}"
  path_add_exist_all "${BATS_TOP}"
  # TODO: envfile
  #  . "$(dirname "${BASH_SOURCE[0]}")/envfile.sh"
  #  envfile
}

#######################################
# creates $BATS_ARRAY array from $BATS_TEST_DESCRIPTION or argument
# Globals:
#   BATS_ARRAY
#   BATS_TEST_DESCRIPTION
#######################################
# shellcheck disable=SC2086
bats::array() { mapfile -t BATS_ARRAY < <(xargs printf '%s\n' <<<${BATS_TEST_DESCRIPTION}); }

#######################################
# creates $BATS_ARRAY array from $BATS_TEST_DESCRIPTION or argument
# Globals:
#   BATS_ARRAY
#   BATS_TEST_DESCRIPTION
#######################################
bats::basename() { basename "${BATS_TEST_FILENAME-}" .bats; }

#######################################
# Changes to top repository path \$BATS_TOP and top path found, otherwise changes to the \$BATS_TESTS
# Globals:
#   BATS_ROOT
#   BATS_TESTS
#   BATS_TOP
#######################################
bats::cd() { cd "${BATS_TOP:-${BATS_TESTS:-.}}" || return; }

#######################################
# create a remote, a local temporary directory and change to local repository directory (no commits added)
# Globals:
#   BATS_REMOTE
# Arguments:
#  1  directory name (default: random name)
#######################################
bats::remote() {
  BATS_REMOTE=("$(bats::tmp "${1:-$RANDOM}")" "$(bats::tmp "${1:-$RANDOM}.git")")
  git -C "${BATS_REMOTE[1]}" init --bare --quiet
  cd "${BATS_REMOTE[0]}" || return
  git init --quiet
  git branch -M main
  git remote add origin "${BATS_REMOTE[1]}"
  git config branch.main.remote origin
  git config branch.main.merge refs/heads/main
  git config user.name "${BATS_BASENAME}"
  git config user.email "${BATS_BASENAME}@example.com"
}

#######################################
# run description array
# Globals:
#   BATS_ARRAY
# Arguments:
#  None
# Caution:
#  Do not se it with single quotes ('echo "1 2" 3 4'), use double quotes ("echo '1 2' 3 4")
#######################################
bats::run() {
  bats::array
  run "${BATS_ARRAY[@]}"
}

#######################################
# create a temporary directory in $BATS_FILE_TMPDIR if arg is provided
# Globals:
#   BATS_FILE_TMPDIR
# Arguments:
#  1  directory name (default: returns $BATS_FILE_TMPDIR)
# Outputs:
#  new temporary directory or $BATS_FILE_TMPDIR
#######################################
bats::tmp() {
  local tmp="${BATS_FILE_TMPDIR}${1:+/$1}"
  [ ! "${1-}" ] || mkdir -p "${tmp}"
  echo "${tmp}"
}

#######################################
# show error and exit 1
# Arguments:
#   * message
#######################################
_die() {
  echo >&2 "${0##*/}: ${*}"
  exit 1
}

#######################################
# find tests in directory "*.bats" and adds to BATS_TESTS
# Globals:
#   BATS_TESTS
# Arguments:
#   1 directory
#   2 message to exit if not found
# Returns:
#  1 if not tests found
#######################################
_directory() {
  local tests
  [ "$(realpath "$1")" != "$(realpath "${HOME}")" ] || _die "$1" "is home directory"
  mapfile -t tests < <(find "$(realpath "$1")" \( -type f -o -type l \) -name "*.bats")
  [ "${tests-}" ] || return
  BATS_TESTS+=("${tests[@]}")
}

#######################################
# checks if function is exported
# Globals:
#   FUNCNAME
# Arguments:
#   1   function name
# Returns:
#   1 if function is not exported,
#   0 if function is exported
#######################################
_exported() {
  if ! declare -Fp "$1" 2>/dev/null | grep -q "declare -fx ${1}" >/dev/null; then
    echo >&2 "${BASH_SOURCE[0]}: ${1}: function not exported"
    return 1
  fi
}

#######################################
# check if is file suffix is "*.bats" and adds to BATS_TESTS
# Globals:
#   BATS_TESTS
# Arguments:
#   1 file
# Returns:
#  1 invalid file
#######################################
_file() {
  [ "${1##*.}" = bats ] || return
  BATS_TESTS+=("$(realpath "$1")")
}

#######################################
# get functions in file/files
# Arguments:
#  None
#######################################
_functions() { awk -F '(' '/^[a-z].*\(\)/ && ! /=\(/ { print $1 }' "$@"; }

#######################################
# show help and exit
# Arguments:
#   None
#######################################
_help() {
  local rc=$? script="${0##*/}"
  local sh="${script/.sh/}.sh"
  [ ! "${1-}" ] || {
    echo -e "${0##*/}: ${1}: ${2}\n"
    rc=1
  }
  cat <<EOF
usage: ${script} [<tests>] [<options>]
   or: ${sh} [<tests>] [<options>]
   or: ${script} -h|-help|commands|help|functions|verbose
   or: ${sh} -h|-help|commands|help|functions|verbose
   or: . ${script}
   or: . ${sh}

bats testing wrapper and helper functions when "${script}" or "${sh}" sourced

<tests> is the path to a Bats test file, or the path to a directory containing Bats
test files (ending with ".bats"). If no <tests> run for: first directory found with ".bats"
files in working directory, or either 'tests', 'test' or '__tests__' under top repository path.

Changes to top repository path \$BATS_TOP when running tests and top path found, otherwise changes
to the \$BATS_TEST_DIR

Commands:
  -h, --help, help          display this help and exit
  commands                  display ${script}' commands
  functions                 display functions available when ${script} is sourced
  list                      display tests found relative to current working directory

Options:
  --dry-run                 show command that would be executed and globals
  --man                     show bats(1) man page
  --man7                    show bats(7) man page
  --one                     run only one job in parallel instead of \$BATS_NUMBER_OF_PARALLEL_JOBS
  --verbose                 run bats tests showing all outputs, with trace and not cleaning the tempdir

Bats options:
$(awk '/--count/,0' < <("${BATS_EXECUTABLE}" --help))

Globals:
   BATS_COMMAND             Command Executed.
   BATS_GATHER              Gather the output of failing *and* passing tests as
                            files in directory [--gather-test-outputs-in].
   BATS_OUTPUT              Directory to write report files [-o|--output].
   BATS_TEST_DIR            Path to the test directory, passed as argument or found by '${script}'.
   BATS_TESTS               Array of tests found.

$("${BATS_EXECUTABLE}" --version)
EOF
  exit $rc
}

#######################################
# bats libs
# Globals:
#   BASH_SOURCE
#   __brew_lib
#   i
# Arguments:
#  None
# Returns:
#   1 ...
#######################################
_libs() {
  local i
  __brew_lib="$(brew --prefix)/lib"
  for i in bats-assert bats-file bats-support; do
    if ! . "${__brew_lib}/${i}/load.bash"; then
      echo >&2 "${BASH_SOURCE[0]}: ${__brew_lib}/${i}/load.bash: sourcing error"
      return 1
    fi
  done
  unset i
}

#######################################
# parse arguments when is executed and run bats  (private used by bats.bash)
# Globals:
#   OPTS_BACK
# Arguments:
#   None
#######################################
_main() {
  # TODO: patch del formatter, envrc
  _libs
  mapfile -t BATS_FUNCTIONS < <(
    _functions "${__brew_lib}"/*/src/*.bash &&
    _functions "${BASH_SOURCE[0]}" &&
    awk -F '(' "/^$(basename "${BASH_SOURCE[0]}" .sh)::.*\(\)/ { gsub(/ /,\"\",\$1); print \$1 }" "${BASH_SOURCE[0]}"
  )
  # bashsupport disable=BP2001
  export -f "${BATS_FUNCTIONS[@]}" && _exported assert && _exported bats::env && bats::env
  unset -f _die _directory _file _functions _help _libs

  [ "${BASH_SOURCE##*/}" = "${0##*/}" ] || return
  return
  set -eu
  shopt -s inherit_errexit

  local outputs
  outputs="$(realpath "${BATS_TOP:-.}/.${0##*/}")"

  local directory
  local dry=false
  local gather_test_outputs_in=false
  local gather_dir=("${outputs}/test")
  local jobs=()
  local list=false
  local no_parallelize_across_files=()
  local no_parallelize_within_files=()
  local no_tempdir_cleanup=false
  local options=()
  local one=false
  local output=false
  local output_dir=("${outputs}/output")
  local print_output_on_failure=(--print-output-on-failure)
  local show_output_of_passing_tests=false
  local timing=false
  local trace=false
  local verbose=false
  local verbose_run=false

  while (($#)); do
    case "$1" in
      -h | --help | help) _help ;;
      --code-quote-style)
        options+=("$1" "$2")
        shift
        ;;
      -c | --count) options+=("$1") ;;
      -f | --filter)
        options+=("$1" "$2")
        shift
        ;;
      -F | --formatter)
        options+=("$1" "${2/bashpro/pretty}")
        shift
        ;;
      -d | --dry-run) dry=true ;;
      -j | --jobs)
        jobs=("$1" "$2")
        shift
        ;;
      --gather-test-outputs-in)
        gather_test_outputs_in=true
        gather_dir=("$(realpath "$2")")
        options+=("$1" "$2")
        shift
        ;;
      --man|--man7) man "$(brew --prefix bats-core)/share/man/${1}/bats.${1##*.}"; exit ;;
      --no-parallelize-across-files) no_parallelize_across_files=("$1") ;;
      --no-parallelize-within-files) no_parallelize_within_files=("$1") ;;
      --no-tempdir-cleanup)
        no_tempdir_cleanup=true
        options+=("$1")
        ;;
      --one) one=true ;;
      -p | --pretty) options+=("$1") ;;
      --report-formatter)
        options+=("$1" "$2")
        shift
        ;;
      -r | --recursive) : ;;
      -o | --output)
        output=true
        output_dir=("$(realpath "$2")")
        options+=("$1" "$2")
        shift
        ;;
      --print-output-on-failure) : ;;
      --show-output-of-passing-tests)
        show_output_of_passing_tests=true
        options+=("$1")
        ;;
      --tap) options+=("$1") ;;
      -T | --timing)
        timing=true
        options+=("$1")
        ;;
      -x | --trace)
        trace=true
        options+=("$1")
        ;;
      --verbose) verbose=true ;;
      --verbose-run)
        verbose_run=true
        options+=("$1")
        ;;
      -v | --version) options+=("$1") ;;
      commands)
        printf '%s\n' -h --help help "$1" functions list | sort
        exit
        ;;
      functions)
        printf '%s\n' "${BATS_FUNCTIONS[@]}" | sort
        exit
        ;;
      list) list=true ;;
      -*) _help "$1" "invalid option" ;;
      *)
        test -e "$1" || _help "$1" "no such file, directory or invalid command"
        test -d "$1" || { _file "$1" && shift && continue; } || _die "${1}:" "invalid .bats extension"
        _directory "$1" || _die "${1}:" "no .bats tests found in directory"
        ;;
    esac
    shift
  done

  [ "${jobs-}" ] || jobs=(--jobs "${BATS_NUMBER_OF_PARALLEL_JOBS:-1}")
  [ ! "${no_parallelize_across_files-}" ] || [ "${jobs[1]}" -ne 1 ] || jobs=(--jobs 2)
  [ ! "${no_parallelize_within_files-}" ] || [ "${jobs[1]}" -ne 1 ] || jobs=(--jobs 2)

  ! $one || {
    jobs=(--jobs 1)
    no_parallelize_across_files=()
    no_parallelize_within_files=()
  }

  if $verbose; then
    $gather_test_outputs_in || {
      gather_test_outputs_in=true
      options+=("--gather-test-outputs-in" "${gather_dir[@]}")
    }
    $no_tempdir_cleanup || options+=("--no-tempdir-cleanup")
    $output || {
      output=true
      options+=("--output" "${output_dir[@]}")
    }
    $show_output_of_passing_tests || options+=("--show-output-of-passing-tests")
    $timing || options+=("--timing")
    $trace || options+=("--trace")
    $verbose_run || options+=("--verbose-run")
  fi

  if ! $dry; then
    ! $gather_test_outputs_in || ! test -d "${gather_dir[@]}" || rm -rf "${gather_dir[@]}"
    ! $output || {
      rm -rf "${output_dir[@]}"
      mkdir -p "${output_dir[@]}"
    }
  fi

  if [ ! "${BATS_TESTS-}" ] && ! _directory "$(pwd)"; then
    if [ "${BATS_TOP-}" ]; then
      for i in __tests__ test test; do
        directory="${BATS_TOP}/${i}"
        ! test -d "${directory}" || _directory "${directory}" || true
      done
      [ "${BATS_TESTS-}" ] || _die "${BATS_TOP}/{__tests__,test,tests}: no .bats test found"
    else
      _die "${PWD}: not a git repository (or any of the parent directories)"
    fi
  fi

  local directories=()
  for i in "${BATS_TESTS[@]}"; do
    [ -d "${i}" ] || {
      directories+=("$(dirname "${i}")")
      continue
    }
    directories+=("${i}")
  done
  mapfile -t directories < <(printf '%s\n' "${directories[@]}" | sort -u)
  BATS_TEST_DIR="$(find "${directories[@]}" -mindepth 0 -maxdepth 0 -type d -print -quit)"

  local directory="${BATS_TESTS[0]}"
  for i in "${BATS_TESTS[@]}"; do
    directory="$(comm -12 <(tr "/" "\n" <<<"${i/\//}") \
      <(tr "/" "\n" <<<"${directory/\//}") | sed 's|^|/|g' | tr -d '\n')"
  done
  test -d "${directory}" || directory="$(dirname "${directory}")"

  local command=(
    "${BATS_EXECUTABLE}"
    "${jobs[@]}"
    "${no_parallelize_across_files[@]}"
    "${no_parallelize_within_files[@]}"
    "${print_output_on_failure[@]}"
    "${options[@]}"
    "${BATS_TESTS[@]}"
  )

  BATS_COMMAND="${command[*]}"
  BATS_GATHER="${gather_dir[*]}"
  BATS_OUTPUT="${output_dir[*]}"

  if $list; then
    printarr "${BATS_TESTS[@]}" | sed "s|$(pwd)/||"
  elif $dry; then
    echo BATS_GATHER="${BATS_GATHER}" BATS_OUTPUT="${BATS_OUTPUT}" BATS_TEST_DIR="${directory}" "${command[@]}"
  else
    BATS_TEST_DIR="${directory}" "${command[@]}"
  fi

  if $verbose; then
    echo >&2 BATS_GATHER: "${gather_dir[*]}"
    echo >&2 BATS_OUTPUT: "${output_dir[*]}"
  fi
}

_main "$@"
