import { useBridgeBoundState } from './useBridgeBoundState'

export const useBlinkenLights = () =>
  useBridgeBoundState<number>('blinkenlights-update')

export const useLcdText = () => useBridgeBoundState<string>('lcd-update')
