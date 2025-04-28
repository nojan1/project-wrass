package main

import (
	"fmt"
	"strconv"
	"strings"

	sim6502 "github.com/nojan1/sim6502/pkg"
)

type Breakpoint struct {
	address uint16
	enabled bool
}

type UserBreakpointHandler struct {
	simulatorState *SimulatorState
	proc *sim6502.Processor
	breakpoints []Breakpoint
}

func (s *UserBreakpointHandler) Prepare(breakpointString string) {
	s.breakpoints = make([]Breakpoint, 0)

	for _, breakpoint := range strings.Split(breakpointString, ",") {
		if addr, ok := strconv.ParseUint(breakpoint, 16, 16); ok == nil {
			s.breakpoints = append(s.breakpoints, Breakpoint { address: uint16(addr), enabled: true })

			fmt.Printf("Breakpoint will be set at $%04X \n", addr)
		} 
	}

	s.setAllBreakpoints()
}

func (b *UserBreakpointHandler) HandleBreak(proc *sim6502.Processor) error {
	proc.Stop()
	proc.ClearBreakpoints()
	b.simulatorState.inBreakpoint = true
	b.simulatorState.isRunning = false

	return nil
}

func (b *UserBreakpointHandler) StepOutOfBreakStateIfNeeded() bool {
	if !b.simulatorState.inBreakpoint {
		return false
	}

	b.proc.ClearBreakpoints()
	b.proc.Step()

	b.setAllBreakpoints()

	return true
}

func (b *UserBreakpointHandler) setAllBreakpoints() {
	b.proc.ClearBreakpoints()

	for _, breakpoint := range b.breakpoints {
		if breakpoint.enabled {
			b.proc.SetBreakpoint(breakpoint.address, b)
		}
	}
}