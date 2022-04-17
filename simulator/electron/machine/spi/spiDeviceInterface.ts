export interface ISpiDeviceInterface {
  selected: boolean
  onClock(dataIn: boolean): boolean
}
