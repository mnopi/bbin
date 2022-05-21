#!/usr/bin/env bats

setup() {
  . path.sh
}

@test "path_in /bin MANPATH " {
  run true
  [ "$status" -eq 0 ]
}
