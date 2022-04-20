import { ISdCardStateHandler } from './sdState'
import { SdCardState } from './states'

export class SdCardUninitializedState implements ISdCardStateHandler {
  private _pulsesRecieved = 0

  onClock(
    dataIn: number,
    selected: boolean
  ): {
    dataOut: number
    newState?: SdCardState | undefined
  } {
    if (selected && dataIn === 1) this._pulsesRecieved++

    return {
      dataOut: 0,
      newState: this._pulsesRecieved === 74 ? SdCardState.Idle : undefined,
    }
  }
}
