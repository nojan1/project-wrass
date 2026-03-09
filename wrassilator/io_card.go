package main

type IoCard struct {
	keyboard  *Keyboard
	spi       *SPI
	userVia   *W65C22
	systemVia *W65C22

	keyboardOeB bool
	spiOeB      bool
}

func NewIoCard(irqMultiplexer *IRQMultiplexer, sdCardPath string) *IoCard {
	keyboard := &Keyboard{}

	spi := &SPI{
		outputShiftRegister: &IC74165{},
		inputShiftRegister:  &IC74565{},
	}

	// device 0 is the "none selected device"
	spi.devices[1] = NewSdCard(sdCardPath)
	spi.devices[2] = NewDS1306()

	// Temp
	spi.devices[3] = &SpiEchoDevice{
		shifter: &SPIShifter{mode: 1},
	}

	ioCard := &IoCard{
		keyboard: keyboard,
		spi:      spi,
		userVia: &W65C22{
			irqMultiplexer: irqMultiplexer,
			irqSource:      UserViaIRQSource,
		},
		systemVia: &W65C22{
			irqMultiplexer: irqMultiplexer,
			irqSource:      SystemViaIRQSource,
		},
	}

	ioCard.systemVia.portReadHandler = ioCard
	ioCard.systemVia.portWriteHandler = ioCard

	return ioCard
}

// PortA on the SystemVia has the following pin allocations
// PA0: SPI_DEV0
// PA1: SPI_DEV1
// PA2: SPI_DEV2
// PA3: CLK_In
// PA4: CLK_Invert
// PA5: /DI_Latch
// PA6: /DO_Enable
// PA7: /Keyboard_OE
func (s *IoCard) writePort(val uint8, port W65C22Register) {
	if port == PORTA {
		s.spiOeB = (val>>6)&0x1 == 1
		s.keyboardOeB = (val>>7)&0x1 == 1
	}

	// Writes to PortB (SPI data out) is handled inside spi writePort handler
	s.spi.writePort(val, port)
}

// PortB is connected as a bus to three sources, SPI read/write and keyboard read
func (s *IoCard) readPort(port W65C22Register) (val uint8, requestIRQ bool) {
	if port == PORTB {
		returnVal := uint8(0)
		requestIRQ := false

		if s.spiOeB {
			returnVal |= s.spi.inputShiftRegister.readLatchValue
		}

		if s.keyboardOeB {
			val, irq := s.keyboard.readPort(port)
			returnVal |= val
			requestIRQ = requestIRQ || irq
		}

		return returnVal, requestIRQ

	} else {
		return 0, false
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
