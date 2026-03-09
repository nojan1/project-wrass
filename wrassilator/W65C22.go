package main

type W65C22Register uint8

const (
	PORTB W65C22Register = iota
	PORTA
	DDRB
	DDRA
)

type W65C22PortReadHandler interface {
	readPort(port W65C22Register) (val uint8, requestIRQ bool)
}

type W65C22PortWriteHandler interface {
	writePort(val uint8, port W65C22Register)
}

type W65C22 struct {
	irqMultiplexer *IRQMultiplexer
	irqSource      IRQSource

	ddrA             uint8
	ddrB             uint8
	portReadHandler  W65C22PortReadHandler
	portWriteHandler W65C22PortWriteHandler
}

func (s *W65C22) Write(addr uint8, val uint8) {
	register := W65C22Register(addr & 0xF)
	switch register {
	case PORTB:
		if s.portWriteHandler != nil {
			s.portWriteHandler.writePort(val&s.ddrB, PORTB)
		}
	case PORTA:
		if s.portWriteHandler != nil {
			s.portWriteHandler.writePort(val&s.ddrA, PORTA)
		}
	case DDRB:
		s.ddrB = val
	case DDRA:
		s.ddrA = val
	}
}

func (s *W65C22) Read(addr uint8) uint8 {
	// TODO: IRQ from port is actually conditional and is controlled by registers.
	// update this function at some point

	register := W65C22Register(addr & 0xF)
	switch register {
	case PORTB:
		if s.portReadHandler != nil {
			data, holdIRQ := s.portReadHandler.readPort(PORTB)

			if holdIRQ {
				s.irqMultiplexer.SetInterupt(s.irqSource)
			} else {
				s.irqMultiplexer.ClearInterupt(s.irqSource)
			}

			return data
		}
	case PORTA:
		if s.portReadHandler != nil {
			data, holdIRQ := s.portReadHandler.readPort(PORTA)

			if holdIRQ {
				s.irqMultiplexer.SetInterupt(s.irqSource)
			} else {
				s.irqMultiplexer.ClearInterupt(s.irqSource)
			}

			return data
		}
	case DDRB:
		return s.ddrB
	case DDRA:
		return s.ddrA
	}

	return 0
}
