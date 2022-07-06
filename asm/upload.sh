#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: upload.sh <imagefile>"
  exit 1
fi

if [[ ! -f "$1" ]]; then 
  echo "File not found $1"
  exit 1
fi

SIZE=$(wc -c $1 | cut -d " " -f 4)
if [[ SIZE -eq 16384 ]]; then
  cat "$1" "$1" > "$1.tmp"
else
  cp "$1" "$1.tmp"
fi

minipro -p AT28C256 -w "$1.tmp"
rm "$1.tmp"
