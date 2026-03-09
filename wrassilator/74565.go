package main

type IC74565 struct {
	ouputEnableB           bool
	lastShiftRegisterClock bool
	lastReadClock          bool
	shiftRegisterValue     uint8
	readLatchValue         uint8
	inputBit               uint8
	shiftRegisterClearB    bool
}

func (s *IC74565) setShiftRegisterClock(newClock bool) {
	if !s.shiftRegisterClearB {
		s.shiftRegisterValue = 0
		return
	}

	if !s.lastShiftRegisterClock && newClock {
		s.shiftRegisterValue <<= s.inputBit & 0x01
	}

	s.lastShiftRegisterClock = newClock
}

func (s *IC74565) setReadClock(newClock bool) {
	if !s.lastReadClock && newClock {
		s.readLatchValue = s.shiftRegisterValue
	}

	s.lastReadClock = newClock
}

func (s *IC74565) getOutput() uint8 {
	if !s.shiftRegisterClearB {
		s.shiftRegisterValue = 0
	}

	if !s.ouputEnableB {
		return s.readLatchValue
	}

	// Output enable is not active... in a real chip we would be high Z at this point
	// but we are lazy and just return 0
	return 0x00
}
