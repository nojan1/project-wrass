// import { CPU6502, ReadWrite } from '6502-emulator'
// import { createContext, useContext } from 'react'

// export interface ICpuContext {
//   cpu?: CPU6502
//   ram?: Uint8ClampedArray
// }

// const I_NOOP = 0xea

// export const initCpu = () => {
//   const ram = new Uint8ClampedArray(0xffff) // 64kb ram
//   ram.fill(I_NOOP) // fill ram with noop instructions

//   const accessMemory = (
//     readWrite: ReadWrite,
//     address: number,
//     value: number
//   ) => {
//     // capture a write to 0x6000 as a magic output address, print to console
//     if (address === 0x6000 && readWrite === ReadWrite.write) {
//       console.log('Output: ', value.toString(16))
//       return
//     }

//     // write value to RAM (processor is reading from [address])
//     if (readWrite === ReadWrite.read) {
//       return ram[address]
//     }

//     // store value in RAM (processor is writing [value] to [address])
//     ram[address] = value
//   }

//   return {
//     ram,
//     cpu: new CPU6502({
//       accessMemory: (rw, addr, val) => accessMemory(rw, addr, val ?? 0),
//     }),
//   }
// }

// const CpuContext = createContext<ICpuContext>({})

// export const CpuContextProvider = CpuContext.Provider
// export const useCpuContext = () => useContext(CpuContext)
