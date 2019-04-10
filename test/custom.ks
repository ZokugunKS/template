#![bin]

extern {
	__dirname: String
	console
	describe: Function
	it: Function
}

import {
	'@zokugun/lang'
	'chai'				for expect
	'fs'
	'path'
	'..'
}

describe('custom', func() {
	it('should do new', func() {
		const custom = new Template({
			interpolate: {
				regex: /\$\{([\s\S]+?)\}/g
				replace(m, code) => this.cse.start + 'it.' + code + '()' + this.cse.end
			}
		})

		expect(custom).to.exist
		expect(custom).to.have.property('compile')
	})

	it('should compile', func() {
		const custom = new Template({
			interpolate: {
				regex: /\$\{([\s\S]+?)\}/g
				replace(m, code) => this.cse.start + 'it.' + code + '()' + this.cse.end
			}
		})

		const source: String = fs.readFileSync(path.join(__dirname, 'custom.src'), {
			encoding: 'utf8'
		})
		const generated: String = fs.readFileSync(path.join(__dirname, 'custom.gen'), {
			encoding: 'utf8'
		})

		expect(custom.compile(source, {
			allowsCurrying: false
		}).toSource()).to.equal(generated.trimEnd())
	})
})
