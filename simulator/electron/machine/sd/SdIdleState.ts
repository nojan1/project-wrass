import { R1Flags, SdSpiCommands } from './commands'
import { SdStateHandlerBase } from './SdStateHandlerBase'

export class SdCardIdleState extends SdStateHandlerBase {
  private _validCommands = [
    SdSpiCommands.CMD0,
    SdSpiCommands.CMD1,
    SdSpiCommands.CMD8,
  ]

  protected handleCommand(
    command: SdSpiCommands,
    argument: number,
    crc: number
  ): number[] {
    if (this._validCommands.includes(command)) {
      if (command === SdSpiCommands.CMD0 && crc !== 0b1001010) {
        return [R1Flags.CrcError]
      }

      return [
        command === SdSpiCommands.CMD0 ? R1Flags.InIdleState : R1Flags.Success,
      ]
    } else {
      console.log(`Got invalid command ${command}`)
      return [R1Flags.IllegalCommand]
    }
  }
}