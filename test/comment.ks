#![bin]

extern {
	describe:	func
	it:			func
	__dirname:	string
}

import {
	'@zokugun/lang'
	'chai'		for expect
	'fs'
	'klaw-sync' => klaw
	'path'
	'..'
}

func compile(name) {
	const source = fs.readFileSync(path.join(__dirname, name + '.src'), {
		encoding: 'utf8'
	})

	const generated = fs.readFileSync(path.join(__dirname, name + '.gen'), {
		encoding: 'utf8'
	}):String.rtrim()

	expect(template.compile(source, {
		strip: false
	}).toSource()).to.equal(generated)
}

describe('comment', func() {
	it('should compile folding', func() {
		compile('comment.folding')
	})
})
