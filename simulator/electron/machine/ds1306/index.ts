import { toHex } from '../../utils/output'
import { Shifter } from '../spi/shifter'
import { ISpiDeviceInterface } from '../spi/spiDeviceInterface'

export class DS1306 implements ISpiDeviceInterface {
  private _inShifter = new Shifter()
  private _outShifter = new Shifter()
  private _internalDate = new Date(0, 0, 0, 0, 0, 0)

  private _addressRecieved: number = -1
  private _userRam = new Uint8ClampedArray(96)

  selected: boolean = false

  constructor() {
    setInterval(this.update.bind(this), 1000)
  }

  onClock(dataIn: number): number {
    if (!this.selected) return 0
    this._inShifter.shiftIn(dataIn)

    if (this._inShifter.dataAvailable() === 8) {
      const data = this._inShifter.read(8)
      const output = this.onByte(data)
      if (output !== undefined) this._outShifter.write(output)
    }

    return this._outShifter.shiftOut()
  }

  private onByte(dataIn: number) {
    // console.log(`onByte recived ${dataIn}`)

    if (this._addressRecieved >= 0) {
      const effectiveAddress = this._addressRecieved & 0x7f
      const isWrite = (this._addressRecieved & 0x80) !== 0
      const f = (read: () => number, write: () => void) => {
        if (isWrite) {
          write()
          return 0xff
        } else {
          const value = read()
          console.log(
            `Read from address ${toHex(effectiveAddress, 2, true)}, got ${toHex(
              value,
              2,
              true
            )}`
          )
          return value
        }
      }

      this._addressRecieved = -1

      switch (effectiveAddress) {
        case 0x0:
          return f(
            () => this.toBcd(this._internalDate.getSeconds()),
            () => this._internalDate.setSeconds(this.fromBcd(dataIn))
          )
        case 0x1:
          return f(
            () => this.toBcd(this._internalDate.getMinutes()),
            () => this._internalDate.setMinutes(this.fromBcd(dataIn))
          )
        case 0x2:
          return f(
            () => this.toBcd(this._internalDate.getDay()),
            () => {}
          )
        case 0x3:
          return f(
            () => this.toBcd(this._internalDate.getHours()),
            () => this._internalDate.setHours(this.fromBcd(dataIn))
          )
        case 0x4:
          return f(
            () => this.toBcd(this._internalDate.getDate()),
            () => this._internalDate.setDate(this.fromBcd(dataIn))
          )
        case 0x5:
          return f(
            () => this.toBcd(this._internalDate.getMonth()),
            () => this._internalDate.setMonth(this.fromBcd(dataIn))
          )
        case 0x6:
          return f(
            () => this.toBcd(2000 - this._internalDate.getFullYear()),
            () => this._internalDate.setFullYear(2000 + this.fromBcd(dataIn))
          )
        // Alarms address 7 - E not implemented
        case 0xf:
          return 0 // Control register
        case 0x10:
          return 0 // Status register
        case 0x11:
          return 0 // Trickle charge register
      }

      // Handle address block
      if (effectiveAddress >= 0x20 && effectiveAddress <= 0x7f) {
        return f(
          () => this._userRam[effectiveAddress],
          () => (this._userRam[effectiveAddress] = dataIn)
        )
      }
    } else {
      // Byte is address
      console.log(`Address was set to ${toHex(dataIn, 2, true)}`)
      this._addressRecieved = dataIn
    }
  }

  private toBcd(x: number) {
    x &= 0xff
    return ((x / 10) << 4) | x % 10
  }

  private fromBcd(x: number) {
    x &= 0xff
    return (x >> 4) * 10 + (x & 0x0f)
  }

  private update() {
    this._internalDate.setSeconds(this._internalDate.getSeconds() + 1)
  }
}
