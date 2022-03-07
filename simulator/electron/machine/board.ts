import VanillaBoard from '6502.ts/lib/machine/vanilla/Board'
import Memory from '6502.ts/lib/machine/vanilla/Memory'
import { SystemBus } from './systemBus'

export const createBoard = (bus: SystemBus) => {
  class My6502ProjectBoard extends VanillaBoard {
    protected override _createBus(): Memory {
      return bus
    }
  }

  return new My6502ProjectBoard()
}
