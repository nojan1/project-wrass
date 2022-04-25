import { app, BrowserWindow, ipcMain, WebContents } from 'electron'
import { getTestProgramBuffer } from './data/program'
import { BoardInitContext, initBoard } from './machine'
import { Breakpoint } from './types/breakpoint'
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

function parseOptions() {
  return yargs(hideBin(process.argv))
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
    })
    .option('display', {
      type: 'string',
      choices: ['lcd', 'graphic'],
      default: 'lcd',
    })
    .option('sd-image', {
      type: 'string',
    }).argv
}

function createWindow(options: any) {
  mainWindow = new BrowserWindow({
    // icon: path.join(assetsPath, 'assets', 'icon.png'),
    width: 1200,
    height: 770,
    backgroundColor: '#191622',
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      preload: MAIN_WINDOW_PRELOAD_WEBPACK_ENTRY,
    },
  })

  if (!app.isPackaged) mainWindow.webContents.openDevTools()

  const url = `${MAIN_WINDOW_WEBPACK_ENTRY}?display=${options.display}`
  mainWindow.loadURL(url)

  mainWindow.on('closed', () => {
    mainWindow = null
  })
}

const createDebugger = async (options: any) => {
  const data: Buffer | null = options.file
    ? await loadMemoryFromFile(options.file)
    : getTestProgramBuffer()

  symbols = options.listing ? await parseListing(options.listing) : null
  const boardContext = initBoard(
    (channel: string, data: any) => mainWindow?.webContents.send(channel, data),
    data,
    options.loadAddress,
    options.resetAddress ?? options.loadAddress,
    options.sdImage
  )

  const initialBreakpoints: Array<Breakpoint> = []

  options.breakpoint?.forEach((address: number, i: number) => {
    boardContext.myDebugger.setBreakpoint(address, `Breakpoint from cli #${i}`)
    initialBreakpoints.push({
      address,
      description: `Breakpoint from cli #${i}`,
    })
  })

  symbols?.breakpoints.forEach(([address, name]) => {
    console.log(`Setting breakpoint from listing. ${name} => ${toHex(address)}`)
    boardContext.myDebugger.setBreakpoint(
      address,
      `Breakpoint from listing: ${name}`
    )

    initialBreakpoints.push({
      address,
      description: `Breakpoint from listing: ${name}`,
    })
  })

  return { boardContext, initialBreakpoints }
}

async function registerListeners({
  boardContext: { myDebugger, bus },
  initialBreakpoints,
}: {
  boardContext: BoardInitContext
  initialBreakpoints: Array<Breakpoint>
}) {
  const sendUpdates = (sender: WebContents) => {
    const disassembly = myDebugger.disassemble(15)
    sender.send(
      'dissassembly-state-update',
      symbols ? annotateDisassembly(disassembly, symbols) : disassembly
    )

    sender.send('cpu-state-update', myDebugger.getBoard().getCpu().state)
    sender.send('stack-dump-update', myDebugger.dumpStack())

    const trap = myDebugger.getLastTrap()
    sender.send(
      'last-trap-update',
      trap
        ? {
            reason: trap.reason,
            message: trap.message,
          }
        : undefined
    )

    sender.send('memory-dump', bus.dumpMemory())
  }

  ipcMain.handle('disassemble-at', (_, address, length) =>
    myDebugger.disassembleAt(address, length)
  )

  ipcMain.on('add-breakpoint', (_, address, description = '') => {
    myDebugger.setBreakpoint(address, description)
  })

  ipcMain.on('remove-breakpoint', (_, address) => {
    myDebugger.clearBreakpoint(address)
  })

  ipcMain.handle('step-debugger', event => {
    event.sender.send('debugger-running', true)
    event.sender.send('last-trap-update', undefined)

    myDebugger.step(1)

    sendUpdates(event.sender)
    event.sender.send('debugger-running', false)
  })

  ipcMain.on('run', async event => {
    event.sender.send('debugger-running', true)
    event.sender.send('last-trap-update', undefined)

    while (1) {
      await deferWork(() => myDebugger.step(100))
      const lastTrap = myDebugger.getLastTrap()

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

    myDebugger.injectTrap()

    sendUpdates(event.sender)
    event.sender.send('debugger-running', false)
  })

  ipcMain.on('update-request', event => {
    event.sender.send('initial-breakpoints', initialBreakpoints)
    sendUpdates(event.sender)
  })
}

const options = parseOptions()

app
  .on('ready', () => createWindow(options))
  .whenReady()
  .then(() => createDebugger(options))
  .then(registerListeners)
  .catch(e => console.error(e))

app.on('window-all-closed', () => {
  app.quit()
})

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow(options)
  }
})
