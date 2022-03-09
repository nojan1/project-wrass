import CpuInterface from '6502.ts/lib/machine/cpu/CpuInterface'
import { ipcMain } from 'electron'
import { Scancodes } from './scancodes'
import { ViaCallbackHandler } from './via'

export class KeyboardController implements ViaCallbackHandler {
  private _cpu: CpuInterface | null = null
  private _pendingData: number | null = null

  constructor() {
    ipcMain.on('keydown', (_, code: string) => {
      const scancode = Scancodes[code]
      if (!scancode) return

      this._pendingData = scancode
      this._cpu?.setInterrupt(true)
    })

    ipcMain.on('keyup', (_, code: string) => {
      const scancode = Scancodes[code]
      if (!scancode) return

      this._pendingData = scancode
      this._cpu?.setInterrupt(true)
    })
  }

  attachCpu(cpu: CpuInterface) {
    this._cpu = cpu
  }

  portARead(): number | null {
    if (this._pendingData) {
      const dataToReturn = this._pendingData
      this._pendingData = null

      return dataToReturn
    }

    return null
  }

  portAWrite(value: number): void {}
  portBWrite(value: number): void {}
  portBRead(): number | null {
    return null
  }
}
