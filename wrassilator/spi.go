package main

import "fmt"

type SPI struct {
	currentDevice uint8
	devices       [8]SPIDevice
	portValue     uint8
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

	clock := (val>>2)&0x1 == 1
	mosi := val & 0x1

	var miso uint8 = 1

	for i := range s.devices {
		if s.devices[i] != nil {
			deviceMiso := s.devices[i].onClock(clock, mosi, s.currentDevice == uint8(i))
			miso &= deviceMiso
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
	dataOut   chan uint8
	bufferOut uint8
	bufferIn  uint8
	cycle     int
	cycleOut  int
	lastClock  bool
	lastMiso   uint8
	bufferOutInitialized bool
}

func (s *SPIShifter) onClock(clock bool, mosi uint8) (miso uint8) {
	if clock == s.lastClock {
		// No transition meaning no edge to trigger on, do nothing
		if s.bufferOutInitialized {
			return s.lastMiso
		}else{
			return 1
		}
	}

	if !s.bufferOutInitialized {
		s.bufferOut = 0xFF
	}

	s.lastClock = clock
	s.bufferOutInitialized = true

	cphase := s.mode&0x1 == 1
	cpol := (s.mode>>1)&0x1 == 1

	clockIsIdle := cpol == clock

	if (!cphase && clockIsIdle) || (cphase && !clockIsIdle) {
		// Shift out
		miso = (s.bufferOut >> 7) & 0x1
		s.bufferOut <<= 1
		s.cycleOut++
		
		if s.cycleOut == 8 {
			// fmt.Println("shifter all shifted out")

			if s.dataOut != nil {
				select {
				case s.bufferOut = <-s.dataOut:
					s.cycleOut = 0
					// fmt.Printf("...got data from channel: $%02X\n", s.bufferOut)
				default:
					//Nothing to add
					// fmt.Println("...nothing new to send")
					s.cycleOut = 0
					s.bufferOut = 0xFF
				}
			}else {
				s.cycleOut = 0
				s.bufferOut = 0xFF
			}
		}

	} else if (cphase && clockIsIdle) || (!cphase && !clockIsIdle) {
		// Shift in
		s.bufferIn = (s.bufferIn << 1) | (mosi & 0x1)
		s.cycle++
	}

	s.lastMiso = miso
	return miso
}

func (s *SPIShifter) readByte() (val uint8, ok bool) {
	if s.cycle == 8 {
		s.cycle = 0
		return s.bufferIn, true
	}

	return 0, false
}

func (s *SPIShifter) writeByte(val uint8) {
	s.bufferOut = val
	s.cycleOut = 0
	s.bufferOutInitialized = true
	fmt.Printf("Buffer out was set to $%02X\n", val)
}
