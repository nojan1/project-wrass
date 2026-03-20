#!/usr/bin/env bash

binaryPath=$(mktemp -t kernel-binary.XXX)
listingPath=$(mktemp -t kernel-listing.XXX)

asm/build.sh "$binaryPath" asm/kernel/kernel.s "$listingPath"
[ $? -ne 0 ] && echo "Build failed!" && exit 1

printf "Binary:\n%s\n" $binaryPath
printf "Listing:\n%s\n" $listingPath

if [ -z "$1" ]; then
  cd wrassilator && go run . -file "$binaryPath" # -listing "$listingPath"
else
  prgRes=$(asm/loadable-programs/build-for-load.sh $1)
  [ $? -ne 0 ] && exit 1

  cd wrassilator && go run . -file "$binaryPath" <<<"$prgRes"
fi
