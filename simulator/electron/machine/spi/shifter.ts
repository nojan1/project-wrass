export class Shifter {
  private _data: Array<number> = [0x00]

  private _currentWriteByte: number = 0
  private _currentWriteBit: number = 0

  private _currentReadByte: number = 0
  private _currentReadBit: number = 0

  empty: boolean = true

  constructor(initialData?: number[]) {
    if (initialData) {
      this._data = initialData
      this._currentWriteByte = initialData.length
      this._currentWriteBit = 0
      this.empty = false
    }
  }

  byteLength() {
    return this._currentWriteByte
  }

  bitLength() {
    return this._currentWriteByte * 8 + this._currentWriteBit
  }

  dataAvailable() {
    return this.bitLength() - (this._currentReadByte * 8 + this._currentReadBit)
  }

  shiftIn(dataIn: number) {
    dataIn = dataIn & 0x1

    if (this._currentWriteByte > this._data.length - 1) this._data.push(0x0)

    this.empty = false
    this._data[this._currentWriteByte] |= dataIn << (7 - this._currentWriteBit)

    // console.log(
    //   `CurrentByte: ${this._currentWriteByte}, CurrentBit: ${this._currentWriteBit}`
    // )

    if (++this._currentWriteBit === 8) {
      this._currentWriteBit = 0
      this._currentWriteByte++

      if (this._currentWriteByte > this._data.length - 1) this._data.push(0x0)
    }

    // console.log(this._data.map(x => x.toString(2).padStart(8, '0')).join(' '))
  }

  shiftOut() {
    if (this.empty) return 0

    const dataOut =
      (this._data[this._currentReadByte] &
        (1 << (7 - this._currentReadBit))) ===
      0
        ? 0
        : 1

    // console.log(this._data.map(x => x.toString(2).padStart(8, '0')).join(' '))
    // console.log(`byte: ${this._currentReadByte}, bit: ${this._currentReadBit}`)

    if (++this._currentReadBit > 7) {
      this._currentReadBit = 0

      if (++this._currentReadByte > this._data.length - 1) {
        this.empty = true
        this._currentReadByte--
      }
    }

    console.log(`Shifting out ${dataOut}, bits left ${this.dataAvailable()}`)
    return dataOut
  }

  read(numBits: number) {
    let returnValue = 0

    for (let i = 0; i < numBits; i++) {
      returnValue = (returnValue << 1) | this.shiftOut()
    }

    return returnValue
  }

  write(data: number) {
    for (let i = 0; i < 8; i++) {
      this.shiftIn(data & (1 << (7 - i)) ? 1 : 0)
    }
  }
}
