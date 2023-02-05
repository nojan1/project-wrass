import BusInterface from '6502.ts/lib/machine/bus/BusInterface'
import { SendDataCallback } from '..'
// import { toHex } from '../../utils/output'
import { colors } from './colors'
import { tileset } from './tileset'

const DisplayWidth = 640
const DisplayHeight = 480
const TotalCharCols = 64
const TotalCharRows = 32

const FramebufferStart = 0x0000
const ColorAttributesStart = FramebufferStart + 0x0800
const TilemapStart = ColorAttributesStart + 0x0800
const ColorsStart = TilemapStart + 0x800
const MemoryTop = ColorsStart + 0x80

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
  private _internalMemory = new Uint8ClampedArray(MemoryTop + 1)

  constructor(private _sendData: SendDataCallback) {
    this._registers = new Uint8ClampedArray([0x0, 0x0, 0x0, 0x1, 0x0, 0x0, 0x0])

    tileset.forEach((data, i) => {
      this._internalMemory[TilemapStart + i] = data
    })

    colors.forEach((color, i) => {
      this._internalMemory[ColorsStart + i] = color
    })

    for (let i = 0; i < TotalCharCols * TotalCharRows; i++) {
      this._internalMemory[FramebufferStart + i] = ~~(Math.random() * 255)
      this._internalMemory[ColorAttributesStart + i] = ~~(Math.random() * 255)
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

      this.handleIncrement()

      if (internalAddress > this._internalMemory.length) {
        return 0
      }

      return this._internalMemory[internalAddress]
    }

    return this._registers[register]
  }

  peek(address: number): number {
    const register = this.registerFromAddress(address)
    return this._registers[register]
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

      // console.log(`Wrote ${value} to ${toHex(internalAddress, 4, true)}`)

      this.handleIncrement()

      if (internalAddress <= this._internalMemory.length) {
        this._internalMemory[internalAddress] = value
      }
    }

    this._registers[register] = value
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
    const rawScreenbuffer = new Uint8ClampedArray(
      DisplayWidth * DisplayHeight * 4
    )

    const scrollX = this._registers[GpuRegisters.XOffset]
    const scrollY = this._registers[GpuRegisters.YOffset]

    for (let scanline = 0; scanline < DisplayHeight; scanline++) {
      for (let cycle = 0; cycle < DisplayWidth; cycle++) {
        const offsetCycle = ((cycle >> 1) + (512 - scrollX)) & 0x1ff
        const offsetScanline = ((scanline >> 1) + (256 - scrollY)) & 0x0ff

        const charColumn = offsetCycle >> 3
        const charRow = offsetScanline >> 3

        const framebufferAddress = (charRow << 6) | charColumn

        const tileNumber =
          this._internalMemory[FramebufferStart + framebufferAddress]

        const charRenderColumn = offsetCycle & 0x7
        const charRenderRow = offsetScanline & 0x7

        const tileDataAddress = charRenderRow + (tileNumber << 3)

        const tileData = this._internalMemory[TilemapStart + tileDataAddress]
        const pixelOn = ((tileData >> charRenderColumn) & 0x1) === 1

        const colorAttribute =
          this._internalMemory[ColorAttributesStart + framebufferAddress]

        const colorIndex = pixelOn
          ? (colorAttribute >> 4) & 0xf
          : colorAttribute & 0xf

        const color = this._internalMemory[ColorsStart + colorIndex]

        // Simulator specific, the data to send to the render component
        const screenBufferIndex = (scanline * DisplayWidth + cycle) * 4

        rawScreenbuffer[screenBufferIndex + 0] = ((color >> 6) & 0b11) * 64
        rawScreenbuffer[screenBufferIndex + 1] = ((color >> 3) & 0b111) * 32
        rawScreenbuffer[screenBufferIndex + 2] = ((color >> 0) & 0b111) * 32
        rawScreenbuffer[screenBufferIndex + 3] = 255
      }
    }

    this._sendData('framebuffer-update', rawScreenbuffer)
  }
}
