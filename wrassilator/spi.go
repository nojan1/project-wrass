package main

type SPI struct {
	currentDevice uint8
	devices       [8]SPIDevice
	portValue     uint8
	lastClock     bool
}

type SPIDevice interface {
	onClock(clock bool, mosi uint8, selected bool) (miso uint8)
}

func (s *SPI) writePort(val uint8) {
	if val&0x10 == 0 {
		s.currentDevice = 0xFF
	} else {
		s.currentDevice = (val >> 5) & 0x7
	}

	clock := (val >> 2) & 0x1 == 1
	mosi := val & 0x1

	// if s.lastClock == clock {
	// 	return
	// }

	s.lastClock = clock

	var miso uint8 = 0

	for i := range s.devices {
		if s.devices[i] != nil {
			miso |= s.devices[i].onClock(clock, mosi, s.currentDevice == uint8(i))
		}
	}

	s.portValue = (val & 0xfd) | miso<<1
}

func (s *SPI) readPort() (val uint8, requestIRG bool) {
	return s.portValue, false
}

///

type SPIMode = uint8

type SPIShifter struct {
	mode      SPIMode
	bufferOut uint8
	bufferIn  uint8
	cycle     int
}

func (s *SPIShifter) onClock(clock bool, mosi uint8) (miso uint8) {
	cphase := s.mode&0x1 == 1
	cpol := (s.mode >> 1) & 0x1 == 1

	clockIsIdle := cpol && clock	

	if (!cphase && clockIsIdle) || (cphase && !clockIsIdle) {
		// Shift out
		miso = (s.bufferOut >> 7) & 0x1
		s.bufferOut <<= 1
	} else if (cphase && clockIsIdle) || (!cphase && !clockIsIdle){
		// Shift in
		s.bufferIn = (s.bufferIn << 1) | (mosi & 0x1)
		s.cycle++
	}

	return miso
}

func (s *SPIShifter) readByte() (val uint8, ok bool) {
	if s.cycle % 8 == 0 {
		return s.bufferIn, true
	}

	return 0, false
}

func (s *SPIShifter) writeByte(val uint8) {
	s.bufferOut = val
}
