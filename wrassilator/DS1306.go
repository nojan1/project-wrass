package main

import (
	"fmt"
	"time"
)

type DS1306 struct {
	shifter *SPIShifter
	addressRecieved uint8
	internalDate time.Time
}

type DS1306Register = uint8

const (
	SECONDS DS1306Register = iota
	MINUTES
	DAY
	HOURS
	DATE
	MONTH
	YEAR
	
	CONTROL = 0xf
	STATUS = 0x10
	TRICKLECHARGE = 0x11
)


func NewDS1306 () (*DS1306) {
	return &DS1306{
		addressRecieved: 0xFF,
		// internalDate:  time.Date(0, 0, 0, 0, 0, 0, 0, time.Local),
		internalDate: time.Now(),
		shifter: &SPIShifter{ mode: 0 },
	}
}

func (s *DS1306) onClock(clock bool, mosi uint8, selected bool) (miso uint8) {
	if !selected {
		return 0
	}

	miso = s.shifter.onClock(clock, mosi)

	if val, ok := s.shifter.readByte(); ok {
		// fmt.Printf("DS1306 got %v\n", val)

		if s.addressRecieved != 0xFF {
			// Data read / write
			effectiveAddress := s.addressRecieved & 0x7f
			isWrite := s.addressRecieved & 0x80 != 0

			f := func (read func() uint8, write func ()) {
				if isWrite {
					write()
					fmt.Printf("Writing to address $%02X, value $%02X \n", effectiveAddress, val)
					s.shifter.writeByte(0xFf)
				} else {
					value := read()
					fmt.Printf("Read from address $%02X, got $%02X \n", effectiveAddress, value)
					s.shifter.writeByte(value)
				}
			}	

			s.addressRecieved = 0xFF

			switch effectiveAddress {
			case SECONDS:
				f(
					func() uint8 { 
						return toBcd(s.internalDate.Second())
					},
					func() { 
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
					},
				)
			case MINUTES:
				f(
					func() uint8 { 
						return toBcd(s.internalDate.Minute())
					},
					func() { 
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
					},
				)
			case DAY:
				f(
					func() uint8 { 
						return toBcd(s.internalDate.Day())
					},
					func() { },
				)
			case HOURS:
				f(
					func() uint8 { 
						return toBcd(s.internalDate.Hour())
					},
					func() { 
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
					},
				)
			case DATE:
				f(
					func() uint8 { 
						return toBcd(s.internalDate.Day())
					},
					func() { 
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
					},
				)
			case MONTH:
				f(
					func() uint8 { 
						return toBcd(int(s.internalDate.Month()))
					},
					func() { 
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
					},
				)
			case YEAR:
				f(
					func() uint8 { 
						return toBcd(2000 - s.internalDate.Year())
					},
					func() { 
						s.internalDate = time.Date(
							2000 + fromBcd(val),
							s.internalDate.Month(),
							s.internalDate.Day(),
							s.internalDate.Hour(), 
							s.internalDate.Minute(),
							s.internalDate.Second(), 
							0,
							time.Local,
						)
					},
				)
			default:
				s.shifter.writeByte(0)
			}
		} else {
			s.addressRecieved = val
		}
	}

	return miso
}

func toBcd(x int) uint8{
	return uint8(((x / 10) << 4) | (x % 10))
}

func fromBcd(x uint8) int {
	return int((x >> 4) * 10 + (x & 0x0f))
} 