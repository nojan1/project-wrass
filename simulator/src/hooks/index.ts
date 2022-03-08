import { useBridgeBoundState } from './useBridgeBoundState'

export const useBlinkenLights = () =>
  useBridgeBoundState<number>('blinkenlights-update')
