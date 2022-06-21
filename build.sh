#!/bin/bash

cd asm

BUILD="$1"
LISTING="$2"
OUTPUT="$3"

vasm6502_oldstyle -DGRAPHICOUTPUT -Fbin -dotdir -wdc02 -L $LISTING -o $OUTPUT $BUILD
