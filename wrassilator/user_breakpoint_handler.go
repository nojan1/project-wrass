package main

import (
	sim6502 "github.com/nojan1/sim6502/pkg"
)

type UserBreakpointHandler struct {
	simulatorState *SimulatorState
}

func (b *UserBreakpointHandler) HandleBreak(proc *sim6502.Processor) error {
	proc.Stop()
	proc.ClearBreakpoints()
	b.simulatorState.isRunning = false

	return nil
}