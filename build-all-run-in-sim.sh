#!/usr/bin/env bash

binaryPath=$(mktemp -t kernel-binary)
listingPath=$(mktemp -t kernel-listing)

asm/build.sh "$binaryPath" asm/kernel/kernel.s "$listingPath"
[ $? -ne 0 ] && echo "Build failed!" && exit 1

printf "Binary:\n%s\n" $binaryPath
printf "Listing:\n%s\n" $listingPath

cd wrassilator && go run . -file "$binaryPath" # -listing "$listingPath"
