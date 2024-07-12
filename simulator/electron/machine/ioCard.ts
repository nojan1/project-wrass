import BusInterface from '6502.ts/lib/machine/bus/BusInterface'
import { MultiplexingBus } from './multiplexingBus'
import { VIA } from './via'

export class IoCard extends MultiplexingBus {
  constructor(private _systemVia: VIA, private _userVia: VIA) {
    super()
  }

  protected _getBus(address: number): BusInterface | null {
    if (address & 0x20) return null // Out of scope
    return address & 0x10 ? this._systemVia : this._userVia
  }
}
