# Smoke test: the freshly built C-BIOS MSX2 ROM boots to its banner.
# get_screen throws while the boot logo is up (screen 5 is not a text mode),
# so the poll catches the error and simply tries again.
set throttle off
set mute on
after realtime 60 { puts stderr "FAIL: no banner within the real-time deadline"; exit 2 }
proc look {} {
    if {![catch {get_screen} screen]} {
        if {[string first "C-BIOS 0.29" $screen] >= 0} {
            puts stderr "PASS: C-BIOS banner on screen"
            exit 0
        }
    }
    after time 0.5 look
}
after time 1 look
