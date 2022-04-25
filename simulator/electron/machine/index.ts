import BoardInterface from '6502.ts/lib/machine/board/BoardInterface'
import { toHex } from '../utils/output'
import { createBoard } from './board'
import { Gpu } from './gpu'
import { IoMultiplexer } from './io'
import { IoCard } from './ioCard'
import { KeyboardController } from './keyboardController'
import { LcdController } from './lcdController'
import { MyDebugger } from './myDebugger'
import { SdCard } from './sd/sdCard'
import { SpiEchoDevice } from './spi/spiEchoDevice'
import { SpiViaCallbackHandler } from './spi/spiViaCallbackHandler'
import { SystemBus } from './systemBus'
import { VIA } from './via'

export type SendDataCallback = (channel: string, data: any) => void

const setMemory = (
  bus: SystemBus,
  data: Buffer,
  loadAddress: number,
  entryAddress: number
) => {
  console.log(
    `Loading ${toHex(data.length)} bytes from ${toHex(loadAddress)} to ${toHex(
      loadAddress + data.length - 1
    )}`
  )

  for (let i = 0; i < data.length; i++) {
    bus.poke(loadAddress + i, data[i])
  }

  if (loadAddress + data.length < 0xfffc) {
    console.log(`Setting RESV to ${toHex(entryAddress)}`)

    bus.poke(0xfffc, entryAddress & 0xff)
    bus.poke(0xfffd, (entryAddress >> 8) & 0xff)
  }
}

export interface BoardInitContext {
  board: BoardInterface
  myDebugger: MyDebugger
  bus: SystemBus
}

export const initBoard = (
  sendData: SendDataCallback,
  loadData: Buffer | null = null,
  loadAdress: number = 0x020,
  entryAddress: number = 0x8000,
  sdImagePath: string
): BoardInitContext => {
  const lcdVia1 = new VIA()
  lcdVia1.registerCallbackHandler(new LcdController(sendData))

  const via1 = new VIA()
  via1.registerCallbackHandler(
    new SpiViaCallbackHandler({
      1: new SdCard(sdImagePath),
      2: new SpiEchoDevice(),
    })
  )

  const via2 = new VIA()
  const keyboardController = new KeyboardController()
  via2.registerCallbackHandler(keyboardController)

  const io = new IoMultiplexer({
    0: new IoCard(via1, via2),
    1: new Gpu(sendData),
    2: lcdVia1,
  })

  const bus = new SystemBus(sendData, io)
  if (loadData) setMemory(bus, loadData, loadAdress, entryAddress)

  const board = createBoard(bus)
  board.boot()

  const myDebugger = new MyDebugger()
  myDebugger.attach(board)
  myDebugger.setBreakpointsEnabled(true)

  keyboardController.attachCpu(board.getCpu())

  return {
    board,
    myDebugger,
    bus,
  }
}
