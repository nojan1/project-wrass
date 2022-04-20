import { ISpiDeviceInterface } from './spiDeviceInterface'

export class SpiEchoDevice implements ISpiDeviceInterface {
  selected: boolean = false

  onClock(dataIn: number): number {
    if (!this.selected) return 0
    return dataIn
  }
}
