import BusInterface from '6502.ts/lib/machine/bus/BusInterface'
import { SendDataCallback } from '.'
import { ipcMain } from 'electron'

import readline from 'readline'

export class Uart implements BusInterface {
  private writeBuffer = new FIFO<number>(16)
  private readBuffer = new FIFO<number>()

  private useStdInOut = false

  constructor(private sendData: SendDataCallback) {
    setInterval(() => {
      while (this.writeBuffer.count() > 0) {
        const value = this.writeBuffer.dequeue()
        sendData('uart-recieve', { value })

        if (this.useStdInOut) console.log(String.fromCharCode(value))
      }
    }, 50)

    ipcMain.on('uartTransmit', (_, value: number) => {
      this.readBuffer.enqueue(value)
    })

    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout,
      terminal: false,
    })

    rl.on('line', line => {
      for (let i = 0; i < line.length; i++) {
        this.readBuffer.enqueue(line.charCodeAt(i))
      }

      this.readBuffer.enqueue(10)
    })
  }

  read(address: number): number {
    address &= 0x3

    switch (address) {
      case 1:
        return this.readBuffer.dequeue()
      case 2:
        // eslint-disable-next-line no-case-declarations
        const status =
          ((this.readBuffer.count() > 0 ? 1 : 0) << 7) |
          ((this.writeBuffer.count() === 16 ? 0 : 1) << 6) |
          (0 << 5) |
          (0 << 4) |
          (0 << 3) |
          ((this.writeBuffer.count() > 0 ? 1 : 0) << 2) |
          ((this.readBuffer.count() >= 16 ? 0 : 1) << 1) |
          0

        // console.log(`Status is now: ${status.toString(2)}`)
        return status
      default:
        return (Math.random() * 256) & 0xff
    }
  }

  write(address: number, value: number): void {
    address &= 0x3

    if (address === 0) {
      this.writeBuffer.enqueue(value)
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
