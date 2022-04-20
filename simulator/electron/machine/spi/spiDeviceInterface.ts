export interface ISpiDeviceInterface {
  selected: boolean
  onClock(dataIn: number): number
}
