# Integration test: Nextor boots to the DOS prompt on the built C-BIOS ROM.
# get_screen throws while the machine is in a graphical mode, so the poll
# catches the error and tries again. openMSX's Tcl `exit` does not unwind the
# script, so every exit is followed by a return.
set throttle off
set mute on
after realtime 60 {
    if {[catch {get_screen} screen]} { set screen "(not a text mode: $screen)" }
    puts stderr "FAIL: no prompt within the real-time deadline; screen was:\n$screen"
    exit 1
    return
}
proc look {} {
    if {![catch {get_screen} screen]} {
        if {[string first "A:\\>" $screen] >= 0} {
            puts stderr "PASS: Nextor booted to the prompt; screen:\n$screen"
            exit 0
            return
        }
    }
    after time 0.5 look
}
after time 2 look
