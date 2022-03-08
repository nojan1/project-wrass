import BusInterface from '6502.ts/lib/machine/bus/BusInterface'

const PORTB = 0
const PORTA = 1
const DDRB = 2
const DDRA = 3

export class VIA implements BusInterface {
  private _buffer = new Uint8ClampedArray(16)

  read(address: number): number {
    console.log(`VIA read from register ${address & 0xf}`)
    return this._buffer[address & 0xf]
  }

  write(address: number, value: number): void {
    const register = address & 0xf
    console.log(`VIA got write to register ${register}`)
    this._buffer[register] = value
  }

  peek(address: number): number {
    return this.read(address)
  }

  poke(address: number, value: number): void {
    this.write(address, value)
  }

  readWord(address: number): number {
    throw new Error('Method not implemented.')
  }
}
