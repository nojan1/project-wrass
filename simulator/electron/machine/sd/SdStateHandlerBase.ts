import { Shifter } from '../spi/shifter'
import { R1Flags, SdSpiCommands } from './commands'
import { ISdCardStateHandler } from './sdState'
import { SdCardState } from './states'

export type StateChangeCallback = (newState: SdCardState) => void

export abstract class SdStateHandlerBase implements ISdCardStateHandler {
  private _buffer = new Shifter()
  private _isSending = false
  protected _isBusy = false
  protected _requestedStateChange: SdCardState | undefined

  // eslint-disable-next-line no-useless-constructor
  constructor(protected _stateChangeCallback: StateChangeCallback) {}

  onClock(
    dataIn: number,
    selected: boolean
  ): {
    dataOut: number
    newState?: SdCardState | undefined
  } {
    if (!selected) return { dataOut: 0 }

    this.clockTick()

    if (this._isSending) {
      const dataOut = this._isBusy ? 1 : this._buffer.shiftOut()
      if (!this._isBusy && this._buffer.empty) {
        console.log('all bits sent')
        this._isSending = false
        this._buffer = new Shifter()

        if (this._requestedStateChange) {
          this._stateChangeCallback(this._requestedStateChange)
          this._requestedStateChange = undefined
        }
      }

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

    console.log(`
        commandIndex=${commandIndex},
        argument=${argument},
        crc=${crc},
        stopbit=${stopBit},
    `)

    this._isBusy = true
    this._isSending = true

    this.handleCommand(commandIndex, argument, crc).then(response => {
      this._buffer = new Shifter(response)
      this._isBusy = false
    })
  }

  protected abstract handleCommand(
    command: SdSpiCommands,
    argument: number,
    crc: number
  ): Promise<number[]>

  protected abstract clockTick(): void
}
