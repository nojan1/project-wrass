import BusInterface from '6502.ts/lib/machine/bus/BusInterface'

export abstract class MultiplexingBus implements BusInterface {
  read(address: number): number {
    return this._getBus(address)?.read(address) ?? 0
  }

  peek(address: number): number {
    return this._getBus(address)?.peek(address) ?? 0
  }

  readWord(address: number): number {
    return this._getBus(address)?.readWord(address) ?? 0
  }

  write(address: number, value: number): void {
    this._getBus(address)?.write(address, value)
  }

  poke(address: number, value: number): void {
    this._getBus(address)?.poke(address, value)
  }

  protected abstract _getBus(address: number): BusInterface | null
}
