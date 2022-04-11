import React, { createContext, useContext, useEffect, useState } from 'react'
import BoardInterface from '6502.ts/lib/machine/board/BoardInterface'
import CpuInterface from '6502.ts/lib/machine/cpu/CpuInterface'
import { Breakpoint } from '../../electron/types/breakpoint'

export interface SimplifiedTrap {
  reason: BoardInterface.TrapReason
  message?: string
}

export interface IMachineContext {
  stateObject?: CpuInterface.State
  disassembly?: string
  stackDump?: string
  lastTrap?: SimplifiedTrap
  debuggerRunning?: boolean
  memoryDump?: Uint8Array
  initialBreakpoints?: Breakpoint[]
}

const MachineContext = createContext<IMachineContext>({})

export const MachineContextProvider: React.FunctionComponent = ({
  children,
}) => {
  const [state, setState] = useState<IMachineContext>({})

  useEffect(() => {
    if (!window.Main) return

    window.Main.on('dissassembly-state-update', (data: any) =>
      setState(x => ({ ...x, disassembly: data }))
    )
    window.Main.on('stack-dump-update', (data: any) =>
      setState(x => ({ ...x, stackDump: data }))
    )
    window.Main.on('last-trap-update', (data: any) =>
      setState(x => ({ ...x, lastTrap: data }))
    )
    window.Main.on('debugger-running', (data: any) =>
      setState(x => ({ ...x, debuggerRunning: data }))
    )
    window.Main.on('cpu-state-update', (data: any) => {
      setState(x => ({ ...x, stateObject: data }))
    })
    window.Main.on('memory-dump', (data: any) => {
      setState(x => ({ ...x, memoryDump: data }))
    })
    window.Main.on('initial-breakpoints', (data: any) => {
      setState(x => ({ ...x, initialBreakpoints: data }))
    })

    window.Main.updateRequest()
  }, [window.Main])

  return (
    <MachineContext.Provider value={state}>{children}</MachineContext.Provider>
  )
}

export const useMachineContext = () => useContext(MachineContext)
