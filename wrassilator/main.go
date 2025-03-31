package main

import (
	"bufio"
	"flag"
	"os"

	rl "github.com/gen2brain/raylib-go/raylib"
	sim6502 "github.com/nojan1/sim6502/pkg"
)

type SimulatorState struct {
	isRunning bool
}

func Draw(gpu *GPU, proc *sim6502.Processor, memControl *MemControl) {
	rl.BeginDrawing()

	rl.ClearBackground(rl.DarkBlue)
	
	gpu.DrawColorAttributes(10, 10)
	gpu.DrawFullFrameBuffer(10, 20 + (TotalCharRows * 8))
	gpu.DrawTileMap(10, 40 + (16 * TotalCharRows))
	gpu.DrawColors(20 + (16 * 16), 40 + (16 * TotalCharRows))
	
	gpu.DrawFrameBuffer(20 + (8 * TotalCharCols), 10)
	
	DrawRegisterStatusPanel(20 + (8 * TotalCharCols) + 650, 10, proc, memControl)
	
	rl.EndDrawing()
}

func main() {
	binaryFile := flag.String("file", "", "The path to the binary file that should be loaded into memory")
	// listingFile := flag.String("listing", "", "The path to a listing file for the binary, it will be used to decorate disassembly and set breakpoints")
	loadAddress := flag.Uint("load-address", 0xC000, "The start address to where the binary should be stored in memory")
	trace := flag.Bool("trace", false, "Enable tracing of CPU instructions")

	flag.Parse()

	if(*binaryFile == "") {
		flag.Usage()
		return
	}

	f, err := os.Open(*binaryFile)
	if err != nil {
		panic(err)
	}
	defer f.Close()
	
	bus := &SystemBus{}

	proc := sim6502.NewProcessor(bus).
		SetModel65C02().
		SetClock(4000000) //4MHz

	gpu, io, uart := bus.InitBus(proc)

	proc.Load(bufio.NewReader(f), uint16(*loadAddress))
	proc.Registers().PC.Init(proc)

	proc.SetOption(sim6502.Trace, *trace) 
	
	rl.InitWindow(1500, 820, "Wrassilator - Your WRASS 1 compatible simulator")
	defer rl.CloseWindow()

	rl.SetTargetFPS(60)

	simulatorState := SimulatorState{
		isRunning: false,
	}

	userBreakpointHandler := UserBreakpointHandler {
		simulatorState: &simulatorState,
	}

	// Kind of disabled
	proc.SetBreakpoint(0xFFFF, &userBreakpointHandler)

	done := make(chan bool)
	uart.Start(&simulatorState, done)

	for !rl.WindowShouldClose() {
		Draw(gpu, proc, &bus.memControl);

		keyPressed := rl.GetKeyPressed()
		switch keyPressed {
		case rl.KeyF5:
			if simulatorState.isRunning {
				proc.Stop()
				simulatorState.isRunning = false
			} else {
				go proc.RunFrom(proc.Registers().PC.Current())
				simulatorState.isRunning = true
			}
		case rl.KeyF10:
			if simulatorState.isRunning {
				proc.Stop()
				simulatorState.isRunning = false
			} else {
				err, _ := proc.Step()
	
				if err != nil {
					panic(err)
				}
			}
		case 0:
			// Ignore
		default:
			io.keyboard.StoreKey(keyPressed, proc)
		}
	}

	proc.Stop()
	simulatorState.isRunning = false
	done <- true
}