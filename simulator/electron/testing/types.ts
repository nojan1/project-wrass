export interface TestMethodContext {
	board
}

export type TestMethodCallback = (context: TestMethodContext) => void 

export interface TestSetupContext {
	arrangeCallbacks: (() => void)[],
	actCallbacks: (() => void)[],
	assertCallbacks: (() => void)[]
}
