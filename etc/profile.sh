# shellcheck shell=sh

# Bbin Prefix
#
# TODO: lo hago en bbin y eval.

BBIN_PREFIX="$(bbin prefix)"; export BBIN_PREFIX
BBIN_DEVELOPMENT=""
HOMEBREW_PREFIX="${BBIN_PREFIX}" # only if dependencies met? or always?

