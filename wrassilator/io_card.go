package main

type IoCard struct {
	keyboard  *Keyboard
	userVia   *W65C22
	systemVia *W65C22
}

func NewIoCard(irqMultiplexer *IRQMultiplexer, sdCardPath string) *IoCard {
	keyboard := &Keyboard{}

	spi := &SPI{}
	spi.devices[0] = NewSdCard(sdCardPath)
	spi.devices[1] = NewDS1306()

	// Temp
	spi.devices[2] = &SpiEchoDevice{
		shifter: &SPIShifter{mode: 1},
	}

	return &IoCard{
		keyboard: keyboard,
		userVia: &W65C22{
			irqMultiplexer: irqMultiplexer,
			irqSource:      UserViaIRQSource,
		},
		systemVia: &W65C22{
			irqMultiplexer:    irqMultiplexer,
			irqSource:         SystemViaIRQSource,
			portAReadHandler:  spi,
			portAWriteHandler: spi,
			portBReadHandler:  keyboard,
		},
	}
}

func (s *IoCard) Write(addr uint16, val uint8) {
	if addr&0x10 != 0 {
		s.systemVia.Write(uint8(addr), val)
	} else {
		s.userVia.Write(uint8(addr), val)
	}
}

func (s *IoCard) Read(addr uint16, internal bool) uint8 {
	if internal {
		return 0
	}

	if addr&0x10 != 0 {
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
	irqMultiplexer *IRQMultiplexer
	irqSource      IRQSource

	ddrA              uint8
	ddrB              uint8
	portAReadHandler  W65C22PortReadHandler
	portBReadHandler  W65C22PortReadHandler
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
	register := W65C22Register(addr & 0xF)
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

func (s *W65C22) Read(addr uint8) uint8 {
	// TODO: IRQ from port is actually conditional and is controlled by registers.
	// update this function at some point

	register := W65C22Register(addr & 0xF)
	switch register {
	case PORTB:
		if s.portBReadHandler != nil {
			data, holdIRQ := s.portBReadHandler.readPort()

			if holdIRQ {
				s.irqMultiplexer.SetInterupt(s.irqSource)
			} else {
				s.irqMultiplexer.ClearInterupt(s.irqSource)
			}

			return data
		}
	case PORTA:
		if s.portAReadHandler != nil {
			data, holdIRQ := s.portAReadHandler.readPort()

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
