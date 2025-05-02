package main

// https://www.rjhcoding.com/avrc-sd-interface-1.php

import (
	"fmt"
	"os"
)

type SdCardInterface struct {
	stateHandlers []SdCardStateHandler
	commandBuffer *CommandBuffer
	dataOut       chan uint8
	shifter       *SPIShifter
	card          *SdCard
}

type SdCard struct {
	file  *os.File
	state SdCardState
}

type SdCardStateHandler interface {
	OnClock(card *SdCard, selected bool)
	OnCommand(card *SdCard, command SdCommand, argument uint32, crc uint8, stopBit uint8, dataOut chan uint8)
}

type SdCardState = int

const (
	SDCARD_STATE_UNINITIALIZED SdCardState = iota
	SDCARD_STATE_COLDBOOT
	SDCARD_STATE_IDLE
	SDCARD_STATE_READY
)

type R1Flags = uint8

const (
	R1Sucess              R1Flags = 0
	R1InIdleState         R1Flags = 1
	R1EreaseReset         R1Flags = 2
	R1IllegalCommand      R1Flags = 4
	R1CrcError            R1Flags = 8
	R1EreaseSequenceError R1Flags = 16
	R1AddressError        R1Flags = 32
	R1ParameterError      R1Flags = 64
)

type SdCommand = uint8

const (
	SD_CMD0   SdCommand = 0  // GO_IDLE_STATE
	SD_CMD1   SdCommand = 1  // SEND_OP_COND
	SD_ACMD41 SdCommand = 41 // APP_SEND_OP_COND
	SD_CMD8   SdCommand = 8  // SEND_IF_COND
	SD_CMD9   SdCommand = 9  // SEND_CSD
	SD_CMD10  SdCommand = 10 // SEND_CID
	SD_CMD12  SdCommand = 12 // STOP_TRANSMISSION
	SD_CMD16  SdCommand = 16 // SET_BLOCKLEN
	SD_CMD17  SdCommand = 17 // READ_SINGLE_BLOCK
	SD_CMD18  SdCommand = 18 // READ_MULTIPLE_BLOCK
	SD_CMD23  SdCommand = 23 // SET_BLOCK_COUNT
	SD_CMD24  SdCommand = 24 // WRITE_BLOCK
	SD_CMD25  SdCommand = 25 // WRITE_MULTIPLE_BLOCK
	SD_CMD55  SdCommand = 55 // APP_CMD
	SD_CMD5   SdCommand = 5  // READ_OCR
)

func NewSdCard(sdImageFilePath string) *SdCardInterface {
	f, error := os.Open(sdImageFilePath)

	if error != nil {
		os.Stderr.WriteString(fmt.Sprintf("Failed to open SD card image, got error %v\n", error))
	}

	dataOut := make(chan uint8, 700)

	return &SdCardInterface{
		shifter:       &SPIShifter{mode: 1, dataOut: dataOut}, //SHOULD BE 0 PROBABLY BUT ASM IS CURRENTLY BORKED!!!
		commandBuffer: &CommandBuffer{},
		dataOut:       dataOut,
		stateHandlers: []SdCardStateHandler{
			&PowerUpSdCardStateHandler{},
			&UninitializedSdCardStateHandler{},
			&IdleSdCardStateHandler{},
			&ReadySdCardStateHandler{},
		},
		card: &SdCard{
			file:  f,
			state: SDCARD_STATE_UNINITIALIZED,
		},
	}
}

func (s *SdCardInterface) onClock(clock bool, mosi uint8, selected bool) (miso uint8) {
	if selected {
		miso = s.shifter.onClock(clock, mosi)
	} else {
		miso = 1
	}

	s.stateHandlers[s.card.state].OnClock(s.card, selected)

	if val, ok := s.shifter.readByte(); ok && selected {
		// fmt.Printf("SD card got byte: $%02X\n", val)
		s.commandBuffer.IngestByte(val)

		if s.commandBuffer.HasCommand() {
			command := s.commandBuffer.GetCommand()
			argument := s.commandBuffer.GetArgument()
			crc := s.commandBuffer.GetCrc()
			stopbit := s.commandBuffer.GetStopBit()

			// fmt.Printf("Got SD Command %v, ARG: %04X, CRC: %X, STOP: %v\n", command, argument, crc, stopbit)

			s.stateHandlers[s.card.state].OnCommand(s.card, command, argument, crc, stopbit, s.dataOut)
		}

	}

	return miso
}

//

type PowerUpSdCardStateHandler struct {
	numCyclesRecieved int
}

func (s *PowerUpSdCardStateHandler) OnClock(card *SdCard, selected bool) {
	s.numCyclesRecieved += 8

	if s.numCyclesRecieved >= 74 {
		// fmt.Println("SD Card is now in Cold boot state")
		card.state = SDCARD_STATE_COLDBOOT
	}
}

func (s *PowerUpSdCardStateHandler) OnCommand(card *SdCard, command SdCommand, argument uint32, crc uint8, stopBit uint8, dataOut chan uint8) {
	// Nope
}

//

