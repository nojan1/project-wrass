import { BoardInitContext } from "../machine"

export interface TestMethodContext extends BoardInitContext {
	
}

export type TestMethodCallback = (context: TestMethodContext) => void 

export enum ActStopKind {
	ExitFromRoutine,
	NumberOfCycles,
	AtAddress
}

export interface ActStepDefinition {
	enterAt: number
	stopKind: ActStopKind
	stopAt?: number
	maxCycles?: number
}

export interface CompletedTestSetup {
	arrangeCallbacks: TestMethodCallback[],
	actStepDefinitions: ActStepDefinition[]
	assertCallbacks: TestMethodCallback[]
}
