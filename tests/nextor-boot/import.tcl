# Populate the image from the staging directory.
set throttle off
set mute on
set staging [file join $::env(CBIOS_TEST_WORK) staging]
if {[catch {diskmanipulator import hda $staging} err]} {
    puts stderr "FAIL: diskmanipulator import: $err"
    exit 1
    return
}
puts stderr "image contents:\n[diskmanipulator dir hda]"
exit 0
