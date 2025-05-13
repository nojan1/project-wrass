#!/usr/bin/env bash

infile="$1"
outfile="$2"

[[ -z "$infile" || -z "$outfile" ]] && echo "Usage: $0 <infile> <outfile>" && exit 1

# magick "$infile" +dither -colors 16 -depth 8 "$outfile"
magick "$infile" -colors 16 -depth 8 "$outfile"