#!/usr/bin/env bash

load './node_modules/bats-support/load'
load './node_modules/bats-assert/load'

# shellcheck disable=SC1090
source "$BATS_TEST_DIRNAME/emptyshell.sh"

# N=42 bats test.bats       // run individual test by index
# R=pattern bats test.bats  // run only tests whose descriptions match pattern
function setup() {
	if [[ -n "${N:-}" ]]; then
		if (( BATS_TEST_NUMBER != N )); then
			skip
		fi
	fi
	if [[ -n "${R:-}" ]]; then
		if ! [[ "${BATS_TEST_DESCRIPTION}" =~ ${R} ]]; then
			skip
		fi
	fi
}

@test "regurgitates args" {
	run emptyshell -a -b -c -d
	assert_output "-a -b -c -d"
}
