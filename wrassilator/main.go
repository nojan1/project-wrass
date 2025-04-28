package main

import (
	"bufio"
	"flag"
	"os"

	rl "github.com/gen2brain/raylib-go/raylib"
	sim6502 "github.com/nojan1/sim6502/pkg"
)

type SimulatorState struct {
	isRunning             bool
	inBreakpoint          bool
	proc                  *sim6502.Processor
	userBreakpointHandler *UserBreakpointHandler
	bus                   *SystemBus
	done                  chan bool
}

func createSimulatorState(binaryFile string, loadAddress uint16, trace bool, breakpoints string, interactive bool) *SimulatorState {
	f, err := os.Open(binaryFile)
	if err != nil {
		panic(err)
	}
	defer f.Close()

	bus := &SystemBus{}

	proc := sim6502.NewProcessor(bus).
		SetModel65C02().
		SetClock(4000000) //4MHz

	bus.InitBus(proc)

	proc.Load(bufio.NewReader(f), loadAddress)
	proc.Registers().PC.Init(proc)

	proc.SetOption(sim6502.Trace, trace)

	simulatorState := &SimulatorState{
		isRunning:    false,
		inBreakpoint: false,
		proc:         proc,
		bus:          bus,
		done:         make(chan bool),
	}

	userBreakpointHandler := UserBreakpointHandler{
		simulatorState: simulatorState,
		proc:           proc,
	}

	userBreakpointHandler.Prepare(breakpoints)

	simulatorState.userBreakpointHandler = &userBreakpointHandler

	bus.uart.Start(simulatorState, interactive)

	return simulatorState
}

func (s *SimulatorState) run(background bool) {
	s.userBreakpointHandler.StepOutOfBreakStateIfNeeded()
	s.isRunning = true

	if background {
		go s.proc.RunFrom(s.proc.Registers().PC.Current())
	} else {
		s.proc.RunFrom(s.proc.Registers().PC.Current())
	}
}

func (s *SimulatorState) stop() {
	s.proc.Stop()
	s.isRunning = false
}

func (s *SimulatorState) terminate() {
	s.stop()
	s.done <- true
}

func (s *SimulatorState) toggle(background bool) {
	if s.isRunning {
		s.stop()
	} else {
		s.run(background)
	}
}

func (s *SimulatorState) step() {
	if !s.userBreakpointHandler.StepOutOfBreakStateIfNeeded() {
		err, _ := s.proc.Step()

		if err != nil {
			panic(err)
		}
	}
}

func Draw(simulatorState *SimulatorState) {
	gpu := simulatorState.bus.gpu

	rl.BeginDrawing()

	rl.ClearBackground(rl.DarkBlue)

	gpu.DrawColorAttributes(10, 10)
	gpu.DrawFullFrameBuffer(10, 20+(TotalCharRows*8))
	gpu.DrawTileMap(10, 40+(16*TotalCharRows))
	gpu.DrawColors(20+(16*16), 40+(16*TotalCharRows))

	gpu.DrawFrameBuffer(20+(8*TotalCharCols), 10)

	DrawRegisterStatusPanel(20+(8*TotalCharCols)+650, 10, simulatorState.proc, &simulatorState.bus.memControl)

	rl.EndDrawing()
}

func main() {
	binaryFile := flag.String("file", "", "The path to the binary file that should be loaded into memory")
	// listingFile := flag.String("listing", "", "The path to a listing file for the binary, it will be used to decorate disassembly and set breakpoints")
	loadAddress := flag.Uint("load-address", 0xC000, "The start address to where the binary should be stored in memory")
	trace := flag.Bool("trace", false, "Enable tracing of CPU instructions")
	breakpoints := flag.String("breakpoint", "", "List of address to break at, separated by ,")
	interactive := flag.Bool("interactive", false, "The uart will bind to stdin / stdout, implied in headless mode")
	headless := flag.Bool("headless", false, "Run the simulator in headless mode (no graphics output)")
	start := flag.Bool("start", false, "Start simulation right away, implied in headless mode")

	flag.Parse()

	if *binaryFile == "" {
		flag.Usage()
		return
	}

	simulatorState := createSimulatorState(*binaryFile, uint16(*loadAddress), *trace, *breakpoints, *interactive || *headless)

	if !*headless {
		rl.InitWindow(1500, 820, "Wrassilator - Your WRASS 1 compatible simulator")
		defer rl.CloseWindow()

		rl.SetTargetFPS(60)

		if *start {
			simulatorState.run(true)
		}

		for !rl.WindowShouldClose() {
			Draw(simulatorState)

			keyPressed := rl.GetKeyPressed()
			switch keyPressed {
			case rl.KeyF5:
				simulatorState.toggle(true)
			case rl.KeyF10:
				if simulatorState.isRunning {
					simulatorState.stop()
				} else {
					simulatorState.step()
				}
			case 0:
				// Ignore
			default:
				simulatorState.bus.io.keyboard.StoreKey(keyPressed, simulatorState.proc)
			}
		}

		simulatorState.terminate()
	}else {
		// Just run the simulator when in headless mode.. it will run on the mainthread till the user kills the application?
		simulatorState.run(false)
	}
}
