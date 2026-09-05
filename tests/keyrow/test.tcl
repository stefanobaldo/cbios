# Unit test for the routine at $0D89 (KEYROW): call it from a tiny program in
# RAM with a key mask and a row counter, then check what reached KEYBUF.
set throttle off
set mute on
after realtime 60 { puts stderr "FAIL: real-time deadline (the routine probably crashed the machine)"; exit 2 }

set PUTPNT  0xF3F8
set NEWKEY6 0xFBEB      ;# NEWKEY + 6: modifier row, bit 0 clear = SHIFT held

# Row 11 - 7 = 4 of scode_tbl is "klmnopqr", so bit 6 of the mask is "q";
# row 11 - 2 = 9 of scode_tbl_otherkeys is "*+/01234", so bit 0 is "*".
# name  mask  rowcounter  newkey6  expected-byte ("" = nothing stored)
set cases {
    {plain-q      0x40 7 0xFF 0x71}
    {shift-Q      0x40 7 0xFE 0x51}
    {keypad-star  0x01 2 0xFF 0x2A}
    {no-key       0x00 7 0xFF ""}
}
set failures 0

proc run_case {name mask row nk6 expected} {
    poke $::NEWKEY6 $nk6
    set put0 [peek16 $::PUTPNT]
    # C000: ld a,mask / ld b,row / call $0D89 / C007: halt / jr C007
    set code [list 0x3E $mask 0x06 $row 0xCD 0x89 0x0D 0x76 0x18 0xFD]
    set addr 0xC000
    foreach byte $code { poke $addr $byte; incr addr }
    debug set_bp 0xC007 {} [list case_done $name $expected $put0]
    reg SP 0xF380
    reg PC 0xC000
}

proc case_done {name expected put0} {
    debug remove_bp [lindex [debug list_bp] 0]
    set put1 [peek16 $::PUTPNT]
    if {$expected eq ""} {
        if {$put1 == $put0} {
            puts stderr "ok   $name: nothing stored"
        } else {
            puts stderr "FAIL $name: PUTPNT moved from [format %04X $put0] to [format %04X $put1]"
            incr ::failures
        }
    } else {
        set got [peek $put0]
        if {$put1 == $put0 + 1 && $got == $expected} {
            puts stderr "ok   $name: stored [format %02X $got]"
        } else {
            puts stderr "FAIL $name: expected [format %02X $expected] at [format %04X $put0], got [format %02X $got], PUTPNT now [format %04X $put1]"
            incr ::failures
        }
    }
    after time 0.05 next_case
}

proc next_case {} {
    # openMSX's Tcl `exit` does not unwind the script: it schedules the quit
    # and execution carries on, so every exit here is followed by a return.
    if {[llength $::cases] == 0} {
        if {$::failures == 0} {
            puts stderr "PASS: keyrow"
            exit 0
        } else {
            puts stderr "FAIL: $::failures case(s) failed"
            exit 1
        }
        return
    }
    set c [lindex $::cases 0]
    set ::cases [lrange $::cases 1 end]
    run_case {*}$c
}

# Let C-BIOS finish its own boot before taking over the CPU.
after time 3 next_case
