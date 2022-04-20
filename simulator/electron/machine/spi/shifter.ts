export class Shifter {
  private _data: Array<number> = [0x00]
  private _currentByte: number = 0
  private _currentBit: number = 0

  empty: boolean = true

  constructor(initialData?: number[]) {
    if (initialData) {
      this._data = initialData
      this._currentByte = initialData.length - 1
      this._currentBit = 8
    }
  }

  byteLength() {
    return this._currentByte
  }

  bitLength() {
    return this._currentByte * 8 + this._currentBit
  }

  shiftIn(dataIn: number) {
    dataIn = dataIn & 0x1

    this.empty = false
    this._data[this._currentByte] |= dataIn << (8 - this._currentBit)

    if (++this._currentBit === 8) {
      this._currentBit = 0
      this._currentByte++
      if (this._currentByte > this._data.length - 1) this._data.push(0x0)
    }
  }

  shiftOut() {
    const dataOut =
      this._data[this._currentByte] & ~(1 << (8 - this._currentBit)) ? 0 : 1

    if (--this._currentBit < 0) {
      this._currentBit = 7

      if (--this._currentByte < 0) {
        this.empty = true
        this._currentByte = 0
        this._currentBit = 0
        this._data[0] = 0x0
      }
    }

    return dataOut
  }

  read(numBits: number) {
    let returnValue = 0

    for (let i = 0; i < numBits; i++) {
      returnValue = (returnValue << 1) | this.shiftOut()
    }

    return returnValue
  }
}
