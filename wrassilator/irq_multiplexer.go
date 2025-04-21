package main

import (
	sim6502 "github.com/nojan1/sim6502/pkg"
)

type IRQSource = uint8

const (
	SystemViaIRQSource IRQSource = iota
	UserViaIRQSource
	GpuFrameIRQSource
)

type IRQMultiplexer struct {
	proc *sim6502.Processor
	sources [256]bool
}

func (s *IRQMultiplexer) SetInterupt(source IRQSource) {
	s.sources[source] = true
	s.setProcIRQ()
}

func (s *IRQMultiplexer) ClearInterupt(source IRQSource) {
	s.sources[source] = false
	s.setProcIRQ()
}

func (s *IRQMultiplexer) setProcIRQ() {
	active := false

	for _, v := range s.sources {
		active = active || v
	}

	s.proc.IRQ(active)
}