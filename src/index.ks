extern console

import '@zokugun/lang'

const $escapeRegex			= /[&<>"]/
const $escapeAmpRegex		= /&/g
const $escapeLtRegex		= /</g
const $escapeGtRegex		= />/g
const $escapeQuoteRegex		= /"/g

const $startend = {
	curry: {
		append: { // {{{
			start: "'+("
			end: ")+'"
			startencode: "'+escape("
			endencode: ")+'"
		} // }}}
		split: { // {{{
			start: "';out+=("
			end: ");out+='"
			startencode: "';out+=escape("
			endencode: ");out+='"
		} // }}}
	},
	noncurry: {
		append: { // {{{
			start: "'+("
			end: ")+'"
			startencode: "'+("
			endencode: ").escapeHTML()+'"
		} // }}}
		split: { // {{{
			start: "';out+=("
			end: ");out+='"
			startencode: "';out+=("
			endencode: ").escapeHTML();out+='"
		} // }}}
	}
}

func $build(that) { // {{{
	let replace = 'return str'

	for tag in Object.keys(that._tags).sort() {
		replace += '.replace(tags.' + tag + '.regex, function() {return tags.' + tag + '.replace.apply(context, arguments);})'
	}

	that._replace = new Function('str,tags,context', replace + ';')
} // }}}

func $escape(text) { // {{{
	if text == null {
		return ''
	}

	text = text.toString()
	if $escapeRegex.test(text) {
		return text.replace($escapeAmpRegex, '&#38;').replace($escapeLtRegex, '&#60;').replace($escapeGtRegex, '&#62;').replace($escapeQuoteRegex, '&#34;')
	}
	else {
		return text
	}
} // }}}

func $noop() => ''

func $unescape(code) => code.replace(/\\('|\\)/g, '$1').replace(/[\r\t\n]/g, ' ')

export class Template {
	private {
		_options: Object
		_replace: Function
		_variables: Array
		_varnames: String
		_tags: Object
	}
	constructor(tags = null, options = null) { // {{{
		@options = Object.append({
			varnames: 'it',
			strip: true,
			append: true,
			allowsCurrying: true
		}, options)

		if @options.variables is Object {
			@varnames = 'escape,' + Object.keys(this.options.variables).join(',')
			@variables = Object.values(this.options.variables)

			delete this.options.variables

			this.options.allowsCurrying = true
		}

		@tags = tags || {}

		$build(this)
	} // }}}
	addTag(name: String, regex: RegExp, replace: Function) { // {{{
		@tags[name] = {
			regex
			replace
		}

		$build(this)
	} // }}}
	clearTags() { // {{{
		@tags = {}

		$build(this)
	} // }}}
	compile(template: String?, options = null): Function { // {{{
		if !?template {
			return $noop
		}

		options = Object.defaults(@options, options)

		let inlines = template.before('\n')
		if inlines.startsWith('{{}} ') {
			template = template.substr(inlines.length + 1)
			inlines = inlines.split(' ')

			for inline in inlines {
				if inline[0] == 's' {
					if inline == 'strip:true' {
						options.strip = true
					}
					else if inline == 'strip:false' {
						options.strip = false
					}
				}
				else if inline[0] == 'a' {
					if inline == 'append:true' {
						options.append = true
					}
					else if inline == 'append:false' {
						options.append = false
					}
				}
				else if inline[0] == 'v' {
					if inline.startsWith('varnames:') {
						options.varnames = inline.after(':')
					}
				}
			}
		}

		const context = {
			cse: options.allowsCurrying ? options.append ? $startend.curry.append : $startend.curry.split : options.append ? $startend.noncurry.append : $startend.noncurry.split,
			unescape: options.unescape || $unescape,
			sid: 0
		}

		let str = this._replace("var out='" + template.replace(/<!--.*-->/g, '').replace(/'|\\/g, '\\$&'), this._tags, context) + "';"

		if options.strip {
			str = str
				.replace(/(^|\r|\n)\t* +| +\t*(\r|\n|$)/g, ' ')
				.replace(/(\t|\s){2,}/g, '')
		}

		str = str
			.replace(/\n/g, '\\n').replace(/\t/g, '\\t').replace(/\r/g, '\\r')
			.replace(/(\s|;|}|^|{)out\+='';/g, '$1').replace(/\+''/g, '')
			.replace(/(\s|;|}|^|{)out\+=''\+/g, '$1out+=')

		try {
			str += "return out;"

			if options.inlineVariables {
				for const name in options.inlineVariables {
					str = 'const ' + name + '=' + toSource(options.inlineVariables[name]) + ';' + str
				}
			}

			if options.allowsCurrying {
				if options.varnames {
					if this._varnames {
						return Function.curry(new Function(this._varnames + ',' + options.varnames, str), [options.escape ?? $escape, ...this._variables])
					}
					else if context.useEscape {
						return Function.curry(new Function('escape,' + options.varnames, str), [options.escape ?? $escape])
					}
					else {
						return new Function(options.varnames, str)
					}
				}
				else {
					if this._varnames {
						return Function.curry(new Function(this._varnames, str), [options.escape ?? $escape, ...this._variables])
					}
					else if context.useEscape {
						return Function.curry(new Function('escape', str), [options.escape ?? $escape])
					}
					else {
						return new Function('', str)
					}
				}
			}
			else {
				if options.varnames {
					return new Function(options.varnames, str)
				}
				else {
					return new Function('', str)
				}
			}
		}
		catch e {
			if !?console && console.log {
				console.log("Could not create a template function: " + str)
				console.log(e.stack || e.toString())
			}
			throw e
		}
	} // }}}
	removeTag(name: String) { // {{{
		delete @tags[name]

		$build(this)
	} // }}}
	run(template: String?, variables: Object = null, options = {}) { // {{{
		if variables? {
			options.varnames = Object.keys(variables).join()
		}

		template = this.compile(template, options)

		if variables? {
			return template.apply(null, Object.values(variables))
		}
		else {
			return template()
		}
	} // }}}
}

export const template = new Template({
	block_open: { // {{{
		regex: /\{\{\/\s*([\s\S]+?)\s*\}\}/g,
		replace(m, code) => "';" + this.unescape(code) + "{out+='"
	} // }}}
	block_close: { // {{{
		regex: /\{\{\\\\\s*([\s\S]+?)?\s*\}\}/g,
		replace(m, code?) => code? ? "';}" + this.unescape(code) + ";out+='" : "';}out+='"
	} // }}}
	comment: { // {{{
		regex: /\{\{--([\s\S]+?)--\}\}/g
		replace() => ''
	} // }}}
	conditional: { // {{{
		regex: /\{\{\?(\?)?\s*([\s\S]*?)\s*\}\}/g,
		replace(m, elsecase?, code) {
			if elsecase {
				if code.length != 0 {
					return "';}else if(" + this.unescape(code) + "){out+='"
				}
				else {
					return "';}else{out+='"
				}
			}
			else {
				if code.length != 0 {
					return "';if(" + this.unescape(code) + "){out+='"
				}
				else {
					return "';}out+='"
				}
			}
		}
	} // }}}
	encode: { // {{{
		regex: /\{\{!([\s\S]+?)\}\}/g,
		replace(m, code) {
			this.useEscape = true

			return this.cse.startencode + this.unescape(code) + this.cse.endencode
		}
	} // }}}
	evaluate: { // {{{
		regex: /\{\{\|([\s\S]+?)\|\}\}/g,
		replace(m, code) => "';" + $unescape(code.replace(/\/\/.*\n/g, '\n').replace(/\/\*([^\*]|(\*+([^\*\/])))*\*\/+/g, '')) + "out+='"
	} // }}}
	function: { // {{{
		regex: /\{\{#\s*(?:([^\}\(]+)\s*(?:\(([^\}]+)\)|\(\))?)?\s*\}\}/g,
		replace(m, name?, parameters = '') {
			if name? {
				if name.indexOf('.') != -1 || name.indexOf('[') != -1 {
					return "';" + name + "=function(" + parameters + "){var out='"
				}
				else {
					return "';var " + name + "=function(" + parameters + "){var out='"
				}
			}
			else {
				return "';return out;};out+='"
			}
		}
	} // }}}
	interpolate: { // {{{
		regex: /\{\{:([\s\S]+?)\}\}/g
		replace(m, code) => this.cse.start + this.unescape(code) + this.cse.end
	} // }}}
	iterate: { // {{{
		regex: /\{\{~\s*(?:\}\}|(~)?([\s\S]+?)\s*\:\s*([\w$]*)\s*(?:\:\s*([\w$]+))?\s*\}\})/g,
		replace(m, desc?, iterate?, vname?, iname?) {
			if !?iterate {
				return "';}}out+='"
			}
			this.sid += 1
			const indv = iname || "i" + this.sid
			iterate = $unescape(iterate)

			if vname {
				if desc {
					return "';var arr" + this.sid + "=" + iterate + ";if(arr" + this.sid + "){var " + vname + "," + indv + "=arr" + this.sid + ".length;while(" + indv + ">0){" + vname + "=arr" + this.sid + "[--" + indv + "];out+='"
				}
				else {
					return "';var arr" + this.sid + "=" + iterate + ";if(arr" + this.sid + "){var " + vname + "," + indv + "=-1,l" + this.sid + "=arr" + this.sid + ".length-1;while(" + indv + "<l" + this.sid + "){" + vname + "=arr" + this.sid + "[++" + indv + "];out+='"
				}
			}
			else {
				if desc {
					return "';var arr" + this.sid + "=" + iterate + ";if(arr" + this.sid + "){var " + indv + "=arr" + this.sid + ".length;while(" + indv + ">0){--" + indv + ";out+='"
				}
				else {
					return "';var arr" + this.sid + "=" + iterate + ";if(arr" + this.sid + "){var " + indv + "=-1,l" + this.sid + "=arr" + this.sid + ".length-1;while(" + indv + "<l" + this.sid + "){++" + indv + ";out+='"
				}
			}
		}
	} // }}}
	interator: { // {{{
		regex: /\{\{%\s*([\s\S]+?)\s*(?:\}\}|\:\s*([\w$]+)\s*\}\})/g,
		replace(m, iterate: String, valueName?) {
			if valueName? {
				return "';var " + valueName + "=" + $unescape(iterate) + ";" + "while(" + valueName + "){out+='"
			}
			else {
				return "';" + iterate.before('.') + "=" + $unescape(iterate) + ";}out+='"
			}
		}
	} // }}}
	oiterate: { // {{{
		regex: /\{\{\.\s*(?:\}\}|([\s\S]+?)\s*\:\s*([\w$]*)\s*(?:\:\s*([\w$]+))?\s*\}\})/g,
		replace(m, iterate?, valueName?, keyName?) {
			if !?iterate {
				return "';}}out+='"
			}
			const obj = 'iter' + (++this.sid)
			iterate = $unescape(iterate)

			if valueName? {
				keyName ??= "i" + this.sid
				return "';var " + keyName + "," + valueName + "," + obj + "=" + iterate + ";" +
					"if(" + obj + "){" +
						"for(" + keyName + " in " + obj + "){" +
							valueName + "=" + obj + "[" + keyName + "];out+='"
			}
			else {
				return "';var " + keyName + "," + obj + "=" + iterate + ";" +
					"if(" + obj + "){" +
						"for(" + keyName + " in " + obj + "){" +
							"out+='"
			}
		}
	} // }}}
	range_open: { // {{{
		regex: /\{\{\[\s*([\w$]+)\s+([\s\S]+)\.\.([^\}\s]+)\s*(?:\:\s*([\s\S]+)\s*)?\]\}\}/g,
		replace(m, iname, from: String, to: String, step: String?) {
			if from.toFloat() < to.toFloat() {
				return "';for(var " + iname + " = " + $unescape(from) + "; " + iname + " <= " + $unescape(to) + "; " + (step ? iname + " += " + $unescape(step) : "++" + iname) + ") {out+='"
			}
			else if from.toFloat() > to.toFloat() {
				return "';for(var " + iname + " = " + $unescape(from) + "; " + iname + " >= " + $unescape(to) + "; " + (step ? iname + " -= " + step.toFloat() : "--" + iname) + ") {out+='"
			}
			else {
				const indv = "l" + ++this.sid
				return "';for(var " + iname + " = " + $unescape(from) + ", " + indv + " = " + $unescape(to) + "; " + iname + " < " + indv + "; " + (step ? step.toFloat() < 0 ? step.toFloat() == -1 ? "--" + iname : iname + " -= " + $unescape(step) : iname + " += " + $unescape(step) : "++" + iname) + ") {out+='"
			}
		}
	} // }}}
	range_close: { // {{{
		regex: /\{\{\[\]\}\}/g,
		replace() => "';}out+='"
	} // }}}
	zgreat_escape: { // {{{
		regex: /\{\{`([\s\S]*)\}\}/g,
		replace(m, code) => '{{' + code + '}}'
	} // }}}
})