type UninitializedSdCardStateHandler struct{}

func (s *UninitializedSdCardStateHandler) OnClock(card *SdCard, selected bool) {}

func (s *UninitializedSdCardStateHandler) OnCommand(card *SdCard, command SdCommand, argument uint32, crc uint8, stopBit uint8, dataOut chan uint8) {
	if command == SD_CMD0 {
		if crc != 0b1001010 {
			fmt.Println("Got CRC error for CMD0")
			dataOut <- R1CrcError
		} else {
			// We got correct go idle command
			// Send 5 "busy" responses
			dataOut <- 0xFF
			dataOut <- 0xFF
			dataOut <- 0xFF
			dataOut <- 0xFF
			dataOut <- 0xFF

			// Send success
			dataOut <- R1Sucess
			card.state = SDCARD_STATE_IDLE
			// fmt.Println("SD Card is in Idle state")
		}
	}
}

//

type IdleSdCardStateHandler struct {
	applicationSpecificCommand bool
	idleStateTimer             int
}

func (s *IdleSdCardStateHandler) OnClock(card *SdCard, selected bool) {}

func (s *IdleSdCardStateHandler) OnCommand(card *SdCard, command SdCommand, argument uint32, crc uint8, stopBit uint8, dataOut chan uint8) {
	if s.applicationSpecificCommand {
		switch command {
		case SD_ACMD41:
			s.idleStateTimer++
			if s.idleStateTimer < 5 {
				dataOut <- R1InIdleState
				// fmt.Printf("Got ACMD41, timer is now %v\n", s.idleStateTimer)
			} else {
				dataOut <- R1Sucess
				card.state = SDCARD_STATE_READY
				// fmt.Println("Git ACMD41, now entering ready state")
			}
		}

		s.applicationSpecificCommand = false
	} else {
		switch command {
		case SD_CMD8:
			// fmt.Println("Responding to CMD8")
			// Return a R7 response, stating that all is fine
			dataOut <- R1Sucess
			dataOut <- 0
			dataOut <- 0
			dataOut <- 0
			dataOut <- (uint8(argument&0xFF) << 1) | 1
		case SD_CMD55:
			// Next command will be an application specific command
			s.applicationSpecificCommand = true
			dataOut <- R1Sucess
		}
	}
}

//

type ReadySdCardStateHandler struct {
	blockSize int64
}

func (s *ReadySdCardStateHandler) OnClock(card *SdCard, selected bool) {}

func (s *ReadySdCardStateHandler) OnCommand(card *SdCard, command SdCommand, argument uint32, crc uint8, stopBit uint8, dataOut chan uint8) {
	if s.blockSize == 0 {
		s.blockSize = 512
	}

	if command == SD_CMD17 {
		fileOffset := int64(argument) * s.blockSize

		if card.file == nil {
			dataOut <- R1AddressError
		} else {
			buffer := make([]byte, s.blockSize)
			_, err := card.file.ReadAt(buffer, fileOffset)

			if err == nil {
				dataOut <- R1Sucess
				dataOut <- 0b11111110

				// fmt.Println("Sending data")
				for _, d := range buffer {
					// fmt.Printf("%02X ", d)

					// if i != 0 && i % 16 == 0 {
					// 	fmt.Println()
					// }

					dataOut <- d
				}
				// fmt.Println("--------")

				dataOut <- 0xaa
				dataOut <- 0xab
			} else {
				dataOut <- R1ParameterError
				fmt.Printf("Failed to read from SD card image, got error %v\n", err)
			}
		}
	}
}

//

type CommandBuffer struct {
	data  [8]uint8
	index int
}

func (s *CommandBuffer) IngestByte(dataIn uint8) {
	s.index = (s.index + 1) % len(s.data)
	s.data[s.index] = dataIn
}

func (s *CommandBuffer) Reset() {
	s.index = 0
}

func (s *CommandBuffer) HasCommand() bool {
	rawCommand := s.dataAtOffset(5)
	stopBit := s.GetStopBit()

	return rawCommand&0b10000000 == 0 &&
		rawCommand&0b01000000 != 0 &&
		stopBit == 1
}

func (s *CommandBuffer) GetCommand() SdCommand {
	return SdCommand(s.dataAtOffset(5) & 0x3F)
}

func (s *CommandBuffer) GetArgument() uint32 {
	return uint32(s.dataAtOffset(4))<<24 |
		uint32(s.dataAtOffset(3))<<16 |
		uint32(s.dataAtOffset(2))<<8 |
		uint32(s.dataAtOffset(1))<<0
}

func (s *CommandBuffer) GetCrc() uint8 {
	return s.dataAtOffset(0) >> 1
}

func (s *CommandBuffer) GetStopBit() uint8 {
	return s.dataAtOffset(0) & 0x1
}

func (s *CommandBuffer) dataAtOffset(amount int) uint8 {
	return s.data[s.getOffsetIndex(amount)]
}

func (s *CommandBuffer) getOffsetIndex(amount int) int {
	offset := s.index - amount
	if offset < 0 {
		return len(s.data) + offset
	}

	return offset
}
