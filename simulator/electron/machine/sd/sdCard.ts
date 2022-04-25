import { ISpiDeviceInterface } from '../spi/spiDeviceInterface'
import { SdCardIdleState } from './SdIdleState'
import { SdCardReadyState } from './SdReadyState'
import { ISdCardStateHandler } from './sdState'
import { SdCardUninitializedState } from './SdUninitializedState'
import { SdCardState } from './states'

export class SdCard implements ISpiDeviceInterface {
  selected: boolean = false

  // eslint-disable-next-line no-useless-constructor
  constructor(sdImagePath: string) {
    this._stateHandlers = {
      [SdCardState.Uninitialized]: new SdCardUninitializedState(),
      [SdCardState.Idle]: new SdCardIdleState(this.setState.bind(this)),
      [SdCardState.Ready]: new SdCardReadyState(
        sdImagePath,
        this.setState.bind(this)
      ),
    }
  }

  private _currentState: SdCardState = SdCardState.Uninitialized
  private _stateHandlers

  private setState(newState: SdCardState) {
    console.log(`SD-Card is now in state ${newState}`)
    this._currentState = newState
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
