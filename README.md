# C-BIOS

A mirror of [C-BIOS](http://cbios.sourceforge.net/), the open-source
replacement BIOS for MSX computers, kept here so that it can be built, tested
and extended in the open.

## Why this repository exists

C-BIOS is the BIOS that MSX emulators such as [openMSX](https://openmsx.org/)
ship with, because the original manufacturer ROMs cannot be redistributed. It
runs cartridge software well, but it was never meant to host a disk operating
system, and it cannot boot [Nextor](https://github.com/Konamiman/Nextor) as
shipped: Nextor's kernel calls an internal, undocumented routine of the
Microsoft MSX BIOS at address `0D89h` during boot, and in C-BIOS that address
falls in the middle of unrelated code. The consequence is that no MSX software
that depends on Nextor can run in an emulator without a proprietary BIOS, which
in practice rules out headless, automated testing in public CI.

The gap is small. With that one routine supplied, Nextor boots on unmodified
C-BIOS 0.29 to the DOS prompt, with the Sunrise IDE driver initialised. The goal
of this repository is to carry that change, as a patch on top of upstream that
keeps C-BIOS's fixed entry points intact, and to publish ROM files that
projects can pin by checksum and use from an emulator in CI.

The first user is [m6os](https://github.com/stefanobaldo/m6os), whose test
harness boots Nextor in a headless openMSX on every commit.

## Status

`main` carries the KEYROW routine at `0D89h`, a test suite that boots Nextor on
the built ROM in headless openMSX, CI on every change, and a release workflow.
`master` tracks upstream unchanged. Releases are listed on the
[releases page](https://github.com/stefanobaldo/cbios/releases).

## Branches

| Branch | Content |
|---|---|
| `master` | Pristine mirror of upstream `git.code.sf.net/p/cbios/cbios` (`master`). Never receives commits of its own; synced by fast-forward. |
| `main` | Upstream plus the changes made here. Default branch. |

## Download

Every release `v0.29-nextor.N` carries all the ROMs C-BIOS builds, a `SHA1SUMS`
file and `C-BIOS_MSX2_Nextor.xml`, an openMSX machine configuration that
selects those ROMs by sha1. Only `cbios_main_msx2.rom` differs from upstream in
a way Nextor notices; the others are rebuilt from the same tree.

The ROM banner still reads "C-BIOS 0.29" — the title string is length-sensitive
on a 32-column screen — so the sha1 is what tells a patched ROM from upstream's.

## Using with openMSX

openMSX finds ROMs by sha1, and its stock `C-BIOS_MSX2` machine asks for
upstream's sha1: dropping a patched ROM into the ROM pool changes nothing. Use
the machine configuration shipped with the release instead:

1. Copy `C-BIOS_MSX2_Nextor.xml` to `share/machines/` in your openMSX user
   directory (`~/.openMSX/share/machines/` on Linux and macOS).
2. Copy `cbios_main_msx2.rom`, `cbios_logo_msx2.rom` and `cbios_sub.rom` to
   `share/systemroms/` there.
3. Start with `openmsx -machine C-BIOS_MSX2_Nextor`, plus your Nextor cartridge
   extension and disk image, for example
   `-ext SunriseIDE_Nextor -hda disk.dsk`.

For automated use, `OPENMSX_USER_DATA=<dir>` makes openMSX read `machines/`,
`extensions/` and `systemroms/` from any directory, which is how the tests in
this repository run without touching `~/.openMSX`.

## What changed from upstream

One routine, entered at address `0D89h` in `src/main.asm` (the address holds a
jump; the routine itself sits further down, past the font table). In the Microsoft MSX
BIOS that address is the tail of the keyboard interrupt: given a bit mask of
newly pressed keys in `A` and the row counter in `B`, it decodes the keys and
appends their characters to the keyboard buffer. It is undocumented, and
Nextor's kernel calls it directly during boot to probe for a Russian keyboard
layout (`CHECK_IS_RUSSIAN` in `source/kernel/bank0/init.mac`). In upstream
C-BIOS that address falls inside the RAM-search boot code, so the call derails
the machine before the disk system initialises.

The routine added here honours the same contract using C-BIOS's own scancode
tables and its `key_store` routine, which became a callable subroutine in the
process. A build-time check fails the assembly if the entry point ever moves off
`0D89h`, and a second one guards the font table it now sits in front of. CAPS lock and the GRAPH/CODE modifiers are ignored, as C-BIOS's own
keyboard scanning ignores them.

Proposing the change to upstream C-BIOS on SourceForge is future work.

## Tests

`make test` builds the ROMs and runs every test under `tests/` in headless
openMSX 21.0: a boot smoke test, a unit test that calls the routine at `0D89h`
through the debugger and checks the keyboard buffer, and an integration test
that boots Nextor 2.1.4 to the `A:\>` prompt. The Nextor files are downloaded
from their official releases, pinned by checksum.

## Building

Upstream's instructions in `doc/building.txt` hold: the only assembler that
builds the source unmodified is [Pasmo](http://pasmo.speccy.org/) 0.5.3, and
`make` produces the ROM files under `derived/bin/`. Pasmo is packaged on Debian
and Ubuntu; on macOS it is built from source
(`http://pasmo.speccy.org/bin/pasmo-0.5.3.tgz`), and `make` is then told where
it went with `make PASMO=/path/to/pasmo`.

## License

C-BIOS is distributed under a two-clause BSD license; the full text and the
copyright holders are in `doc/cbios.txt`. Changes made in this repository are
contributed under the same terms.

## Upstream

- Project site: http://cbios.sourceforge.net/
- Source: `git clone https://git.code.sf.net/p/cbios/cbios`
- Bug tracker and feature requests are on the SourceForge project page.
