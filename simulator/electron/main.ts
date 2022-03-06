import Debugger from '6502.ts/lib/machine/Debugger'
import { app, BrowserWindow, ipcMain, WebContents } from 'electron'
import { My6502ProjectBoard } from './cpu'

import fs from 'fs'
const yargs = require('yargs')
const { hideBin } = require('yargs/helpers')

let mainWindow: BrowserWindow | null

declare const MAIN_WINDOW_WEBPACK_ENTRY: string
declare const MAIN_WINDOW_PRELOAD_WEBPACK_ENTRY: string

// const assetsPath =
//   process.env.NODE_ENV === 'production'
//     ? process.resourcesPath
//     : app.getAppPath()

function createWindow() {
  mainWindow = new BrowserWindow({
    // icon: path.join(assetsPath, 'assets', 'icon.png'),
    width: 1100,
    height: 700,
    backgroundColor: '#191622',
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      preload: MAIN_WINDOW_PRELOAD_WEBPACK_ENTRY,
    },
  })

  mainWindow.webContents.openDevTools()
  mainWindow.loadURL(MAIN_WINDOW_WEBPACK_ENTRY)

  mainWindow.on('closed', () => {
    mainWindow = null
  })
}

const loadMemoryFromFile = async (path: string) => {
  return new Promise<Buffer>((resolve, reject) => {
    fs.readFile(
      path,
      {
        encoding: null,
      },
      (err, data) => {
        if (err) reject(err)
        else {
          resolve(data)
        }
      }
    )
  })
}

const createDebugger = async () => {
  const options = yargs(hideBin(process.argv))
    .option('file', {
      alias: 'f',
      type: 'string',
      description:
        'The path to the binary file that should be loaded in to memory',
    })
    .option('load-address', {
      type: 'number',
      default: 0x8000,
      description:
        'The start address to where the binary should be stored in memory',
    })
    .option('breakpoint', {
      alias: 'b',
      type: 'number',
      array: true,
      description: 'Set breakpoint on address provded',
    }).argv

  const data: Buffer | null = options.file
    ? await loadMemoryFromFile(options.file)
    : null

  const board = new My6502ProjectBoard(data, options.loadAddress)

  board.boot()
  const myDebugger = new Debugger()
  myDebugger.attach(board)
  myDebugger.setBreakpointsEnabled(true)

  options.breakpoint?.forEach((address: number, i: number) => {
    myDebugger.setBreakpoint(address, `Breakpoint from cli #${i}`)
  })

  return myDebugger
}

async function registerListeners(debuggerInstance: Debugger) {
  const sendUpdates = (sender: WebContents) => {
    sender.send('cpu-state-update', debuggerInstance.getBoard().getCpu().state)
    sender.send('dissassembly-state-update', debuggerInstance.disassemble(15))
    sender.send('stack-dump-update', debuggerInstance.dumpStack())

    const trap = debuggerInstance.getLastTrap()
    sender.send(
      'last-trap-update',
      trap
        ? {
            reason: trap.reason,
            message: trap.message,
          }
        : undefined
    )
  }

  ipcMain.on('add-breakpoint', (_, address, description = '') => {
    debuggerInstance.setBreakpoint(address, description)
  })

  ipcMain.on('remove-breakpoint', (_, address) => {
    debuggerInstance.clearBreakpoint(address)
  })

  ipcMain.handle('step-debugger', event => {
    event.sender.send('debugger-running', true)
    event.sender.send('last-trap-update', undefined)

    debuggerInstance.step(1)

    sendUpdates(event.sender)
    event.sender.send('debugger-running', false)
  })

  ipcMain.handle('run', event => {
    event.sender.send('debugger-running', true)
    event.sender.send('last-trap-update', undefined)

    while (1) {
      debuggerInstance.step(100)
      const lastTrap = debuggerInstance.getLastTrap()

      if (lastTrap) {
        sendUpdates(event.sender)
        event.sender.send('debugger-running', false)
        return lastTrap
      }
    }
  })
}

app
  .on('ready', createWindow)
  .whenReady()
  .then(createDebugger)
  .then(registerListeners)
  .catch(e => console.error(e))

app.on('window-all-closed', () => {
  app.quit()
})

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow()
  }
})
