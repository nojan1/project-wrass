import {
  TestMethodCallback,
  ActStepDefinition,
  ActStopKind,
  CompletedTestSetup,
} from './types'
import { SymbolListing } from '../utils/listingParser'
import { toHex } from '../utils/output'

class TestSetupContext {
  private arrangeCallbacks: TestMethodCallback[] = []
  private actStepDefinitions: ActStepDefinition[] = []
  private assertCallbacks: TestMethodCallback[] = []

  private workingActStepDefinition: ActStepDefinition | null = null

  // eslint-disable-next-line no-useless-constructor
  constructor(private symbols: SymbolListing | null) {}

  // Arrange
  public writeMemory(address: number, ...data: number[]) {
    this.arrangeCallbacks.push(({ bus }) => {
      for (let i = 0; i < data.length; i++) {
        bus.write(address + i, data[i])
      }
    })

    return this
  }

  public pokeMemory(address: number, ...data: number[]) {
    this.arrangeCallbacks.push(({ bus }) => {
      for (let i = 0; i < data.length; i++) {
        bus.poke(address + i, data[i])
      }
    })

    return this
  }

  // Act
  public runSubroutine(symbolName: string) {
    this.ensureCleanActStep()

    this.workingActStepDefinition.enterAt = this.symbols?.[symbolName]
    this.workingActStepDefinition.stopKind = ActStopKind.ExitFromRoutine

    return this
  }

  public runSubroutineAt(address: number) {
    this.ensureCleanActStep()

    this.workingActStepDefinition.enterAt = address
    this.workingActStepDefinition.stopKind = ActStopKind.ExitFromRoutine

    return this
  }

  // Assert
  public assert(method: TestMethodCallback) {
    this.assertCallbacks.push(method)
    return this
  }

  public assertMemory(address: number, ...data: number[]) {
    this.assertCallbacks.push(({ bus }) => {
      for (let i = 0; i < data.length; i++) {
        const memData = bus.peek(address + i)

        assert.areEqual(
          memData,
          data[i],
          `Expected data at ${toHex(address + i)} to be ${toHex(
            data[i]
          )} but it was ${toHex(memData)}`
        )
      }
    })

    return this
  }

  public complete(): CompletedTestSetup {
    this.ensureCleanActStep()

    return {
      arrangeCallbacks: this.arrangeCallbacks,
      actStepDefinitions: this.actStepDefinitions,
      assertCallbacks: this.assertCallbacks,
    }
  }

  private ensureCleanActStep() {
    if (this.workingActStepDefinition) {
      this.actStepDefinitions.push(this.workingActStepDefinition)
    }

    this.workingActStepDefinition = {
      enterAt: 0,
      stopKind: ActStopKind.NumberOfCycles,
      maxCycles: 99999,
    }
  }
}

export default TestSetupContext
