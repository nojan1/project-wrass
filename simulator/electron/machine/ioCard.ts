import BusInterface from '6502.ts/lib/machine/bus/BusInterface'
import { MultiplexingBus } from './multiplexingBus'
import { VIA } from './via'

export class IoCard extends MultiplexingBus {
  constructor(private _via1: VIA, private _via2 = new VIA()) {
    super()
  }

  protected _getBus(address: number): BusInterface | null {
    if (address & 0x20) return null // Out of scope
    return address & 0x10 ? this._via2 : this._via1
  }
}
