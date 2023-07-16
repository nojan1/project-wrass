#!/bin/bash

ARGS="-dotdir -wdc02 -Fbin -DNO_LCD"
COMPILER="vasm6502_oldstyle"

if [[ -z "$1" || -z "$2" ]]; then
  echo "Usage: build.sh <output> <input> [listing]"
  exit 1
fi

if [ -z "$3" ]; then
  LISTING=""
else
  LISTING="-L $3"
fi

exec $COMPILER $ARGS $LISTING -o $1 $2

