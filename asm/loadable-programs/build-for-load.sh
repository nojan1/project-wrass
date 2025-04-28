#!/bin/bash

ARGS="-dotdir -wdc02 -Fbin -DNO_LCD"
COMPILER="vasm6502_oldstyle"

if [[ -z "$1" ]]; then
  echo "Usage: $0 <input>"
  exit 1
fi

$COMPILER $ARGS -L a.list -o a.out $@ >&2
[[ $? != 0 ]] && exit $?

program=$(hexdump -ve '1/1 "%.2x"' a.out)
# checksum=$(echo -n $program | perl -e 'while(<>) { my $checksum = 0; $checksum ^= $_ for unpack("(h2)*"); printf "\U%x", $checksum; }')
checksum=$(echo $program | node -e 'const fs=require("fs"); console.log(fs.readFileSync(0, "utf8").match(/[0-9a-z]{2}/g).reduce((acc,cur) => acc ^ parseInt(cur, 16), 0).toString(16).padStart(2,"0"));')

echo "load 0400 $checksum"
echo -n $program
echo ""
echo "jump 0400"