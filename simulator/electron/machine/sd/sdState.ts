import { SdCardState } from './states'

export interface ISdCardStateHandler {
  onClock(
    dataIn: number,
    selected: boolean
  ): { dataOut: number; newState?: SdCardState }
}
