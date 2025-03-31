package main

import (
	sim6502 "github.com/nojan1/sim6502/pkg"
)

type Keyboard struct {
	bufferedKey int32
	readCycle int
}

func (s *Keyboard) HasKey() bool {
	return s.bufferedKey != 0
}

func (s *Keyboard) GetKey() int32 {
	return s.bufferedKey
}

func (s *Keyboard) StoreKey(key int32, proc *sim6502.Processor) {
	s.bufferedKey = KeycodeFromRlKey(key)
	s.readCycle = 3
	proc.IRQ(true)
}

func (s *Keyboard) readPort() (val uint8, requestIRG bool) {
	if s.HasKey() {
		s.readCycle--
		switch s.readCycle {
		case 2:
			return uint8(s.bufferedKey), true
		case 1:
			return 0xF0, true
		case 0:
			backup := s.bufferedKey
			s.bufferedKey = 0
			return uint8(backup), false
		}
	}

	return 0, false
}