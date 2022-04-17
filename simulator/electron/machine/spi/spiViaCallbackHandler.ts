import { ViaCallbackHandler } from '../via'
import { ISpiDeviceInterface } from './spiDeviceInterface'

export class SpiViaCallbackHandler implements ViaCallbackHandler {
  private _selectedDeviceNum = 0x0
  private _lastMiso = false
  private _lastClock = false

  // eslint-disable-next-line no-useless-constructor
  constructor(private _spiDevices: { [key: number]: ISpiDeviceInterface }) {
    this.updateSelectedDevices()
  }

  portAWrite(value: number): void {
    value &= 0xff

    this._selectedDeviceNum = (value >> 5) & 0x7
    this.updateSelectedDevices()

    const clock = (value >> 2) & 0x1
    if (this._lastClock === false && clock === 1) {
      const mosi = !!(value & 0x1)
      this._lastMiso = Object.values(this._spiDevices).reduce<boolean>(
        (acc, cur) => acc || cur.onClock(mosi),
        false
      )
    }

    this._lastClock = !!clock
  }

  portBWrite(value: number): void {
    // Not used
  }

  portARead(): number | null {
    const data = this._lastMiso ? 1 : 0
    return data << 1
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
