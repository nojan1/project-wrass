import BusInterface from '6502.ts/lib/machine/bus/BusInterface'
import { SendDataCallback } from '.'

export class MemoryControlRegister implements BusInterface {
  private _data: number = 0b00000001

  // eslint-disable-next-line no-useless-constructor
  constructor(private _sendData: SendDataCallback) {}

  getMemoryBankNumber() {
    return (this._data & 0b11111000) >> 3
  }

  getRam4Enabled(): boolean {
    return !!(this._data & 0b00000001)
  }

  getRam5Enabled(): boolean {
    return !!(this._data & 0b00000010)
  }

  getRam6Enabled(): boolean {
    return !!(this._data & 0b00000100)
  }

  read(): number {
    return this._data
  }

  peek(): number {
    return this._data
  }

  readWord(): number {
    return this._data
  }

  write(_: number, value: number): void {
    this._data = value
    this._sendData('blinkenlights-update', (value >> 4) & 0xf)
  }

  poke(_: number, value: number): void {
    this.write(_, value)
  }
}
