import BusInterface from '6502.ts/lib/machine/bus/BusInterface'
import Memory from '6502.ts/lib/machine/vanilla/Memory'
// import { toHex } from '../utils/output'
import { MemoryControlRegister } from './memoryControlRegister'

export class SystemBus extends Memory {
  private _rom: Memory
  private _bankedRam: Memory[]

  constructor(
    private _memoryControlRegister: MemoryControlRegister,
    private _io: BusInterface
  ) {
    super()

    this._rom = new Memory()
    this._bankedRam = [...new Array(32)].map(() => new Memory())
  }

  getSubBusForAddress(address: number): BusInterface | null {
    if (address === 0) return this._memoryControlRegister

    if (address >= 0x8000 && address <= 0x9fff) {
      const bank = this._memoryControlRegister.getMemoryBankNumber()
      // console.log(`Banked ram is current using bank number ${bank}`)
      return this._bankedRam[bank]
    }

    if (address >= 0xbc00 && address <= 0xbdff) return this._io

    if (
      address >= 0xbe00 &&
      address <= 0xbfff &&
      !this._memoryControlRegister.getRam4Enabled()
    ) {
      // console.error(
      //   `Got access to address ${toHex(
      //     address,
      //     4,
      //     true
      //   )} when RAM4 was not enabled, however IO2 is not implemented. Will be handled by main RAM`
      // )

      return null
    }

    if (
      address >= 0xc000 &&
      address <= 0xcfff &&
      !this._memoryControlRegister.getRam5Enabled()
    )
      return this._rom

    if (
      address >= 0xe000 &&
      address <= 0xffff &&
      !this._memoryControlRegister.getRam6Enabled()
    )
      return this._rom

    return null
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

  dumpMemory() {
    const dump = new Uint8ClampedArray(0x10000)
    for (let i = 0; i < dump.length; i++) {
      dump[i] = this.peek(i)
    }

    return dump
  }
}
