import { R1Flags, SdSpiCommands } from './commands'
import { SdStateHandlerBase } from './SdStateHandlerBase'
import { SdCardState } from './states'

export class SdCardIdleState extends SdStateHandlerBase {
  private _loadingTicks: number = 0

  private _validCommands = [
    SdSpiCommands.CMD0,
    SdSpiCommands.CMD1,
    SdSpiCommands.CMD8,
  ]

  protected handleCommand(
    command: SdSpiCommands,
    argument: number,
    crc: number
  ): Promise<number[]> {
    if (this._validCommands.includes(command)) {
      if (command === SdSpiCommands.CMD0 && crc !== 0b1001010) {
        return Promise.resolve([R1Flags.CrcError])
      }

      this._isBusy = true
      this._loadingTicks = 5

      if (command === SdSpiCommands.CMD0) {
        this._requestedStateChange = SdCardState.Ready
        return Promise.resolve([R1Flags.InIdleState])
      }

      return Promise.resolve([R1Flags.Success])
    } else {
      console.log(`Got invalid command ${command}`)
      return Promise.resolve([R1Flags.IllegalCommand])
    }
  }

  protected override clockTick(): void {
    if (this._loadingTicks > 0) {
      if (--this._loadingTicks === 0) this._isBusy = false
    }
  }
}
