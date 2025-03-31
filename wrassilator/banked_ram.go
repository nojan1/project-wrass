package main

type BankedRam struct {
	memControl *MemControl
	data [1024 * 512]uint8
}

func (s *BankedRam) Write(addr uint16, val uint8) {
	finalAddr := (uint32(s.memControl.GetMemoryBank()) << 13) | (uint32(addr) & 0x1FFF);
	s.data[finalAddr] = val
}

func (s *BankedRam) Read(addr uint16, internal bool) uint8 {
	finalAddr := (uint32(s.memControl.GetMemoryBank()) << 13) |  (uint32(addr) & 0x1FFF);
	return s.data[finalAddr]
}