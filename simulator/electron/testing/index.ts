const createSut = async (options: any) => {
  const data: Buffer = await loadMemoryFromFile(options.file)

  const symbols = options.listing ? await parseListing(options.listing) : null
  const boardContext = initBoard(
    (channel: string, data: any) => {},
    data,
    options.loadAddress,
    options.resetAddress ?? options.loadAddress,
    options.sdImage
  )

  return { boardContext, symbols }
}

const runTests = (options: any) => {
	
}

export default runTests;
