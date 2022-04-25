import fs from 'fs/promises'
import path from 'path'
import { R1Flags, SdSpiCommands } from './commands'
import { SdStateHandlerBase, StateChangeCallback } from './SdStateHandlerBase'

export class SdCardReadyState extends SdStateHandlerBase {
  private _blockSize = 0

  // eslint-disable-next-line no-useless-constructor
  constructor(
    private _sdImagePath: string,
    _stateChangeCallback: StateChangeCallback
  ) {
    super(_stateChangeCallback)
  }

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
      const file = await fs.open(this.getSdImagePath(), 'r')
      const buffer = new Uint8Array(this._blockSize)
      await file.read(buffer, 0, this._blockSize, address * this._blockSize)

      await file.close()

      return [R1Flags.Success, 0b11111110, ...Array.from(buffer), 0xaa, 0xab]
    } catch (error) {
      console.log('Error reading image', error)
      return [R1Flags.ParameterError]
    }
  }

  private getSdImagePath() {
    if (!this._sdImagePath) throw new Error('No image path provided')
    return path.resolve(this._sdImagePath)
  }
}
