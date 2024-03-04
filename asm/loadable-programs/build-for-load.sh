#!/bin/bash

ARGS="-dotdir -wdc02 -Fbin -DNO_LCD"
COMPILER="vasm6502_oldstyle"

if [[ -z "$1" ]]; then
  echo "Usage: $0 <input>"
  exit 1
fi

$COMPILER $ARGS -L a.list -o a.out $1 >&2

echo "load 0400"
hexdump -ve '1/1 "%.2x"' a.out
echo ""
echo -n "jump 0400"