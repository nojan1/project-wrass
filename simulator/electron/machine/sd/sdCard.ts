import { ISpiDeviceInterface } from '../spi/spiDeviceInterface'
import { SdCardIdleState } from './SdIdleState'
import { SdCardReadyState } from './SdReadyState'
import { ISdCardStateHandler } from './sdState'
import { SdCardUninitializedState } from './SdUninitializedState'
import { SdCardState } from './states'

export class SdCard implements ISpiDeviceInterface {
  selected: boolean = false

  private _currentState: SdCardState = SdCardState.Uninitialized
  private _stateHandlers = {
    [SdCardState.Uninitialized]: new SdCardUninitializedState(),
    [SdCardState.Idle]: new SdCardIdleState(),
    [SdCardState.Ready]: new SdCardReadyState(),
  }

  onClock(dataIn: number): number {
    const stateHandler: ISdCardStateHandler =
      this._stateHandlers[this._currentState]
    const { dataOut, newState } = stateHandler.onClock(dataIn, this.selected)

    if (newState) {
      console.log(`SD-Card is now in state ${newState}`)
      this._currentState = newState
    }

    return dataOut
  }
}
