import BusInterface from '6502.ts/lib/machine/bus/BusInterface'

const PORTB = 0
const PORTA = 1
const DDRB = 2
const DDRA = 3

export interface ViaCallbackHandler {
  portAWrite(value: number): void
  portBWrite(value: number): void
  portARead(): number | null
  portBRead(): number | null
}

export class VIA implements BusInterface {
  private _callbackHandlers: ViaCallbackHandler[] = []
  private _buffer = new Uint8ClampedArray(16)

  read(address: number): number {
    const register = address & 0xf

    if (register === PORTB)
      return (
        this._callbackHandlers.reduce(
          (acc, cur) => acc | (cur.portBRead() ?? 0),
          0
        ) & ~this._buffer[DDRB]
      )
    else if (register === PORTA)
      return (
        this._callbackHandlers.reduce(
          (acc, cur) => acc | (cur.portARead() ?? 0),
          0
        ) & ~this._buffer[DDRA]
      )
    else return this._buffer[register]
  }

  write(address: number, value: number): void {
    const register = address & 0xf

    if (register === PORTB)
      this._callbackHandlers.forEach(c =>
        c.portBWrite(value & this._buffer[DDRB])
      )
    else if (register === PORTA)
      this._callbackHandlers.forEach(c =>
        c.portAWrite(value & this._buffer[DDRA])
      )
    else this._buffer[register] = value
  }

  peek(address: number): number {
    return this.read(address)
  }

  poke(address: number, value: number): void {
    this.write(address, value)
  }

  registerCallbackHandler(handler: ViaCallbackHandler) {
    this._callbackHandlers.push(handler)
  }

  readWord(address: number): number {
    throw new Error('Method not implemented.')
  }
}
