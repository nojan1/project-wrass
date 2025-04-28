package main

import "fmt"

type SpiEchoDevice struct {
	shifter *SPIShifter
}

func (s *SpiEchoDevice) onClock(clock bool, mosi uint8, selected bool) (miso uint8) {
	if !selected {
		return 1
	}

	miso = s.shifter.onClock(clock, mosi)
	if val, ok := s.shifter.readByte(); ok {
		fmt.Printf("SPI Echo device, Got complete byte, $%02X, sending back \n", val)
		s.shifter.writeByte(val)
	}

	return miso
}