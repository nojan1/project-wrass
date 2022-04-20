import { R1Flags, SdSpiCommands } from './commands'
import { SdStateHandlerBase } from './SdStateHandlerBase'

export class SdCardReadyState extends SdStateHandlerBase {
  protected handleCommand(
    command: SdSpiCommands,
    argument: number,
    crc: number
  ): number[] {
    return [R1Flags.ParameterError]
  }
}
