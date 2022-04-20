import { ViaCallbackHandler } from '../via'
import { ISpiDeviceInterface } from './spiDeviceInterface'

export class SpiViaCallbackHandler implements ViaCallbackHandler {
  private _selectedDeviceNum = 0x0
  private _lastMiso = 0
  private _lastClock = false
  private _value = 0x0

  // eslint-disable-next-line no-useless-constructor
  constructor(private _spiDevices: { [key: number]: ISpiDeviceInterface }) {
    this.updateSelectedDevices()
  }

  portAWrite(value: number): void {
    this._value = value & 0xff

    this._selectedDeviceNum = (this._value >> 4) & 0x7
    this.updateSelectedDevices()

    const clock = (this._value >> 2) & 0x1
    const mosi = this._value & 0x1

    if (this._lastClock === false && clock === 1) {
      this._lastMiso = Object.values(this._spiDevices).reduce<number>(
        (acc, cur) => acc | cur.onClock(mosi),
        0
      )
    }

    this._lastClock = !!clock
  }

  portBWrite(value: number): void {
    // Not used
  }

  portARead(): number | null {
    return (this._value & 0xfd) | (this._lastMiso << 1)
  }

  portBRead(): number | null {
    return null
  }

  private updateSelectedDevices() {
    Object.entries(this._spiDevices).forEach(([lineNum, device]) => {
      device.selected = +lineNum === this._selectedDeviceNum
    })
  }
}
