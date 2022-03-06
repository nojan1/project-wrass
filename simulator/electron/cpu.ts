import VanillaBoard from '6502.ts/lib/machine/vanilla/Board'
import VanillaMemory from '6502.ts/lib/machine/vanilla/Memory'

const I_LDA = 0xa9
const I_STA = 0x8d
const I_JMP = 0x4c

const program = [
  I_LDA,
  0x55, // lda 55
  I_STA,
  0x00,
  0x60, // 55 -> 6000 (output 55 to address 0x6000)

  I_LDA,
  0xaa, // lda AA
  I_STA,
  0x00,
  0x60, // AA -> 6000 (output AA to address 0x6000)

  I_JMP,
  0x00,
  0x02, // jump back to start of program
]

export class My6502ProjectBoard extends VanillaBoard {
  constructor(
    private loadData: Buffer | null = null,
    private loadAdress: number = 0x020,
    private entryAddress: number = 0x8000
  ) {
    super()

    this._bus = this._createBus()
  }

  protected override _createBus(): VanillaMemory {
    const ram = new My6502ProjectMemory()

    if (this.loadData) {
      for (let i = 0; i < this.loadData.length; i++) {
        ram.poke(this.loadAdress + i, this.loadData[i])
      }

      ram.poke(0xfffc, this.entryAddress & 0xff)
      ram.poke(0xfffd, (this.entryAddress >> 8) & 0xff)
    } else {
      // Debug usage only!!!
      const offset = 0x0200

      for (let i = 0; i < program.length; i++) {
        ram.poke(offset + i, program[i])
      }

      ram.poke(0xfffc, 0x00)
      ram.poke(0xfffd, 0x02)
    }

    return ram
  }
}

class My6502ProjectMemory extends VanillaMemory {}

// import { CPU6502, ReadWrite } from '6502-emulator'
// import { AccessMemoryFunc } from '6502-emulator/dist/types'

// const I_NOOP = 0xea

// export class CPU {
//   private _ram: Uint8ClampedArray
//   private _cpu: CPU6502

//   public get ram() {
//     return this._ram
//   }

//   public get cpu() {
//     return this._cpu
//   }

//   constructor(private onAccessMemory: AccessMemoryFunc) {
//     this._ram = new Uint8ClampedArray(0xffff) // 64kb ram
//     this._ram.fill(I_NOOP) // fill ram with noop instructions

//     this._cpu = new CPU6502({
//       accessMemory: (rw, addr, val) => this._accessMemory(rw, addr, val ?? 0),
//     })
//   }

//   private _accessMemory(readWrite: ReadWrite, address: number, value: number) {
//     // capture a write to 0x6000 as a magic output address, print to console
//     if (address === 0x6000 && readWrite === ReadWrite.write) {
//       console.log('Output: ', value.toString(16))
//       return
//     }

//     // write value to RAM (processor is reading from [address])
//     if (readWrite === ReadWrite.read) {
//       return this._ram[address]
//     }

//     // store value in RAM (processor is writing [value] to [address])
//     this._ram[address] = value

//     this.onAccessMemory(readWrite, address, value)
//   }
// }
