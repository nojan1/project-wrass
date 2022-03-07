import BusInterface from '6502.ts/lib/machine/bus/BusInterface'
import Memory from '6502.ts/lib/machine/vanilla/Memory'
import { IoMultiplexer } from './io'

export class SystemBus extends Memory {
  private _rom: Memory
  private _io: BusInterface

  constructor() {
    super()

    this._rom = new Memory()
    this._io = new IoMultiplexer()
  }

  getSubBusForAddress(address: number): BusInterface | null {
    if (address <= 0x9fff) return null

    if (address >= 0xa000 && address <= 0xbfff) return this._io

    return this._rom
  }

  read(address: number): number {
    const subBus = this.getSubBusForAddress(address)
    if (subBus) return subBus.read(address)
    else return super.read(address)
  }

  peek(address: number): number {
    const subBus = this.getSubBusForAddress(address)
    if (subBus) return subBus.peek(address)
    else return super.peek(address)
  }

  readWord(address: number): number {
    const subBus = this.getSubBusForAddress(address)
    if (subBus) return subBus.readWord(address)
    else return super.readWord(address)
  }

  write(address: number, value: number): void {
    const subBus = this.getSubBusForAddress(address)
    if (subBus) subBus.write(address, value)
    else super.write(address, value)
  }

  poke(address: number, value: number): void {
    const subBus = this.getSubBusForAddress(address)
    if (subBus) subBus.poke(address, value)
    else super.poke(address, value)
  }
}
