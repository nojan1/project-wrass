import { app, BrowserWindow, ipcMain, WebContents } from 'electron'
import { getTestProgramBuffer } from './data/program'
import { initBoard } from './machine'
import { MyDebugger } from './machine/myDebugger'
import { deferWork } from './utils/deferWork'
import { parseListing, SymbolListing } from './utils/listingParser'
import { loadMemoryFromFile } from './utils/memoryFile'
import { annotateDisassembly, toHex } from './utils/output'

const yargs = require('yargs')
const { hideBin } = require('yargs/helpers')

let mainWindow: BrowserWindow | null
let symbols: SymbolListing | null

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

const createDebugger = async () => {
  const options = yargs(hideBin(process.argv))
    .option('file', {
      alias: 'f',
      type: 'string',
      description:
        'The path to the binary file that should be loaded in to memory',
    })
    .option('listing', {
      alias: 'l',
      type: 'string',
      description:
        'The path to a listing file for the binary, it will be used to decorate disassembly and set breakpoints',
    })
    .option('load-address', {
      type: 'number',
      default: 0x0,
      description:
        'The start address to where the binary should be stored in memory',
    })
    .option('reset-address', {
      type: 'number',
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
    : getTestProgramBuffer()

  symbols = options.listing ? await parseListing(options.listing) : null

  const { myDebugger } = initBoard(
    (channel: string, data: any) => mainWindow?.webContents.send(channel, data),
    data,
    options.loadAddress,
    options.resetAddress ?? options.loadAddress
  )

  options.breakpoint?.forEach((address: number, i: number) => {
    myDebugger.setBreakpoint(address, `Breakpoint from cli #${i}`)
  })

  symbols?.breakpoints.forEach(([address, name]) => {
    console.log(`Setting breakpoint from listing. ${name} => ${toHex(address)}`)
    myDebugger.setBreakpoint(address, `Breakpoint from listing: ${name}`)
  })

  return myDebugger
}

async function registerListeners(debuggerInstance: MyDebugger) {
  const sendUpdates = (sender: WebContents) => {
    const disassembly = debuggerInstance.disassemble(15)
    sender.send(
      'dissassembly-state-update',
      symbols ? annotateDisassembly(disassembly, symbols) : disassembly
    )

    sender.send('cpu-state-update', debuggerInstance.getBoard().getCpu().state)
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

  ipcMain.handle('disassemble-at', (_, address, length) =>
    debuggerInstance.disassembleAt(address, length)
  )

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

  ipcMain.on('run', async event => {
    event.sender.send('debugger-running', true)
    event.sender.send('last-trap-update', undefined)

    while (1) {
      await deferWork(() => debuggerInstance.step(100))
      const lastTrap = debuggerInstance.getLastTrap()

      if (lastTrap) {
        sendUpdates(event.sender)
        event.sender.send('debugger-running', false)
        return lastTrap
      }
    }
  })

  ipcMain.on('pause', event => {
    event.sender.send('debugger-running', true)
    event.sender.send('last-trap-update', undefined)

    debuggerInstance.injectTrap()

    sendUpdates(event.sender)
    event.sender.send('debugger-running', false)
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
