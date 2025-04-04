import { loadMemoryFromFile } from '../utils/memoryFile'
import TestSetupContext from './testSetupContext'
import { BoardInitContext, initBoard } from '../machine'
import { parseListing, SymbolListing } from '../utils/listingParser'
import fs from 'fs'
import path from 'path'
import { CompletedTestSetup, TestMethodContext } from './types'
import vm from 'vm'

const createSut = async (options: any, symbols: SymbolListing | null) => {
  const data: Buffer = await loadMemoryFromFile(options.file)

  const boardContext = initBoard(
    (channel: string, data: any) => {},
    data,
    options.loadAddress,
    options.resetAddress ?? options.loadAddress,
    options.sdImage
  )

  return boardContext
}

const runTests = async (options: any) => {
  console.log('===============================================================')
  console.log('|         Project Wrass Simulator - Test runner               |')
  console.log('===============================================================')
  console.log('')

  if (!options.listing) {
    console.warn(
      'No symbol listing was provided, any reference to symbols wont work. You have been warned.'
    )
    console.log('')
  }

  const symbols = options.listing ? await parseListing(options.listing) : null
  const files = fs.readdirSync(options.testDirectory, {
    withFileTypes: true,
  })

  console.log('Test run starting...\n')

  await Promise.all(
    files
      .filter(file => file.isFile() && file.name.endsWith('.test.js'))
      .map(async file => {
        const testFilePath = path.resolve(options.testDirectory, file.name)
        console.log(`file: ${file.name}`)
        console.log('-----------------------------------\n')
        await runTestFile(testFilePath, symbols, options)
      })
  )

  console.log('\nTest run finished')
}

const printFail = (name: string, err: unknown) => {
  console.error(`\u001b[31m[FAIL]\u001b[0m \t${name}`)
  console.error(err, 'Error running arrange callback')
  console.log('')
}

const runTestFile = async (
  path: string,
  symbols: SymbolListing | null,
  options: any
) => {
  try {
    const code = fs.readFileSync(path, 'utf8')
    const script = new vm.Script(code, {
      filename: path,
    })

    const testSetups: { name: string; context: CompletedTestSetup }[] = []

    const testFuncContext = vm.createContext({
      test: (
        name: string,
        setupCallback: (context: TestSetupContext) => TestSetupContext
      ) => {
        const setupContext = new TestSetupContext(symbols)

        testSetups.push({
          name,
          context: setupCallback(setupContext).complete(),
        })
      },
    })
    script.runInContext(testFuncContext)

    await Promise.all(
      testSetups.map(async ({ name, context }) => {
        let sut: BoardInitContext | null = null

        try {
          sut = await createSut(options, symbols)
        } catch (err) {
          console.error(err, `Error initializing board for test ${name}`)
          return
        }

        const testContext: TestMethodContext = { ...sut }

        try {
          context.arrangeCallbacks.forEach(func => func(testContext))
        } catch (err) {
          printFail(name, err)
          return
        }

        try {
          context.actStepDefinitions.forEach(definition => {})
        } catch (err) {
          printFail(name, err)
          return
        }

        try {
          context.assertCallbacks.forEach(func => func(testContext))
        } catch (err) {
          printFail(name, err)
          return
        }

        console.log(`\u001b[32m[SUCCESS]\u001b[0m \t${name}`)
      })
    )
  } catch (err) {
    console.error(err, `Error ocurred loading ${path}`)
  }
}

export default runTests
