#!/usr/bin/env bats
load './node_modules/bats-support/load'
load './node_modules/bats-assert/load'

@test "usage" {
  source rerun.sh
  run rerun --help 2>&1
  assert_output --partial "Default usage:"
}

@test "invalid option" {
  source rerun.sh
  run rerun --invalid-option 2>&1
  assert_output --partial "Unknown arguments: --invalid-option"
  assert_output --partial "Default usage:"
}
