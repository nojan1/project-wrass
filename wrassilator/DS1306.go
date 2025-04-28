package main

import (
	"fmt"
	"time"
)

type DS1306 struct {
	shifter      *SPIShifter
	writeAddress uint8
	internalDate time.Time
}

type DS1306Register = uint8

const (
	SECONDS DS1306Register = iota
	MINUTES
	HOURS
	DAY
	DATE
	MONTH
	YEAR

	CONTROL       = 0xf
	STATUS        = 0x10
	TRICKLECHARGE = 0x11
)

func NewDS1306() *DS1306 {
	return &DS1306{
		writeAddress: 0xFF,
		// internalDate:  time.Date(0, 0, 0, 0, 0, 0, 0, time.Local),
		internalDate: time.Now(),
		shifter:      &SPIShifter{mode: 1},
	}
}

func (s *DS1306) onClock(clock bool, mosi uint8, selected bool) (miso uint8) {
	if !selected {
		return 1
	}

	miso = s.shifter.onClock(clock, mosi)

	if val, ok := s.shifter.readByte(); ok {
		if s.writeAddress != 0xFF {
			// Perform a write now
			effectiveAddress := s.writeAddress & 0x7f

			fmt.Printf("Got write to address %02X with value %02X\n", effectiveAddress, val)

			switch effectiveAddress {
			case SECONDS:
				s.internalDate = time.Date(
					s.internalDate.Year(),
					s.internalDate.Month(),
					s.internalDate.Day(),
					s.internalDate.Hour(),
					s.internalDate.Minute(),
					fromBcd(val),
					0,
					time.Local,
				)
			case MINUTES:
				s.internalDate = time.Date(
					s.internalDate.Year(),
					s.internalDate.Month(),
					s.internalDate.Day(),
					s.internalDate.Hour(),
					fromBcd(val),
					s.internalDate.Second(),
					0,
					time.Local,
				)
			case DAY:

			case HOURS:
				s.internalDate = time.Date(
					s.internalDate.Year(),
					s.internalDate.Month(),
					s.internalDate.Day(),
					fromBcd(val),
					s.internalDate.Minute(),
					s.internalDate.Second(),
					0,
					time.Local,
				)
			case DATE:
				s.internalDate = time.Date(
					s.internalDate.Year(),
					s.internalDate.Month(),
					fromBcd(val),
					s.internalDate.Hour(),
					s.internalDate.Minute(),
					s.internalDate.Second(),
					0,
					time.Local,
				)
			case MONTH:
				s.internalDate = time.Date(
					s.internalDate.Year(),
					time.Month(fromBcd(val)),
					s.internalDate.Day(),
					s.internalDate.Hour(),
					s.internalDate.Minute(),
					s.internalDate.Second(),
					0,
					time.Local,
				)
			case YEAR:
				s.internalDate = time.Date(
					2000+fromBcd(val),
					s.internalDate.Month(),
					s.internalDate.Day(),
					s.internalDate.Hour(),
					s.internalDate.Minute(),
					s.internalDate.Second(),
					0,
					time.Local,
				)
			}

			s.writeAddress = 0xFF
		} else {
			isWrite := val&0x80 != 0
			if isWrite {
				s.writeAddress = val
			} else {
				// Perform read
				effectiveAddress := val & 0x7f

				switch effectiveAddress {
				case SECONDS:
					s.shifter.writeByte(toBcd(s.internalDate.Second()))
				case MINUTES:
					s.shifter.writeByte(toBcd(s.internalDate.Minute()))
				case DAY:
					s.shifter.writeByte(toBcd(s.internalDate.Day()))
				case HOURS:
					s.shifter.writeByte(toBcd(s.internalDate.Hour()))
				case DATE:
					s.shifter.writeByte(toBcd(s.internalDate.Day()))
				case MONTH:
					s.shifter.writeByte(toBcd(int(s.internalDate.Month())))
				case YEAR:
					year := s.internalDate.Year() - 2000
					s.shifter.writeByte(toBcd(year))
				default:
					s.shifter.writeByte(0)
				}
			}
		}
	}

	return miso
}

func toBcd(x int) uint8 {
	return uint8(((x / 10) << 4) | (x % 10))
}

func fromBcd(x uint8) int {
	return int((x>>4)*10 + (x & 0x0f))
}
