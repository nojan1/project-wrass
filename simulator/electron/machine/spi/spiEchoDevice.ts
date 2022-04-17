import { ISpiDeviceInterface } from './spiDeviceInterface'

export class SpiEchoDevice implements ISpiDeviceInterface {
  selected: boolean = false

  onClock(dataIn: boolean): boolean {
    if (!this.selected) return false
    return dataIn
  }
}
