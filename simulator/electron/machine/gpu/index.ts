import BusInterface from '6502.ts/lib/machine/bus/BusInterface'
import { SendDataCallback } from '..'
import { colors } from './colors'
import { tileset } from './tileset'

const DisplayWidth = 640
const DisplayHeight = 480
const CharCols = 80
const CharRows = 60

const MemoryBase = 0xc000
const FramebufferStart = 0xc000 - MemoryBase
const ColorAttributesStart = 0xd2c1 - MemoryBase
const TilemapStart = 0xe582 - MemoryBase
const ColorsStart = 0xed82 - MemoryBase
const MemoryTop = 0xee02

export enum GpuRegisters {
  // eslint-disable-next-line no-unused-vars
  Control = 0,
  // eslint-disable-next-line no-unused-vars
  YOffset = 1,
  // eslint-disable-next-line no-unused-vars
  XOffset = 2,
  // eslint-disable-next-line no-unused-vars
  Increment = 3,
  // eslint-disable-next-line no-unused-vars
  AddressLow = 4,
  // eslint-disable-next-line no-unused-vars
  AddressHigh = 5,
  // eslint-disable-next-line no-unused-vars
  ReadWrite = 6,
}

export class Gpu implements BusInterface {
  private _registers: Uint8ClampedArray
  private _internalMemory = new Uint8ClampedArray(MemoryTop - MemoryBase + 1)

  constructor(private _sendData: SendDataCallback) {
    this._registers = new Uint8ClampedArray([0x0, 0x0, 0x0, 0x1, 0x0, 0x0, 0x0])

    tileset.forEach((data, i) => {
      this._internalMemory[TilemapStart + i] = data
    })

    colors.forEach((color, i) => {
      this._internalMemory[ColorsStart + i] = color
    })

    for (let i = 0; i < CharCols * CharRows; i++) {
      this._internalMemory[ColorAttributesStart + i] = 0b00010110
    }

    setTimeout(() => {
      this.buildAndSendFramebuffer()
    }, 1000)
  }

  read(address: number): number {
    const register = this.registerFromAddress(address)
    if (register === GpuRegisters.ReadWrite) {
      const internalAddress =
        (this._registers[GpuRegisters.AddressHigh] << 8) &
        this._registers[GpuRegisters.AddressLow]
      const arrayIndex = internalAddress - MemoryBase

      this.handleIncrement()

      if (arrayIndex > this._internalMemory.length) {
        return 0
      }

      return this._internalMemory[arrayIndex]
    }

    return this._registers[register]
  }

  peek(address: number): number {
    return 0
  }

  readWord(address: number): number {
    return this.read(address)
  }

  write(address: number, value: number): void {
    const register = this.registerFromAddress(address)
    if (register === GpuRegisters.ReadWrite) {
      const internalAddress =
        (this._registers[GpuRegisters.AddressHigh] << 8) |
        this._registers[GpuRegisters.AddressLow]
      const arrayIndex = internalAddress - MemoryBase

      this.handleIncrement()

      if (arrayIndex <= this._internalMemory.length) {
        this._internalMemory[arrayIndex] = value
      }
    } else {
      this._registers[register] = value
    }

    this.buildAndSendFramebuffer()
  }

  poke(address: number, value: number): void {
    // Nope
  }

  private registerFromAddress(address: number) {
    return (address & 0x3f) as GpuRegisters
  }

  private handleIncrement() {
    if (this._registers[GpuRegisters.Increment] > 0) {
      const newLowAddress =
        (this._registers[GpuRegisters.AddressLow] +
          this._registers[GpuRegisters.Increment]) &
        0xff

      if (newLowAddress < this._registers[GpuRegisters.AddressLow]) {
        // Wrapped arround
        this._registers[GpuRegisters.AddressHigh] =
          (this._registers[GpuRegisters.AddressHigh] + 1) & 0xff
      }

      this._registers[GpuRegisters.AddressLow] = newLowAddress
    }
  }

  private buildAndSendFramebuffer() {
    const frameBuffer = new Uint8ClampedArray(DisplayWidth * DisplayHeight * 4)

    for (let pixelCol = 0; pixelCol < DisplayWidth; pixelCol++) {
      for (let pixelRow = 0; pixelRow < DisplayHeight; pixelRow++) {
        const col = ~~(pixelCol / 8)
        const row = ~~(pixelRow / 8)

        const subCol = pixelCol % 8
        const subRow = pixelRow % 8

        const char =
          this._internalMemory[FramebufferStart + col + row * CharRows]
        const tile = this._internalMemory[TilemapStart + subRow + char * 8]
        const bit = ((tile >> subCol) & 0x1) === 1

        const colorAttribute =
          this._internalMemory[ColorAttributesStart + col + row * CharRows]
        const colorIndex = bit
          ? (colorAttribute >> 4) & 0xf
          : colorAttribute & 0xf

        const color = this._internalMemory[ColorsStart + colorIndex]
        const frameBufferIndex = (pixelRow * DisplayWidth + pixelCol) * 4

        frameBuffer[frameBufferIndex + 0] = ((color >> 6) & 0b11) * 64
        frameBuffer[frameBufferIndex + 1] = ((color >> 3) & 0b111) * 32
        frameBuffer[frameBufferIndex + 2] = ((color >> 0) & 0b111) * 32
        frameBuffer[frameBufferIndex + 3] = 255
      }
    }

    this._sendData('framebuffer-update', frameBuffer)
  }
}
