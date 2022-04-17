import { ISpiDeviceInterface } from '../spi/spiDeviceInterface'
import { SdCardState } from './states'

export class SdCard implements ISpiDeviceInterface {
  selected: boolean = false

  private _currentState: SdCardState = SdCardState.Idle

  onClock(dataIn: boolean): boolean {
    return false
  }
}
