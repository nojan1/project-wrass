this.test('There is something here', _ => _
	.runSubroutine('printhex')
	.assert((x) => console.log(x))
)

