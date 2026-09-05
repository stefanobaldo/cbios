# Create the boot image: one size means one unpartitioned FAT volume.
set throttle off
set mute on
set img [file join $::env(CBIOS_TEST_WORK) disk.dsk]
file delete -force $img
if {[catch {diskmanipulator create $img 16M} err]} {
    puts stderr "FAIL: diskmanipulator create: $err"
    exit 1
    return
}
exit 0
