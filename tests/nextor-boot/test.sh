#!/bin/sh
set -eu
. "$(dirname "$0")/../lib.sh"
prepare_userdata nextor-boot

cache="$ROOT/derived/test/cache"
sh "$TEST_DIR/fetch.sh" "$cache"
cp "$cache/Nextor-2.1.4.SunriseIDE.ROM" "$UD/systemroms/"

mkdir -p "$WORK/staging"
cp "$cache/NEXTOR.SYS" "$cache/COMMAND2.COM" "$WORK/staging/"
export CBIOS_TEST_WORK="$WORK"

run_openmsx -script "$TEST_DIR/mkdisk.tcl"
run_openmsx -ext SunriseIDE_Nextor_2.1.4 -hda "$WORK/disk.dsk" -script "$TEST_DIR/import.tcl"
run_openmsx -ext SunriseIDE_Nextor_2.1.4 -hda "$WORK/disk.dsk" -script "$TEST_DIR/test.tcl"
