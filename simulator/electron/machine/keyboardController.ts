import CpuInterface from '6502.ts/lib/machine/cpu/CpuInterface'
import { ipcMain } from 'electron'
import { deferWork } from '../utils/deferWork'
import { Scancodes } from './scancodes'
import { ViaCallbackHandler } from './via'

export class KeyboardController implements ViaCallbackHandler {
  private _cpu: CpuInterface | null = null
  private _pendingData: number[] = []

  constructor() {
    ipcMain.on('keydown', (_, code: string) => {
      const scancode = Scancodes[code]
      if (!scancode) return

      this._pendingData = [scancode]
      this._cpu?.setInterrupt(true)
    })

    ipcMain.on('keyup', (_, code: string) => {
      const scancode = Scancodes[code]
      if (!scancode) return

      this._pendingData = [0xf0, scancode]
      this._cpu?.setInterrupt(true)
    })
  }

  attachCpu(cpu: CpuInterface) {
    this._cpu = cpu
  }

  portARead(): number | null {
    this._cpu?.setInterrupt(false)

    const data = this._pendingData.pop() ?? null

    if (this._pendingData.length > 0) {
      deferWork(() => this._cpu?.setInterrupt(true))
    }

    return data
  }

  portAWrite(value: number): void {}
  portBWrite(value: number): void {}
  portBRead(): number | null {
    return null
  }
}
