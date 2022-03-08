import { contextBridge, ipcRenderer } from 'electron'

contextBridge.exposeInMainWorld('Main', {
  disassembleAt: (address: number, length = 10) =>
    ipcRenderer.invoke('disassemble-at', address, length),
  stepDebugger: () => ipcRenderer.invoke('step-debugger'),
  addBreakpoint: (address: number, description?: string) => {
    ipcRenderer.send('add-breakpoint', address, description)
  },

  removeBreakpoint: (address: number) => {
    ipcRenderer.send('remove-breakpoint', address)
  },

  run: () => {
    ipcRenderer.send('run')
  },

  pause: () => {
    ipcRenderer.send('pause')
  },

  /**
   * Provide an easier way to listen to events
   */
  on: (channel: string, callback: Function) => {
    ipcRenderer.on(channel, (_, data) => callback(data))
  },
})
