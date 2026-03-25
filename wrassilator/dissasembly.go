package main

import (
	"fmt"
	sim6502 "github.com/nojan1/sim6502/pkg"
)

type disassembly struct {
	address uint16
	text    string
}

func Disassemble(proc *sim6502.Processor, instructionsBack int, instructionsForward int, symbols map[uint16]string) []*disassembly {
	ret := make([]*disassembly, 0, instructionsBack+instructionsForward)

	pc := proc.Registers().PC.Current()

	// for i := 0; i < instructionsBack; i++ {
	// 	if newPc, ok := jumpBackOneInstruction(proc, pc); ok {
	// 		pc = newPc
	// 	} else {
	// 		break
	// 	}
	// }

	for i := 0; i < instructionsBack+instructionsForward; i++ {
		newPc, disassembly := disassembleInstruction(proc, pc, symbols)
		pc = newPc

		ret = append(ret, disassembly)
	}

	return ret
}

func jumpBackOneInstruction(proc *sim6502.Processor, pc uint16) (uint16, bool) {
	memory := proc.Memory()
	instructions := proc.Instructions()

	bytesBack := 0

	for {
		pc--
		bytesBack++

		if pc < 0 {
			// Out of memory...
			return pc, false
		}

		opcode := memory.Read(pc, true)
		instruction := instructions[opcode]

		if instruction == nil {
			continue
		}

		if bytesBack == getLength(instruction.AddressingMode) {
			return pc, true
		}
	}
}

func getLength(mode sim6502.AddressingMode) int {
	switch mode {
	case sim6502.IMMED, sim6502.REL, sim6502.ZPG, sim6502.ZPG_X, sim6502.ZPG_Y, sim6502.ZPG_REL, sim6502.ZPG_IND:
		return 2
	case sim6502.ABS, sim6502.ABS_X, sim6502.ABS_Y, sim6502.IND, sim6502.X_IND, sim6502.IND_Y, sim6502.IND_ABS_X:
		return 3
	default:
		return 1
	}
}

func annotate(addr uint16, symbols map[uint16]string) string {
	value, found := symbols[addr]
	if found {
		return value
	} else {
		return fmt.Sprintf("$%04X", addr)
	}
}

