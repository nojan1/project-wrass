package main

import (
	"fmt"
	sim6502 "github.com/nojan1/sim6502/pkg"
	rl "github.com/gen2brain/raylib-go/raylib"
)

func DrawRegisterStatusPanel(x int32, y int32, proc *sim6502.Processor) {
	fontSize := 20
	
	lineHeight := 25
	columnWidth := 120

	registers := proc.Registers()

	rl.DrawText(fmt.Sprintf("A: $%02X", registers.A), x + 0, y + 0, int32(fontSize), rl.White)
	rl.DrawText(fmt.Sprintf("X: $%02X", registers.X), x + int32(columnWidth) * 1, y + 0, int32(fontSize), rl.White)
	rl.DrawText(fmt.Sprintf("Y: $%02X", registers.Y), x + int32(columnWidth) * 2, y + 0, int32(fontSize), rl.White)

	rl.DrawText(fmt.Sprintf("PC: $%02X", registers.PC.Current()), x + 0, y + int32(lineHeight) * 1, int32(fontSize), rl.White)
	rl.DrawText(fmt.Sprintf("SP: $%02X", registers.SP.GetStackPointer()), x + int32(columnWidth) * 1, y + int32(lineHeight) * 1, int32(fontSize), rl.White)

	boxSpacing := 30
	boxSize := int32(20)

	DrawStatusBox(registers.SR.IsSet(sim6502.SRFlagB), "B", x + int32(boxSpacing) * 0, y + int32(lineHeight) * 2, boxSize)
	DrawStatusBox(registers.SR.IsSet(sim6502.SRFlagC), "C", x + int32(boxSpacing) * 1, y + int32(lineHeight) * 2, boxSize)
	DrawStatusBox(registers.SR.IsSet(sim6502.SRFlagD), "D", x + int32(boxSpacing) * 2, y + int32(lineHeight) * 2, boxSize)
	DrawStatusBox(registers.SR.IsSet(sim6502.SRFlagI), "I", x + int32(boxSpacing) * 3, y + int32(lineHeight) * 2, boxSize)
	DrawStatusBox(registers.SR.IsSet(sim6502.SRFlagN), "N", x + int32(boxSpacing) * 4, y + int32(lineHeight) * 2, boxSize)
	DrawStatusBox(registers.SR.IsSet(sim6502.SRFlagU), "U", x + int32(boxSpacing) * 5, y + int32(lineHeight) * 2, boxSize)
	DrawStatusBox(registers.SR.IsSet(sim6502.SRFlagV), "V", x + int32(boxSpacing) * 6, y + int32(lineHeight) * 2, boxSize)
	DrawStatusBox(registers.SR.IsSet(sim6502.SRFlagZ), "Z", x + int32(boxSpacing) * 7, y + int32(lineHeight) * 2, boxSize)

	nextLine := 3 + DrawStack(proc, x, y + int32(lineHeight) * 3, lineHeight, fontSize)
	DrawDissambly(proc, x, y + int32(lineHeight) * (4 + nextLine), lineHeight, fontSize)
}

func DrawStatusBox(isSet bool, name string, x int32, y int32, boxSize int32) {
	bgColor := rl.DarkBlue
	fgColor := rl.White

	if isSet {
		bgColor = rl.White
		fgColor = rl.Black
	}

	rl.DrawRectangle(x, y, boxSize, boxSize, bgColor)
	rl.DrawRectangleLines(x, y, boxSize, boxSize, rl.White)
	rl.DrawText(name, x + 2, y, boxSize, fgColor)
}

func DrawStack(proc *sim6502.Processor, x int32, y int32, lineHeight int, fontSize int) int32 {
	numStackEntries := 5
	sp := proc.Registers().SP.GetStackPointer()

	rl.DrawText("- STACK -", x + 80, y, int32(fontSize), rl.White)

	var i uint8
	for i = 0; i < uint8(numStackEntries); i++ {
		sp += i
		addr := 0x100 + uint16(sp)
		value := proc.Memory().Read(addr, true)
		rl.DrawText(fmt.Sprintf("$%02X: $%02X", addr, value), x, y + int32(lineHeight) * int32(i + 1), int32(fontSize), rl.White)

		if sp == 0 {
			break
		}
	}

	return 1 + int32(numStackEntries)
}

