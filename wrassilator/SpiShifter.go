package main

import "fmt"

type SPIMode = uint8

type SPIShifter struct {
	mode                 SPIMode
	dataOut              chan uint8
	bufferOut            uint8
	bufferIn             uint8
	cycle                int
	cycleOut             int
	lastClock            bool
	lastMiso             uint8
	bufferOutInitialized bool
}

func (s *SPIShifter) onClock(clock bool, mosi uint8) (miso uint8) {
	if clock == s.lastClock {
		// No transition meaning no edge to trigger on, do nothing
		if s.bufferOutInitialized {
			return s.lastMiso
		} else {
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
			} else {
				s.cycleOut = 0
				s.bufferOut = 0xFF
			}
		}

	} else if (cphase && clockIsIdle) || (!cphase && !clockIsIdle) {
		// Shift in
		s.bufferIn = (s.bufferIn << 1) | (mosi & 0x1)
		s.cycle++
	}

	// fmt.Printf("Buffer IN: %08b\n", s.bufferIn)
	// fmt.Printf("Buffer OUT: %08b\n", s.bufferOut)

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