func disassembleInstruction(proc *sim6502.Processor, pc uint16, symbols map[uint16]string) (uint16, *disassembly) {
	memory := proc.Memory()
	opcode := memory.Read(pc, true)
	instruction := proc.Instructions()[opcode]

	switch instruction.AddressingMode {
	case sim6502.A, sim6502.IMPL:
		return pc + 1, &disassembly{
			address: pc,
			text:    fmt.Sprintf("%s", instruction.Impl.Mnemonic()),
		}

	case sim6502.IMMED:
		// The data is in the next operand
		data := memory.Read(pc+1, true)
		return pc + 2, &disassembly{
			address: pc,
			text:    fmt.Sprintf("%s $%02X", instruction.Impl.Mnemonic(), data),
		}

	case sim6502.ABS:
		// The data is in the memory cell referenced by the next two operands as $LLHH
		oper1 := memory.Read(pc+1, true)
		oper2 := memory.Read(pc+2, true)
		addr := uint16(oper1) | (uint16(oper2) << 8)
		return pc + 3, &disassembly{
			address: pc,
			text:    fmt.Sprintf("%s %s", instruction.Impl.Mnemonic(), annotate(addr, symbols)),
		}

	case sim6502.ABS_X:
		// The data is in the memory cell referenced by the next two operands (LL, HH) as ($HHLL plus X)
		oper1 := memory.Read(pc+1, true)
		oper2 := memory.Read(pc+2, true)
		baseAddr := (uint16(oper1) | (uint16(oper2) << 8))
		return pc + 3, &disassembly{
			address: pc,
			text:    fmt.Sprintf("%s %s,X", instruction.Impl.Mnemonic(), annotate(baseAddr, symbols)),
		}

	case sim6502.ABS_Y:
		// The data is in the memory cell referenced by the next two operands (LL HH) as ($HHLL plus Y)
		oper1 := memory.Read(pc+1, true)
		oper2 := memory.Read(pc+2, true)
		baseAddr := (uint16(oper1) | (uint16(oper2) << 8))
		return pc + 3, &disassembly{
			address: pc,
			text:    fmt.Sprintf("%s %s,Y", instruction.Impl.Mnemonic(), annotate(baseAddr, symbols)),
		}

	case sim6502.ZPG:
		// The data is in the memory cell referenced by the next operand (LL) as $00LL
		oper1 := memory.Read(pc+1, true)
		addr := uint16(oper1)
		return pc + 2, &disassembly{
			address: pc,
			text:    fmt.Sprintf("%s %s", instruction.Impl.Mnemonic(), annotate(addr, symbols)),
		}

	case sim6502.ZPG_X:
		// The data is in the memory cell referenced by the next operand (LL) as $00(LL+X)
		oper1 := memory.Read(pc+1, true)
		addr := uint16(oper1)
		return pc + 2, &disassembly{
			address: pc,
			text:    fmt.Sprintf("%s %s,X", instruction.Impl.Mnemonic(), annotate(addr, symbols)),
		}

	case sim6502.ZPG_Y:
		// The data is in the memory cell referenced by the next operand (LL) as $00(LL+Y)
		oper1 := memory.Read(pc+1, true)
		addr := uint16(oper1)
		return pc + 2, &disassembly{
			address: pc,
			text:    fmt.Sprintf("%s %s,Y", instruction.Impl.Mnemonic(), annotate(addr, symbols)),
		}

	case sim6502.IND:
		// The data is in the memory cell pointed to by the memory cell referenced by the next two operands (LL, HH)
		// as $HHLL
		oper1 := memory.Read(pc+1, true)
		oper2 := memory.Read(pc+2, true)
		addr := uint16(oper1) | (uint16(oper2) << 8)
		return pc + 3, &disassembly{
			address: pc,
			text:    fmt.Sprintf("%s (%s)", instruction.Impl.Mnemonic(), annotate(addr, symbols)),
		}

	case sim6502.X_IND:
		// The data is in the memory cell pointed to by the memory cell referenced by the next two operands (LL, HH)
		// as $(HHLL+X)
		oper1 := memory.Read(pc+1, true)
		oper2 := memory.Read(pc+2, true)
		addr := uint16(oper1) | (uint16(oper2) << 8)
		return pc + 3, &disassembly{
			address: pc,
			text:    fmt.Sprintf("%s (%s,X)", instruction.Impl.Mnemonic(), annotate(addr, symbols)),
		}

	case sim6502.IND_Y:
		// The data is in the memory cell pointed to by the memory cell referenced by the next two operands (LL, HH)
		// as $(HHLL+Y)
		oper1 := memory.Read(pc+1, true)
		oper2 := memory.Read(pc+2, true)
		addr := uint16(oper1) | (uint16(oper2) << 8)
		return pc + 3, &disassembly{
			address: pc,
			text:    fmt.Sprintf("%s (%s),Y", instruction.Impl.Mnemonic(), annotate(addr, symbols)),
		}

	case sim6502.REL:
		// Operand is a relative offset from the PC of the instruction byte
		// The address is calculated from that
		oper1 := memory.Read(pc+1, true)
		addr := pc
		if oper1&0x80 > 0 {
			addr = addr - uint16(comp2(oper1))
		} else {
			addr = addr + uint16(oper1)
		}
		return pc + 2, &disassembly{
			address: pc,
			text:    fmt.Sprintf("%s %s", instruction.Impl.Mnemonic(), annotate(addr, symbols)),
		}

	// // 65C02 Zero page relative mode
	// case sim502.ZPG_REL:
	// 	oper1 = p.registers.PC.Next()
	// 	data = p.memory.Read(uint16(oper1), false)
	// 	offset := p.registers.PC.Next()
	// 	oper2 = offset
	// 	addr = p.registers.PC.Current()
	// 	if oper1&0x80 > 0 {
	// 		addr = addr - uint16(comp2(offset))
	// 	} else {
	// 		addr = addr + uint16(offset)
	// 	}

	// 65C02 Indirect ABS_X
	case sim6502.IND_ABS_X:
		oper1 := memory.Read(pc+1, true)
		oper2 := memory.Read(pc+2, true)
		addr := uint16(oper1) | (uint16(oper2) << 8)
		return pc + 3, &disassembly{
			address: pc,
			text:    fmt.Sprintf("%s (%s),X", instruction.Impl.Mnemonic(), annotate(addr, symbols)),
		}

	// 65C02 indirect zeropage
	case sim6502.ZPG_IND:
		oper1 := memory.Read(pc+1, true)
		addr := uint16(memory.Read(uint16(oper1), true)) | (uint16(memory.Read(uint16(oper1)+1, true)) << 8)
		return pc + 2, &disassembly{
			address: pc,
			text:    fmt.Sprintf("%s (%04X)", instruction.Impl.Mnemonic(), annotate(addr, symbols)),
		}

	default:
		// Should never happen
		return pc + 1, &disassembly{
			address: pc,
			text:    "UNKNOWN",
		}
	}

}

func comp2(val uint8) uint8 {
	if val == 0 {
		return 0
	}
	return (val ^ 0xff) + 1
}