func DrawDissambly(proc *sim6502.Processor, x int32, y int32, lineHeight int, fontSize int) {
	currentAddress := proc.Registers().PC.Current()
	startAddress := currentAddress - 8

	rl.DrawText("- PROG -", x + 80, y, int32(fontSize), rl.White)

	var i uint16
	for i = 0; i < 15; i++ {
		text := fmt.Sprintf("$%02X:", startAddress + i)
		textY := y + int32(lineHeight) * int32(i + 1)

		if startAddress + i == currentAddress {
			rl.DrawText(text, x, textY, int32(fontSize), rl.White)
		} else {
			rl.DrawText(text, x, textY, int32(fontSize), rl.Gray)
		}
	}
}

func (s *GPU) DrawTileMap(xBase int32, yBase int32) {
	var numColumns int32 = 16
	var tileNumber int32

	for tileNumber = 0; tileNumber < 256; tileNumber++ {
		xTileBase := xBase + 16 * (tileNumber % numColumns)
		yTileBase := yBase + 16 * (tileNumber / numColumns)

		s.drawTileWithAttribute(xTileBase, yTileBase, uint8(tileNumber), 0b00010000, 2)
	}
}

func (s *GPU) DrawColorAttributes(xBase int32, yBase int32) {
	var side float32 = 8
	var attributeIndex int32

	for attributeIndex = 0; attributeIndex < (TilemapStart - ColorAttributesStart); attributeIndex++ {
		colorAttribute := s.vram[ColorAttributesStart + attributeIndex]
		foregroundIndex := (colorAttribute >> 4) & 0xf
		backgroundIndex := colorAttribute & 0xf

		xDrawBase := float32(xBase + 8 * (attributeIndex % TotalCharCols))
		yDrawBase := float32(yBase + 8 * (attributeIndex / TotalCharCols))

		rl.DrawTriangle(
			rl.Vector2{ X: xDrawBase, Y: yDrawBase },
			rl.Vector2{ X: xDrawBase, Y: yDrawBase + side },
			rl.Vector2{ X: xDrawBase + side, Y: yDrawBase },
			s.rlColorFromIndex(foregroundIndex),
		)	

		rl.DrawTriangle(
			rl.Vector2{ X: xDrawBase, Y: yDrawBase + side },
			rl.Vector2{ X: xDrawBase + side, Y: yDrawBase + side },
			rl.Vector2{ X: xDrawBase + side, Y: yDrawBase },
			s.rlColorFromIndex(backgroundIndex),
		)	
	}

	s.drawWindowBoundry(xBase, yBase)
}

func (s *GPU) drawWindowBoundry(xBase int32, yBase int32) {
	// offsetX := s.registerValues[XOffset]
	// offsetY := s.registerValues[YOffset]


}

func (s *GPU) DrawFullFrameBuffer(xBase int32, yBase int32) {
	var frameBufferIndex int32
	for frameBufferIndex = 0; frameBufferIndex < (ColorAttributesStart - FramebufferStart); frameBufferIndex++ {
		tileNumber := s.vram[FramebufferStart + frameBufferIndex]

		xDrawBase := int32(xBase + 8 * (frameBufferIndex % TotalCharCols))
		yDrawBase := int32(yBase + 8 * (frameBufferIndex / TotalCharCols))

		s.drawTileWithAttribute(xDrawBase, yDrawBase, tileNumber, 0b00010000, 1)
	}

	s.drawWindowBoundry(xBase, yBase)
}

func (s *GPU) DrawColors(xBase int32, yBase int32) {
	var colorIndex ColorIndex
	var side int32 = 32
	var columns int32 = 4

	for colorIndex = 0; colorIndex < 16; colorIndex++ {
		rl.DrawRectangle(
			xBase + ((int32(colorIndex) % columns) * (side + 5)),
			yBase + ((int32(colorIndex) / columns) * (side + 5)),
			side,
			side,
			s.rlColorFromIndex(colorIndex),
		)
	}
}