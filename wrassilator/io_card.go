package main

import (
	sim6502 "github.com/nojan1/sim6502/pkg"
)

type IoCard struct {
	keyboard *Keyboard
	userVia *W65C22
	systemVia *W65C22
}

func NewIoCard(proc *sim6502.Processor) *IoCard {
	keyboard := &Keyboard{}

	return &IoCard{
		keyboard: keyboard,
		userVia: &W65C22{
			proc: proc,
		},
		systemVia: &W65C22{
			proc: proc,
			portBReadHandler: keyboard,
		},
	}
}

func (s *IoCard) Write(addr uint16, val uint8) {
	if addr & 0x10 != 0 {
		s.systemVia.Write(uint8(addr), val)
	} else {
		s.userVia.Write(uint8(addr), val)
	}	
}

func (s *IoCard) Read(addr uint16, internal bool) uint8 {
	if internal {
		return 0
	}

	if addr & 0x10 != 0 {
		return s.systemVia.Read(uint8(addr))
	} else {
		return s.userVia.Read(uint8(addr))
	}
}


type W65C22PortReadHandler interface {
	readPort() (val uint8, requestIRG bool)
}

type W65C22PortWriteHandler interface {
	writePort(val uint8)
}

type W65C22 struct {
	proc *sim6502.Processor
	ddrA uint8
	ddrB uint8
	portAReadHandler W65C22PortReadHandler
	portBReadHandler W65C22PortReadHandler
	portAWriteHandler W65C22PortWriteHandler
	portBWriteHandler W65C22PortWriteHandler
}

type W65C22Register uint8

const (
	PORTB W65C22Register = iota
	PORTA
	DDRB
	DDRA
)

func (s *W65C22) Write(addr uint8, val uint8) {
	register := W65C22Register(addr)
	switch register {
	case PORTB:
		if s.portBWriteHandler != nil {
			s.portBWriteHandler.writePort(val & s.ddrB)
		}
	case PORTA:
		if s.portAWriteHandler != nil {
			s.portAWriteHandler.writePort(val & s.ddrA)
		}
	case DDRB:
		s.ddrB = val
	case DDRA:
		s.ddrA = val
	}
}

func (s *W65C22) Read(addr uint8) uint8{
	// TODO: IRQ from port is actually conditional and is controlled by registers.
	// update this function at some point
	
	register := W65C22Register(addr & 0xF)
	switch register {
	case PORTB:
		if s.portBReadHandler != nil {
			data, holdIRQ := s.portBReadHandler.readPort()
			s.proc.IRQ(holdIRQ)
			return data
		}
	case PORTA:
		if s.portAReadHandler != nil {
			data, holdIRQ := s.portAReadHandler.readPort()
			s.proc.IRQ(holdIRQ)
			return data
		}
	case DDRB:
		return s.ddrB
	case DDRA:
		return s.ddrA
	}

	return 0
}