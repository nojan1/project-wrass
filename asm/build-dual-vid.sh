#!/bin/bash

if [[ -z "$1" || -z "$2" ]]; then
  echo "Usage: build-dual-vid.sh <output> <input>"
  exit 1
fi

ARGS="-dotdir -wdc02 -Fbin"
COMPILER="vasm6502_oldstyle"

$COMPILER $ARGS -o .out-lcd.bin $2
$COMPILER $ARGS -DGRAPHIC_OUTPUT -o .out-gfx.bin $2

cat .out-lcd.bin .out-gfx.bin > $1
rm .out-lcd.bin .out-gfx.bin