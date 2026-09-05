# Shared helpers for the tests. Source this file, then call prepare_userdata
# and run_openmsx. Requires derived/bin to be built and `openmsx` (21.0) on
# PATH, or $OPENMSX pointing at the binary.

prepare_userdata() {
    TEST_NAME=$1
    ROOT=$(cd "$(dirname "$0")/../.." && pwd)
    TEST_DIR="$ROOT/tests/$TEST_NAME"
    WORK="$ROOT/derived/test/$TEST_NAME"
    UD="$WORK/userdata"
    OPENMSX=${OPENMSX:-openmsx}

    rm -rf "$WORK"
    mkdir -p "$UD/machines" "$UD/extensions" "$UD/systemroms"

    for rom in cbios_main_msx2 cbios_logo_msx2 cbios_sub; do
        [ -f "$ROOT/derived/bin/$rom.rom" ] || { echo "tests: $rom.rom not built, run make first" >&2; exit 2; }
        cp "$ROOT/derived/bin/$rom.rom" "$UD/systemroms/"
    done

    # The machine XML references the ROMs just built, by sha1, through the
    # same substitution `make dist` uses for the shipped configs.
    ( cd "$ROOT" && shasum -a 1 derived/bin/cbios_main_msx2.rom \
                                 derived/bin/cbios_logo_msx2.rom \
                                 derived/bin/cbios_sub.rom \
        | sed -nf tools/subst_sha1.sed ) > "$WORK/sha1.sed"
    sed -f "$WORK/sha1.sed" "$ROOT/configs/openMSX/C-BIOS_MSX2.xml" \
        > "$UD/machines/C-BIOS_MSX2_Nextor.xml"
    grep -q '<sha1>' "$UD/machines/C-BIOS_MSX2_Nextor.xml" \
        || { echo "tests: sha1 substitution produced no <sha1> element" >&2; exit 2; }

    if [ -d "$TEST_DIR/extensions" ]; then
        cp "$TEST_DIR"/extensions/*.xml "$UD/extensions/"
    fi
    export ROOT TEST_DIR WORK UD OPENMSX
}

run_openmsx() {
    OPENMSX_USER_DATA="$UD" "$OPENMSX" \
        -machine C-BIOS_MSX2_Nextor \
        -setting "$ROOT/tests/openmsx/settings.xml" \
        -command "set renderer none" \
        "$@"
}
