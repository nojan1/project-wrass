package main

type MemControl uint8

func (s *MemControl) GetMemoryBank() uint8 {
	return (uint8(*s) >> 3) & 0x1F;
}

func (s *MemControl) Io2Enabled() bool {
	return uint8(*s) & 0x1 == 0
}

func (s *MemControl) Rom1Enabled() bool {
	return (uint8(*s) >> 1) & 0x1 == 0
}

func (s *MemControl) Rom2Enabled() bool {
	return (uint8(*s) >> 2) & 0x1 == 0
}

type MemControlRegister struct {
	memControl *MemControl
}

func (s *MemControlRegister) Write(addr uint16, val uint8) {
	*(s.memControl) = MemControl(val)
}

func (s *MemControlRegister) Read(addr uint16, internal bool) uint8 {
	return uint8(*s.memControl)
}