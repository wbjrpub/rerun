#!/usr/bin/env bash

# sanity - exit on any error; no unbound variables
set -euo pipefail

function emptyshell() {
	# script arguments:
	local args=( "$@" )

	echo "${args[@]}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	emptyshell "$@"
fi
