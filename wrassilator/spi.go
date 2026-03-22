package main

import "fmt"

type SPI struct {
	currentDevice uint8
	devices       [8]SPIDevice

	doEnableB bool

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

		conditionedClock := clk
		if clkInvert {
			conditionedClock = !conditionedClock
		}

		var miso uint8 = 1
		fmt.Printf("PORTA Written, device: %02x, clk: %t, clkInvert: %t, diLatchB: %t, doEnableB: %t, keyboardOe: %d\n", s.currentDevice, clk, clkInvert, diLatchB, s.doEnableB, (val>>7)&0x1)

		s.outputShiftRegister.parallelLoadB = diLatchB
		s.outputShiftRegister.setClock(!conditionedClock)

		for i := range s.devices {
			if s.devices[i] != nil {
				deviceMiso, highZ := s.devices[i].onClock(clk, s.outputShiftRegister.q7, s.currentDevice == uint8(i))

				if !highZ {
					miso &= deviceMiso
				}
			}
		}

		s.inputShiftRegister.inputBit = miso

		s.inputShiftRegister.setShiftRegisterClock(conditionedClock)
		s.inputShiftRegister.setReadClock(!s.doEnableB)
	} else {
		s.outputShiftRegister.parallelInput = val
	}
}
