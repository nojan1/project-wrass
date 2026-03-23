package main

type IC74165 struct {
	parallelLoadB bool
	clockEnableB  bool
	lastClock     bool
	q7            uint8
	ds            uint8
	parallelInput uint8
	latchedData   uint8
}

func (s *IC74165) setClock(newClock bool) {
	if !s.parallelLoadB {
		// ParallelLoad is active.. no shifting will happen
		// fmt.Printf("165 latched output %08b \n", s.parallelInput)
		s.latchedData = s.parallelInput
		s.q7 = (s.parallelInput >> 7) & 1
	} else if !s.clockEnableB && !s.lastClock && newClock {
		// We have a LOW to HIGH clock transition... with an enabled clock
		s.q7 = (s.latchedData >> 7) & 1
		s.latchedData = (s.latchedData << 1) | (s.ds & 0x01)
		// fmt.Printf("165 was clocked, q7==%d, data=%08b\n", s.q7, s.latchedData)
	}

	s.lastClock = newClock
}
