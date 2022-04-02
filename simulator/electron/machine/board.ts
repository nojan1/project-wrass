import VanillaBoard from '6502.ts/lib/machine/vanilla/Board'
import Factory, { Create65C02Cpu } from '6502.ts/lib/machine/cpu/Factory'
import Memory from '6502.ts/lib/machine/vanilla/Memory'
import { SystemBus } from './systemBus'

export const createBoard = (bus: SystemBus) => {
  class My6502ProjectBoard extends VanillaBoard {
    constructor() {
      super(bus => Create65C02Cpu(Factory.Type.stateMachine, bus))
    }

    protected override _createBus(): Memory {
      return bus
    }
  }

  return new My6502ProjectBoard()
}
