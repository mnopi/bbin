#!/usr/bin/env bats

setup() {
  . paths.sh
}

@test "path_in /bin MANPATH " {
  run true
  [ "$status" -eq 0 ]
}
