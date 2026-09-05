#!/bin/sh
# Print the release notes for a tag. Usage: tools/release-notes.sh <tag>
set -eu
tag=${1:?usage: tools/release-notes.sh <tag>}
cat <<NOTES
C-BIOS $(cat version.txt) with the KEYROW routine at 0D89h, which lets Nextor boot.

The ROMs are built from the sources at this tag with pasmo 0.5.3. The ROM
banner still reads "C-BIOS 0.29": the sha1 in SHA1SUMS is what identifies a
patched ROM.

Tested by booting the Nextor 2.1.4 Sunrise IDE kernel (NEXTOR.SYS 2.1.3,
COMMAND2.COM 2.1.0) to the DOS prompt on cbios_main_msx2.rom in openMSX 21.0,
headless, in GitHub Actions.

Files:
- cbios_*.rom: every ROM C-BIOS builds; only cbios_main_msx2.rom carries a change
  relevant to Nextor today, the others are rebuilt from the same tree.
- SHA1SUMS: sha1 of every ROM.
- C-BIOS_MSX2_Nextor.xml: an openMSX machine configuration that selects these
  ROMs by sha1. Put it in share/machines and the ROMs in share/systemroms of
  your openMSX user directory, then start with -machine C-BIOS_MSX2_Nextor.

Tag: $tag
NOTES
