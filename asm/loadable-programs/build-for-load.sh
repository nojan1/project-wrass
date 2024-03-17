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
checksum=$(echo -n $program | perl -e 'while(<>) { my $checksum = 0; $checksum ^= $_ for unpack("(h2)*"); printf "\U%x", $checksum; }')

echo "load 0400 $checksum"
echo -n $program
echo ""
echo -n "jump 0400"