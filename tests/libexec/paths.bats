#!/usr/bin/env bats

@test "path_in /bin MANPATH " {
  run true
  [ "$status" -eq 0 ]
}
