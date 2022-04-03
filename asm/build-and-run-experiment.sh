#!/bin/bash

if [ -z "$1" ]; then
    echo "Enter filename"; exit 1
fi

export sourcefile=experiments/$1.s

if [ ! -f "$sourcefile" ]; then 
    echo "No such file $sourcefile"; exit 1
fi

vasm6502_oldstyle -wdc02 -dotdir -Fbin -L experiment.list -o experiment.bin $sourcefile
6502-simulator -f experiment.bin -l experiment.list $2