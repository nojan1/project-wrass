import VanillaBoard from '6502.ts/lib/machine/vanilla/Board'
import { SystemBus } from './systemBus'

export class My6502ProjectBoard extends VanillaBoard {
  constructor(systemBus: SystemBus) {
    super()
    this._bus = systemBus
  }
}
