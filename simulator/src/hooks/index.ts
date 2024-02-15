import { useBridgeBoundState } from './useBridgeBoundState'

export const useBlinkenLights = () =>
  useBridgeBoundState<number>('blinkenlights-update')

export const useLcdText = () => useBridgeBoundState<string>('lcd-update')

export const useFramebuffer = () =>
  useBridgeBoundState<Uint8ClampedArray>('framebuffer-update')

export const useUartRecieve = () =>
  useBridgeBoundState<{ value: number }>('uart-recieve')
