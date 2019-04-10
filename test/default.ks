#![bin]

extern {
	__dirname: String
	describe: Function
	it: Function
}

import {
	'@zokugun/lang'
	'chai'				for expect
	'fs'
	'klaw-sync'			=> klaw
	'path'
	'..'
}

describe('default', func() {
	func prepare(file) {
		const root = path.dirname(file)
		const name = path.basename(file).slice(0, -4)

		it('should compile ' + name, func() {
			const source: String = fs.readFileSync(file, {
				encoding: 'utf8'
			})
			const generated: String = fs.readFileSync(path.join(root, name + '.gen'), {
				encoding: 'utf8'
			})

			expect(template.compile(source, {
				allowsCurrying: false
			}).toSource()).to.equal(generated.trimEnd())
		})
	}

	const options = {
		nodir: true
		traverseAll: true
		filter: item => item.path.slice(-4) == '.src'
	}

	for file in klaw(path.join(__dirname, 'cases'), options) {
		prepare(file.path)
	}
})