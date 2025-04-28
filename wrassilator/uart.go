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
	UartStatus
	UartConfig
)

const (
	UART_TRANSMIT_BUFFER_FULL    uint8 = 0b01000000
	UART_RECIEVE_BUFFER_NONEMPTY uint8 = 0b10000000
	UART_IRQ_ACTIVE              uint8 = 0b00000010
	UART_RECIEVE_BUFFER_FULL     uint8 = 0b00000001

	TRANSMIT_BUFFER_REAL_SIZE int = 16
	RECIEVE_BUFFER_REAL_SIZE  int = 65536

	PORT string = "0.0.0.0:62213"
)

type UART struct {
	recieveBuffer  [RECIEVE_BUFFER_REAL_SIZE]uint8
	transmitBuffer [TRANSMIT_BUFFER_REAL_SIZE]uint8

	recieveWriteIndex  int
	recieveReadIndex   int
	transmitWriteIndex int
	transmitReadIndex  int
}

func (s *UART) Start(simulatorState *SimulatorState, interactive bool) {
	uartInput := make(chan uint8)

	go func() {
		stat, _ := os.Stdin.Stat()
		isCharDevice := stat.Mode()&os.ModeCharDevice == 0
		if !isCharDevice && !interactive {
			// Will not read stream stdin data if not in interactive mode
			fmt.Println("STDIN is live terminal, will not read serial data from it")
			return
		}

		fmt.Println("Will read serial data from STDIN")

		buf := make([]uint8, 255)
		reader := bufio.NewReader(os.Stdin)

		for {
			n, err := reader.Read(buf)

			if n > 0 {
				// fmt.Printf("%v bytes where read from stdin\n", n)
				for i := range n {
					uartInput <- buf[i]
				}
			}

			if err != nil {
				break
			}
		}

		close(uartInput)
	}()

	// Byte transmit loop
	go func() {
		delay := 1.0 / (119200 / 8)
		waitDuration := time.Duration(delay * float64(time.Second))

		// var stdinReader *bufio.Reader
		// stat, _ := os.Stdin.Stat()
		// if stat.Mode()&os.ModeCharDevice == 0 {
		// 	fmt.Println("Will read serial data from STDIN")
		// 	stdinReader = bufio.NewReader(os.Stdin)
		// } else {
		// 	fmt.Println("STDIN is live terminal, will not read serial data from it")
		// }

		for {
			select {
			case <-simulatorState.done:
				return
			case <-time.After(waitDuration):
				if simulatorState.isRunning {
					if s.transmitReadIndex < s.transmitWriteIndex {
						if interactive {
							indexToSend := s.transmitReadIndex % TRANSMIT_BUFFER_REAL_SIZE
							os.Stdout.Write(s.transmitBuffer[indexToSend : indexToSend+1])
						}

						s.transmitReadIndex++
					}

					select {
					case data := <-uartInput:
						if data != 0 {
							s.recieveWriteIndex++
							s.recieveBuffer[s.recieveWriteIndex%RECIEVE_BUFFER_REAL_SIZE] = data
						}
					default:
					}

					// if stdinReader != nil {
					// 	if data, error := stdinReader.ReadByte(); error == nil {
					// 		s.recieveWriteIndex++
					// 		s.recieveBuffer[s.recieveWriteIndex%RECIEVE_BUFFER_REAL_SIZE] = data
					// 	}
					// }

					// if interactive {
					// 	stat, _ := os.Stdin.Stat()
					// 	size := stat.Size()
					// 	fmt.Printf("STDIN currently has size %v\n", size)
					// }
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
		if s.transmitWriteIndex-s.transmitReadIndex < TRANSMIT_BUFFER_REAL_SIZE {
			s.transmitWriteIndex++
		}
		s.transmitBuffer[s.transmitWriteIndex%TRANSMIT_BUFFER_REAL_SIZE] = val
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
		return s.recieveBuffer[s.recieveReadIndex%RECIEVE_BUFFER_REAL_SIZE]
	} else if subAddr == UartStatus {
		var status uint8 = 0

		if s.recieveWriteIndex-s.recieveReadIndex > 0 {
			status |= UART_RECIEVE_BUFFER_NONEMPTY
		}

		if s.recieveWriteIndex-s.recieveReadIndex < 15 {
			status |= UART_RECIEVE_BUFFER_FULL
		}

		if s.transmitWriteIndex-s.transmitReadIndex < 15 {
			status |= UART_TRANSMIT_BUFFER_FULL
		}

		return status
	} else {
		return 0
	}
}
