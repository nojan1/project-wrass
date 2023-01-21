#!/bin/sh

apio raw 'yosys -p "synth_ice40 -json hardware.json" bus_interface.v clock_divider.v gpu.v memory.v pixel_generator.v sync_generator.v'
apio raw 'nextpnr-ice40 --hx1k --package vq100 --json hardware.json --asc hardware.asc --pcf ice40-io-video.pcf --pre-pack setclock.py'
