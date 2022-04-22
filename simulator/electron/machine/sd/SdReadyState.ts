import fs from 'fs/promises'
import { app } from 'electron'
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
      const file = await fs.open(
        app.getAppPath() + '/testfiles/sd-card.img',
        'r'
      )
      const buffer = new Uint8Array(this._blockSize)
      await file.read(buffer, 0, this._blockSize, address * this._blockSize)

      await file.close()

      return [R1Flags.Success, 0b11111110, ...Array.from(buffer), 0xaa, 0xab]
    } catch (error) {
      console.log('Error reading image', error)
      return [R1Flags.ParameterError]
    }
  }
}
