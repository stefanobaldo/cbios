#!/bin/sh
set -eu
. "$(dirname "$0")/../lib.sh"
prepare_userdata keyrow
run_openmsx -script "$TEST_DIR/test.tcl"
