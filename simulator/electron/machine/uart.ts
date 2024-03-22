import BusInterface from '6502.ts/lib/machine/bus/BusInterface'
import { BoardRunStateStore, SendDataCallback } from '.'
import { ipcMain } from 'electron'

import readline from 'readline'

const BaudRate = 115200

export class Uart implements BusInterface {
  private writeBuffer = new FIFO<number>(16)
  private readBuffer = new FIFO<number>()

  private simulatorToSendBuffer = new FIFO<number>()

  private waitingForFirstStatusAccess = true
  private useStdInOut = false

  private irqEnable = 0
  private irqActive = 0

  constructor(sendData: SendDataCallback, runState: BoardRunStateStore) {
    // Interval time is the actual time it would take the uart to send a byte using the provided baudrate
    const interval = 1000 / (BaudRate / 8)

    setInterval(() => {
      if (!runState.simulatorRunning || this.waitingForFirstStatusAccess) return

      // Data written from the "computer" to be send to the simulator gui
      if (this.writeBuffer.count() > 0) {
        const value = this.writeBuffer.dequeue()
        sendData('uart-recieve', { value })

        if (this.useStdInOut) console.log(String.fromCharCode(value))
      }

      // Bytes from simulator to be send to the "computer"
      if (this.simulatorToSendBuffer.count() > 0) {
        const value = this.simulatorToSendBuffer.dequeue()
        this.readBuffer.enqueue(value)

        if (this.irqEnable === 1) {
          this.irqActive = 1
          runState.triggerInterupt()
        }
      }
    }, interval)

    ipcMain.on('uartTransmit', (_, value: number) => {
      this.simulatorToSendBuffer.enqueue(value)
    })

    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout,
      terminal: false,
    })

    rl.on('line', line => {
      for (let i = 0; i < line.length; i++) {
        this.simulatorToSendBuffer.enqueue(line.charCodeAt(i))
      }

      this.simulatorToSendBuffer.enqueue(10)
    })
  }

  read(address: number): number {
    address &= 0x3

    switch (address) {
      case 1:
        this.irqActive = 0
        return this.readBuffer.dequeue()
      case 2:
        this.waitingForFirstStatusAccess = false

        // eslint-disable-next-line no-case-declarations
        const status =
          ((this.readBuffer.count() > 0 ? 1 : 0) << 7) |
          ((this.writeBuffer.count() === 16 ? 0 : 1) << 6) |
          (0 << 5) |
          (0 << 4) |
          (0 << 3) |
          ((this.writeBuffer.count() > 0 ? 1 : 0) << 2) |
          (this.irqActive << 1) |
          ((this.readBuffer.count() >= 16 ? 0 : 1) << 0)

        // console.log(`Status is now: ${status.toString(2)}`)
        return status
      default:
        return (Math.random() * 256) & 0xff
    }
  }

  write(address: number, value: number): void {
    address &= 0x3

    switch (address) {
      case 0:
        this.writeBuffer.enqueue(value)
        break
      case 3:
        this.irqEnable = value & 1
        break
      default:
        break
    }
  }

  peek(address: number): number {
    return 0
  }

  readWord(address: number): number {
    return 0
  }

  poke(address: number, value: number): void {
    this.write(address, value)
  }
}

class FIFO<T> {
  private items: Record<number, T> = {}
  private frontIndex = 0
  private backIndex = 0

  // eslint-disable-next-line no-useless-constructor
  constructor(private length: number | null = null) {}

  enqueue(item: T) {
    // console.log('enqueue called, count is', this.count())
    if (this.length !== null && this.count() > this.length!) return

    this.items[this.backIndex] = item
    this.backIndex++
  }

  dequeue() {
    const item = this.items[this.frontIndex]
    delete this.items[this.frontIndex]

    if (this.frontIndex !== this.backIndex) this.frontIndex++
    // console.log('dequeue completed, count is', this.count())
    return item
  }

  peek() {
    return this.items[this.frontIndex]
  }

  count() {
    return Math.abs(this.backIndex - this.frontIndex)
  }

  get printQueue() {
    return this.items
  }
}
