import { Shifter } from '../spi/shifter'
import { R1Flags, SdSpiCommands } from './commands'
import { ISdCardStateHandler } from './sdState'
import { SdCardState } from './states'

export abstract class SdStateHandlerBase implements ISdCardStateHandler {
  private _buffer = new Shifter()
  private _isSending = false

  onClock(
    dataIn: number,
    selected: boolean
  ): {
    dataOut: number
    newState?: SdCardState | undefined
  } {
    if (!selected) return { dataOut: 0 }

    if (this._isSending) {
      const dataOut = this._buffer.shiftOut()
      if (this._buffer.empty) this._isSending = false

      return { dataOut }
    } else {
      this._buffer.shiftIn(dataIn)
      if (this._buffer.bitLength() === 48) {
        // Got a complete command
        this.processCommand()
      }

      return { dataOut: 0 }
    }
  }

  private processCommand() {
    // Start bits
    if (this._buffer.shiftOut() !== 0 || this._buffer.shiftOut() !== 1) {
      console.log('Got invalid start bits')
      this._buffer = new Shifter([
        R1Flags.ParameterError, // Not sure if this is right...
      ])
    }

    const commandIndex = this._buffer.read(6)
    const argument = this._buffer.read(32)
    const crc = this._buffer.read(7)
    const stopBit = this._buffer.shiftOut()

    if (stopBit !== 1) {
      console.log('Got invalid stop bit')
      this._buffer = new Shifter([
        R1Flags.ParameterError, // Not sure if this is right...
      ])
    }

    const response = this.handleCommand(commandIndex, argument, crc)
    this._buffer = new Shifter(response)
  }

  protected abstract handleCommand(
    command: SdSpiCommands,
    argument: number,
    crc: number
  ): number[]
}
