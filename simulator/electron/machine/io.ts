import BusInterface from '6502.ts/lib/machine/bus/BusInterface'

export class IoMultiplexer implements BusInterface {
  read(address: number): number {
    throw new Error('Method not implemented.')
  }

  peek(address: number): number {
    throw new Error('Method not implemented.')
  }

  readWord(address: number): number {
    throw new Error('Method not implemented.')
  }

  write(address: number, value: number): void {
    throw new Error('Method not implemented.')
  }

  poke(address: number, value: number): void {
    throw new Error('Method not implemented.')
  }
}
