package main

type SPI struct {
	currentDevice uint8
	devices       [8]SPIDevice
	portValue     uint8

	keyboardOeB bool
	doEnableB   bool

	outputShiftRegister *IC74165
	inputShiftRegister  *IC74565
}

type SPIDevice interface {
	onClock(clock bool, mosi uint8, selected bool) (miso uint8, highZ bool)
}

func (s *SPI) writePort(val uint8, port W65C22Register) {
	if port == PORTA {
		s.currentDevice = val & 0x7
		clk := (val>>3)&0x1 == 1
		clkInvert := (val>>4)&0x1 == 1

		diLatchB := (val>>5)&0x1 == 1
		s.doEnableB = (val>>6)&0x1 == 1
		s.keyboardOeB = (val>>7)&0x1 == 1

		conditionedClock := clk
		if clkInvert {
			conditionedClock = !conditionedClock
		}

		s.inputShiftRegister.setShiftRegisterClock(conditionedClock)
		s.inputShiftRegister.setReadClock(!s.doEnableB)

		var miso uint8 = 1

		for i := range s.devices {
			if s.devices[i] != nil {
				deviceMiso, highZ := s.devices[i].onClock(clk, s.outputShiftRegister.q7, s.currentDevice == uint8(i))

				if !highZ {
					miso &= deviceMiso
				}
			}
		}

		s.inputShiftRegister.inputBit = miso

		s.outputShiftRegister.parallelLoadB = diLatchB
		s.outputShiftRegister.setClock(!conditionedClock)
	} else {
		s.outputShiftRegister.parallelInput = val
	}
}

func (s *SPI) readPort(port W65C22Register) (val uint8, requestIRQ bool) {
	if port == PORTB {
		returnVal := uint8(0)

		if s.doEnableB {
			returnVal |= s.inputShiftRegister.readLatchValue
		}

		return returnVal, false

	} else {
		return 0, false
	}
}
