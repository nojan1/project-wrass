package main

import (
	"bufio"
	"fmt"
	"os"
	"time"
	// "net"
)

type UartRegister uint8

const (
	Transmit UartRegister = iota
	Recieve
	Status
	Config
)

const (
	UART_TRANSMIT_BUFFER_FULL uint8 = 0b01000000
	UART_RECIEVE_BUFFER_NONEMPTY uint8 = 0b10000000
	UART_IRQ_ACTIVE uint8 = 0b00000010
	UART_RECIEVE_BUFFER_FULL uint8 = 0b00000001

	TRANSMIT_BUFFER_REAL_SIZE int = 16
	RECIEVE_BUFFER_REAL_SIZE int = 65536

	PORT string = "0.0.0.0:62213"
)

type UART struct {
	recieveBuffer [RECIEVE_BUFFER_REAL_SIZE]uint8
	transmitBuffer [TRANSMIT_BUFFER_REAL_SIZE]uint8

	recieveWriteIndex int
	recieveReadIndex int
	transmitWriteIndex int
	transmitReadIndex int
}

func (s *UART) Start(simulatorState *SimulatorState, done chan bool) {

	// Byte transmit loop
	go func() {
		delay := 1.0 / (119200 / 8)
		waitDuration := time.Duration(delay * float64(time.Second))

		var stdinReader *bufio.Reader
		stat, _ := os.Stdin.Stat()
		if stat.Mode() & os.ModeCharDevice == 0 {
			fmt.Println("Will read serial data from STDIN")
			stdinReader = bufio.NewReader(os.Stdin)
		}else{
			fmt.Println("STDIN is live terminal, will not read serial data from it")
		}

		for {
			select {
			case <- done:
				return
			case <- time.After(waitDuration):
				if simulatorState.isRunning {
					// Fake sending data somewhere
					if s.transmitReadIndex < s.transmitWriteIndex {
						s.transmitReadIndex++;
					}

					if stdinReader != nil {		
						if data, error := stdinReader.ReadByte(); error == nil {
							s.recieveWriteIndex++;
							s.recieveBuffer[s.recieveWriteIndex % RECIEVE_BUFFER_REAL_SIZE] = data
						}
					}
				}
			}
		}
	}()

	// Network listening loop
	// go func() {
	// 	l, err := net.Listen("tcp", PORT)
    //     if err != nil {
    //             fmt.Println(err)
    //             return
    //     }

	// 	defer l.Close()

    //     c, err := l.Accept()
    //     if err != nil {
    //             fmt.Println(err)
    //             return
    //     }


	// }()
}

func (s *UART) Write(addr uint16, val uint8) {
	subAddr := UartRegister(addr & 0x3)
	if subAddr == Transmit {
		if s.transmitWriteIndex - s.transmitReadIndex < TRANSMIT_BUFFER_REAL_SIZE {
			s.transmitWriteIndex++;
		}
		s.transmitBuffer[s.transmitWriteIndex % TRANSMIT_BUFFER_REAL_SIZE] = val
	}
}

func (s *UART) Read(addr uint16, internal bool) uint8 {
	if internal {
		return 0
	}

	subAddr := UartRegister(addr & 0x3)
	if subAddr == Recieve {
		if s.recieveReadIndex < s.recieveWriteIndex {
			s.recieveReadIndex++
		}
		return s.recieveBuffer[s.recieveReadIndex % RECIEVE_BUFFER_REAL_SIZE]
	} else if subAddr == Status {
		var status uint8 = 0

		if s.recieveWriteIndex - s.recieveReadIndex > 0 {
			status |= UART_RECIEVE_BUFFER_NONEMPTY
		}

		if s.recieveWriteIndex - s.recieveReadIndex < 15 {
			status |= UART_RECIEVE_BUFFER_FULL
		}

		if s.transmitWriteIndex - s.transmitReadIndex < 15 {
			status |= UART_TRANSMIT_BUFFER_FULL
		}

		return status;
	} else {
		return 0;
	}
}