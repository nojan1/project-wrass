import { SendDataCallback } from '.'
import { toHex } from '../utils/output'
import { ViaCallbackHandler } from './via'

export class LcdController implements ViaCallbackHandler {
  private _data = 0
  private _rw = 0
  private _rs = 0
  private _e = 0
  private _last_e = 0

  private _position = 0
  private _characters = Array(40).fill(' ')

  // eslint-disable-next-line no-useless-constructor
  constructor(private _sendData: SendDataCallback) {}

  portAWrite(value: number): void {
    this._e = (value & 0x80) >> 7
    this._rw = (value & 0x40) >> 6
    this._rs = (value & 0x20) >> 5

    if (this._e === 1 && this._last_e === 0) {
      console.log('E toggled, about to handle command')
      console.log(
        `e: ${this._e} rw: ${this._rw} rs: ${this._rs} data: ${toHex(
          this._data
        )}`
      )
      this._handleCommand()
    }

    this._last_e = this._e
  }

  portBWrite(value: number): void {
    this._data = value
  }

  portARead(): number | null {
    return null
  }

  portBRead(): number | null {
    return 0x0 // Never busy.. very fake
  }

  private _handleCommand() {
    if (this._rs === 0) {
      // Instruction
      if (this._rw === 1) {
        // Read
      } else {
        // Write
        if (this._data === 1) {
          // Clear home
          this._position = 0
          this._characters = Array(40).fill(' ')
        }
      }
    } else {
      // Data
      if (this._rw === 0) {
        const character = String.fromCharCode(this._data).substring(0, 1)
        this._characters[this._position] = character
        this._position = (this._position + 1) % this._characters.length

        this._sendUpdate()
      }
    }
  }

  private _sendUpdate() {
    const newContent = this._characters.join('')
    this._sendData('lcd-update', newContent)
  }
}
