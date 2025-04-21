package main

import (
	sim6502 "github.com/nojan1/sim6502/pkg"
)

type SystemBus struct {
	backingMemory [64 * 1024]uint8
	rom [32 * 1024]uint8
	memControl MemControl

	bankedRam *BankedRam
	memControlRegister *MemControlRegister
	gpu *GPU
	uart *UART
	io *IoCard
}

func (m *SystemBus) InitBus (proc *sim6502.Processor) (gpu *GPU, io *IoCard, uart *UART) {
	irqMultiplexer := &IRQMultiplexer{ proc: proc }

	m.memControl = MemControl(0)
	m.memControlRegister = &MemControlRegister{ memControl: &m.memControl }
	
	m.bankedRam = &BankedRam{ memControl: &m.memControl }

	m.gpu = &GPU{ irqMultiplexer: irqMultiplexer }
	m.gpu.Init()

	m.io = NewIoCard(irqMultiplexer)

	m.uart = &UART{}

	return m.gpu, m.io, m.uart
}

func (m *SystemBus) Clear() {
	for i := 0; i < len(m.backingMemory); i++ {
		m.backingMemory[i] = 0x00
	}
}

func (m *SystemBus) Write(addr uint16, val uint8) {
	if addr >= 0xE000 && m.memControl.Rom2Enabled() {
		// ROM (2) / RAM (6)
		m.rom[addr & 0x7FFF] = val
		return
	} else if addr >= 0xC000 && addr <= 0xDFFF && m.memControl.Rom1Enabled() {
		// ROM (1) / RAM (5)
		m.rom[addr & 0x7FFF] = val
		return
	} else if addr >= 0xBE00 && addr <= 0xBFFF && m.memControl.Io2Enabled() {
		// IO (2) / RAM (4) 
		
		/// Currently there is nothing in IO space 2
		return
	} else if addr >= 0xBC00 && addr <= 0xDFFF  {
		// IO (1) 

		if addr >= 0xBC00 && addr <= 0xBC3F {
			m.io.Write(addr, val)
		} else if addr >= 0xBC40 && addr <= 0xBC7F{
			m.gpu.Write(addr, val)
		} else if addr >= 0xBC80 && addr <= 0xBCBF{
			// LCD...
		} else if addr >= 0xBCC0 && addr <= 0xBCFF{
			m.uart.Write(addr, val)
		}
		return
	} else if addr >= 0x8000 && addr <= 0x9FFF {
		// RAM (2) 
		m.bankedRam.Write(addr, val)
		return
	} else if addr == 0x000 {
		// Memcontrol register
		m.memControlRegister.Write(addr, val)
		return
	}

	// RAM (1) / RAM (3) / Extra enabled memory
	m.backingMemory[addr] = val
}

func (m *SystemBus) Read(addr uint16, internal bool) uint8 {
	if addr >= 0xE000 && m.memControl.Rom2Enabled() {
		// ROM (2) / RAM (6)
		return m.rom[addr & 0x7FFF]
	} else if addr >= 0xC000 && addr <= 0xDFFF && m.memControl.Rom1Enabled() {
		// ROM (1) / RAM (5)
		return m.rom[addr & 0x7FFF]
	} else if addr >= 0xBE00 && addr <= 0xBFFF && m.memControl.Io2Enabled() {
		// IO (2) / RAM (4) 
		
		/// Currently there is nothing in IO space 2
		return 0
	} else if addr >= 0xBC00 && addr <= 0xDFFF  {
		// IO (1) 
		if addr >= 0xBC00 && addr <= 0xBC3F {
			return m.io.Read(addr, internal)
		} else if addr >= 0xBC40 && addr <= 0xBC7F{
			return m.gpu.Read(addr, internal)
		} else if addr >= 0xBC80 && addr <= 0xBCBF{
			// LCD...
		} else if addr >= 0xBCC0 && addr <= 0xBCFF{
			return m.uart.Read(addr, internal)
		} else {
			return 0
		}
	} else if addr >= 0x8000 && addr <= 0x9FFF {
		// RAM (2) 
		return m.bankedRam.Read(addr, internal)
	}  else if addr == 0x000 {
		// Memcontrol register
		return m.memControlRegister.Read(addr, internal)
	}

	// RAM (1) / RAM (3) / Extra enabled memory
	return m.backingMemory[addr]
}