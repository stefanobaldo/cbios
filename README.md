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

Mirror only, for now. `master` tracks upstream unchanged; this branch, `main`,
carries this file and will carry the patch, its tests and the release workflow.
Nothing has been released yet.

## Branches

| Branch | Content |
|---|---|
| `master` | Pristine mirror of upstream `git.code.sf.net/p/cbios/cbios` (`master`). Never receives commits of its own; synced by fast-forward. |
| `main` | Upstream plus the changes made here. Default branch. |

## Building

Upstream's instructions in `doc/building.txt` hold: the only assembler that
builds the source unmodified is [Pasmo](http://pasmo.speccy.org/) 0.5.3, and
`make` produces the ROM files under `derived/bin/`. Pasmo is packaged on Debian
and Ubuntu.

## License

C-BIOS is distributed under a two-clause BSD license; the full text and the
copyright holders are in `doc/cbios.txt`. Changes made in this repository are
contributed under the same terms.

## Upstream

- Project site: http://cbios.sourceforge.net/
- Source: `git clone https://git.code.sf.net/p/cbios/cbios`
- Bug tracker and feature requests are on the SourceForge project page.
