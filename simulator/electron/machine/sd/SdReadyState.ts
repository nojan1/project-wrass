import fs from 'fs/promises'
import { R1Flags, SdSpiCommands } from './commands'
import { SdStateHandlerBase } from './SdStateHandlerBase'

export class SdCardReadyState extends SdStateHandlerBase {
  private _blockSize = 0

  protected handleCommand(
    command: SdSpiCommands,
    argument: number,
    _: number
  ): Promise<number[]> {
    switch (command) {
      case SdSpiCommands.CMD16:
        // Set block size
        this._blockSize = argument
        return Promise.resolve([R1Flags.Success])
      case SdSpiCommands.CMD17:
        return this.readBlock(argument)
      default:
        return Promise.resolve([R1Flags.ParameterError])
    }
  }

  protected override clockTick(): void {}

  private async readBlock(address: number): Promise<number[]> {
    try {
      const file = await fs.open('../sd-card.img', 0)
      const buffer = new Uint8Array()
      await fs.read(file, buffer, address * this._blockSize, this._blockSize)

      return [R1Flags.Success, 0b11111110, ...Array.from(buffer), 0xaa, 0xab]
    } catch (error) {
      return [R1Flags.ParameterError]
    }
  }
}
