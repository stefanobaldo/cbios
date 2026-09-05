#!/bin/sh
# Download the pinned Nextor files into $1 (default derived/test/cache) and
# verify their checksums. Safe to run repeatedly; existing verified files are
# kept.
set -eu
cache=${1:-derived/test/cache}
mkdir -p "$cache"

fetch() { # url sha256 target
    if [ ! -f "$3" ]; then
        curl -fsSL -o "$3.part" "$1" && mv "$3.part" "$3"
    fi
    echo "$2  $3" | shasum -a 256 -c - >/dev/null || {
        echo "fetch: checksum mismatch for $3" >&2; rm -f "$3"; exit 2; }
}

fetch https://github.com/Konamiman/Nextor/releases/download/v2.1.4/Nextor-2.1.4.SunriseIDE.ROM \
      4eafcd3a4918da7da98559b2b598d430521d35857f1bf0d2ba6619f8e71c05b2 "$cache/Nextor-2.1.4.SunriseIDE.ROM"
fetch https://github.com/Konamiman/Nextor/releases/download/v2.1.3/NEXTOR.SYS \
      3db8c8094bd5d3df4197b2f6606d4e28fb5a2462086f72ce8b6664d12a94bde7 "$cache/NEXTOR.SYS"
fetch https://github.com/Konamiman/Nextor/releases/download/v2.1.0/tools.zip \
      5792ff3fe7ab684b8afd405cdd898e25f6efdb84ca1f2cb9ac1428cc848d924e "$cache/tools.zip"
if [ ! -f "$cache/COMMAND2.COM" ]; then
    unzip -o -q -j "$cache/tools.zip" COMMAND2.COM -d "$cache"
fi
echo "1bb7860631cd6257fefdbd996640bd345d7eab931758e7dc2725cdb02072067c  $cache/COMMAND2.COM" \
    | shasum -a 256 -c - >/dev/null || { echo "fetch: COMMAND2.COM checksum mismatch" >&2; exit 2; }
echo "fetch: Nextor 2.1.4 kernel ROM, NEXTOR.SYS 2.1.3, COMMAND2.COM 2.1.0 ready in $cache"
