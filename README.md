[@zokugun/template](https://github.com/ZokugunKS/template)
==========================================================

[![kaoscript](https://img.shields.io/badge/language-kaoscript-orange.svg)](https://github.com/kaoscript/kaoscript)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)
[![NPM Version](https://img.shields.io/npm/v/@zokugun/template.svg?colorB=green)](https://www.npmjs.com/package/@zokugun/template)
[![Dependency Status](https://badges.depfu.com/badges//overview.svg)](https://depfu.com/github/ZokugunKS/template)
[![Build Status](https://travis-ci.org/ZokugunKS/template.svg?branch=master)](https://travis-ci.org/ZokugunKS/template)
[![CircleCI](https://circleci.com/gh/ZokugunKS/template/tree/master.svg?style=shield)](https://circleci.com/gh/ZokugunKS/template/tree/master)
[![Coverage Status](https://img.shields.io/coveralls/ZokugunKS/template/master.svg)](https://coveralls.io/github/ZokugunKS/template)

It is a fast template engine forked from [doT](https://github.com/olado/doT) with extended and extendable tags.

Getting Started
---------------

### In Node.js

With [node](http://nodejs.org) previously installed:

	npm install @zokugun/template

Use it with `JavaScript`:

```javascript
require('kaoscript/register');

const { Template } = require('@zokugun/template')();

const myTemplate = template.compile(`It's nice to meet you, {{:it}}.`);

console.log(myTemplate('miss White'));
```

Use it with `kaoscript`:

```kaoscript
import '@zokugun/template'

const myTemplate = template.compile(`It's nice to meet you, {{:it}}.`)

console.log(myTemplate('miss White'))
```

Differences from doT
--------------------

doT			| zokugun.template					| Description
---			| ----------------					| -----------
`{{ }}`		| <code>{{&#124; &#124;}}</code>	| for evaluation
`{{= }}`	| `{{: }}`							| for interpolation
`{{! }}`	| `{{! }}`							| for interpolation with encoding
`{{# }}`	| use `{{: }}`						| for using partials
`{{## #}}`	| `{{#name(args)}} {{#}}`			| for defining partials
`{{? }}`	| `{{? }}`							| for conditionals
`{{~ }}`	| `{{~ }}`							| for array iteration
			| `{{. }}`							| for object iteration
			| `{{% }}`							| for iterator
			| `{{[ ]}}`							| for range iteration
			| `{{/ }}` `{{\ }}`					| for block
			| <code>{{` }}</code>				| for escaping template
			| `{{-- --}}`						| for comments

`{{ }}` has been changed to `{{| |}}` to be able to do:

```
{{|
	function hello(name) {
		if(arguments.length) {
			return 'hello ' + name;
		}
		else {
			return 'hello world!';
		}
	};
|}}
{{:hello('foo')}}
```

API
---

```kaoscript
import '@zokugun/template'
```

The variable *template* is the default template compiler. It contains the tags describe below.

### template.new(tags, options)

The default compiler contains the extra method *new* which allows you to create new template compiler.

The arguments *tags* and *options* can be optionals.
By default, *options* will be:

```
{
	varnames: 'it',
	strip: true,      // remove spaces in javascript code. Be careful of missing ;
	append: true      // use string concatenation or addition assignment operator
}
```

Example:

```kaosscript
const custom = template.new({
	interpolate: {
		regex: /\$\{([\s\S]+?)\}/g
		replace(m, code) => this.cse.start + 'it.' + code + this.cse.end
	}
})

const hello = custom.compile('Hello ${firstname}')

console.log(hello({
	firstname: 'John'
	lastname: 'Doe'
}))
```

### template.addTag(name, regex, replace)

The method *addTag* allow you to add new tag so he can extends the compiler.
The tags are executed in alphabetic order. So its name will determine when the tag will be executed.

The function *replace* will be called as in str.replace(*regex*, *replace*) excepted that the variable *this* will an object like:

```
{
	cse: {
		start: string,         // start of the code
		end: string,           // end of the code
		startencode: string,   // start of the code that will be HTML escaped
		endencode: string      // end of the code that will be HTML escaped
	},
	unescape(str),   // unescape the code to pass from the template to the function's code
	sid: integer               // the sid for the variables' names
}
```

### template.clearTags()

The method *clearTags* removes all the tags defined in the compiler.

### template.compile(template, options)

The function *compile* returns a function based of the string *template*.
The argument *options* will overwrite the default options of the compiler.

The first line of the *template* can also contains options for the compiler. It must start with '{{}} ' and the options separated with spaces.

```
{{}} strip:true
hello {{:it.firstname}}
```

```
{{}} strip:false varnames:firstname,lastname
hello {{:firstname}}
```

### template.removeTag(name)

The method *clearTags* removes the tag named *name*.

### template.run(template, variables, options)

The method *run* will firstly compiles the *template* with the *options* and the *variables*' names. Then it will execute the resulting function with the *variables*.

```
console.log(template.run('It\'s nice to meet you, {{:name}}.', {
	name: 'miss White'
}))
```

This is the least efficient to use a template. Because the template will be compiled every time.

Tags
----

### Interpolation

<table>
	<thead>
		<tr>
			<th>Template</th>
			<th>Data</th>
			<th>Result</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td>
				<pre>
```
<div>It\'s nice to meet you, {{:it.name}}!</div>
<div>Today, you have {{:it.age}}.</div>
```
				</pre>
			</td>
			<td>
				<pre>
<code class="lang-javascript">{
	name: 'Jake',
	age: 32
}</code>
				</pre>
			</td>
			<td>
				<pre>
```
<div>It\'s nice to meet you, Jake!</div>
<div>Today, you have 31.</div>
```
				</pre>
			</td>
		</tr>
	</tbody>
</table>

### Interpolation with encoding

<table>
	<thead>
		<tr>
			<th>Template</th>
			<th>Data</th>
			<th>Result</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td>
				<pre>
```
<a href="{{!it.url}}">{{:it.title}}</a>
```
				</pre>
			</td>
			<td>
				<pre>
<code class="lang-javascript">{
	title: 'github',
	url: 'https://github.com'
}</code>
				</pre>
			</td>
			<td>
				<pre>
```
<a href="https://github.com">github</a>
```
				</pre>
			</td>
		</tr>
	</tbody>
</table>

### Evaluation

<table>
	<thead>
		<tr>
			<th>Template</th>
			<th>Data</th>
			<th>Result</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td>
				<pre>
```
{{|
	function hello(name) {
		if(arguments.length) {
			return 'hello ' + name;
		}
		else {
			return 'hello world!';
		}
	};
|}}
<div>{{:hello(it.name)}}</div>
```
				</pre>
			</td>
			<td>
				<pre>
<code class="lang-javascript">{
	name: 'Jake'
}</code>
				</pre>
			</td>
			<td>
				<pre>
```
<div>hello Jake</div>
```
				</pre>
			</td>
		</tr>
	</tbody>
</table>

### Conditionals

<table>
	<thead>
		<tr>
			<th>Template</th>
			<th>Data</th>
			<th>Result</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td rowspan="3">
				<pre>
```
{{?it.morning}}
good morning
{{??it.evening}}
good evening
{{??}}
hello
{{?}}
```
				</pre>
			</td>
			<td>
				<pre>
```
{
	morning: true
}
```
				</pre>
			</td>
			<td>
				<pre>
```
good morning
```
				</pre>
			</td>
		</tr>
		<tr>
			<td>
				<pre>
```
{
	evening: true
}
```
				</pre>
			</td>
			<td>
				<pre>
```
good evening
```
				</pre>
			</td>
		</tr>
		<tr>
			<td>
				<pre>
```
{
}
```
				</pre>
			</td>
			<td>
				<pre>
```
hello
```
				</pre>
			</td>
		</tr>
	</tbody>
</table>

### Array Iteration

<table>
	<thead>
		<tr>
			<th>Template</th>
			<th>Data</th>
			<th>Result</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td>
				<pre>
```
{{~it :value}}
<div>{{:value}}</div>
{{~}}
```
				</pre>
			</td>
			<td rowspan="4">
				<pre>
```
['banana','apple','orange']
```
				</pre>
			</td>
			<td>
				<pre>
```
<div>banana</div>
<div>apple</div>
<div>orange</div>
```
				</pre>
			</td>
		</tr>
		<tr>
			<td>
				<pre>
```
{{~it :value:index}}
<div class="fruit{{:index%2}}">{{:value}}</div>
{{~}}
```
				</pre>
			</td>
			<td>
				<pre>
```
<div class="fruit0">banana</div>
<div class="fruit1">apple</div>
<div class="fruit0">orange</div>
```
				</pre>
			</td>
		</tr>
		<tr>
			<td>
				<pre>
```
{{~~it :value}}
<div>{{:value}}</div>
{{~}}
```
				</pre>
			</td>
			<td>
				<pre>
```
<div>orange</div>
<div>apple</div>
<div>banana</div>
```
				</pre>
			</td>
		</tr>
		<tr>
			<td>
				<pre>
```
{{~~it :value:index}}
<div class="fruit{{:index%2}}">{{:value}}</div>
{{~}}
```
				</pre>
			</td>
			<td>
				<pre>
```
<div class="fruit0">orange</div>
<div class="fruit1">apple</div>
<div class="fruit0">banana</div>
```
				</pre>
			</td>
		</tr>
	</tbody>
</table>

### Object Iteration

<table>
	<thead>
		<tr>
			<th>Template</th>
			<th>Data</th>
			<th>Result</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td>
				<pre>
```
{{.it :value}}
<div>{{:value}}</div>
{{.}}
```
				</pre>
			</td>
			<td rowspan="2">
				<pre>
```
{
	firstname: 'John',
	lastname: 'Doe',
	age: 25
}
```
				</pre>
			</td>
			<td>
				<pre>
```
<div>John</div>
<div>Doe</div>
<div>25</div>
```
				</pre>
			</td>
		</tr>
		<tr>
			<td>
				<pre>
```
{{.it :value:key}}
<div class="{{:key}}">{{:value}}</div>
{{.}}
```
				</pre>
			</td>
			<td>
				<pre>
```
<div class="firstname">John</div>
<div class="lastname">Doe</div>
<div class="age">25</div>
```
				</pre>
			</td>
		</tr>
	</tbody>
</table>

### Iterator

<table>
	<thead>
		<tr>
			<th>Template</th>
			<th>Data</th>
			<th>Result</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td>
				<pre>
```
{{%iterator.first() :item}}
{{:item.name()}}
{{%iterator.next()}}
```
				</pre>
			</td>
			<td>
			</td>
			<td>
			</td>
		</tr>
	</tbody>
</table>

### Range Iteration

<table>
	<thead>
		<tr>
			<th>Template</th>
			<th>Data</th>
			<th>Result</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td>
				<pre>
```
{{[i 0..3]}}
{{:i}}
{{[]}}
```
				</pre>
			</td>
			<td rowspan="3">
				<pre>
```
{
}
```
				</pre>
			</td>
			<td>
				<pre>
```
0
1
2
3
```
				</pre>
			</td>
		</tr>
		<tr>
			<td>
				<pre>
```
{{[i 3..0]}}
{{:i}}
{{[]}}
```
				</pre>
			</td>
			<td>
				<pre>
```
3
2
1
0
```
				</pre>
			</td>
		</tr>
		<tr>
			<td>
				<pre>
```
{{[i 0..3 :2]}}
{{:i}}
{{[]}}
```
				</pre>
			</td>
			<td>
				<pre>
```
0
1
```
				</pre>
			</td>
		</tr>
		<tr>
			<td>
				<pre>
```
{{[i 0..it]}}
{{:i}}
{{[]}}
```
				</pre>
			</td>
			<td>
				<pre>
```
3
```
				</pre>
			</td>
			<td>
				<pre>
```
0
1
2
3
```
				</pre>
			</td>
		</tr>
	</tbody>
</table>

### Partials

<table>
	<thead>
		<tr>
			<th>Template</th>
			<th>Data</th>
			<th>Result</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td>
				<pre>
```
{{#hello}}
	Hello world!
{{#}}

{{:hello()}}
```
				</pre>
			</td>
			<td>
				<pre>
```
{
}
```
				</pre>
			</td>
			<td>
				<pre>
```
Hello world!
```
				</pre>
			</td>
		</tr>
		<tr>
			<td>
				<pre>
```
{{#hello(name)}}
	Hello {{:name}}!
{{#}}

{{:hello(it.name)}}
```
				</pre>
			</td>
			<td>
				<pre>
```
{
	name: 'Jake'
}
```
				</pre>
			</td>
			<td>
				<pre>
```
Hello Jake!
```
				</pre>
			</td>
		</tr>
	</tbody>
</table>

### Blocks

<table>
	<thead>
		<tr>
			<th>Template</th>
			<th>Data</th>
			<th>Result</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td>
				<pre>
```
{{|var i = 0;|}}
{{/do}}
{{:i}}
{{\while(++i <= 3)}}
```
				</pre>
			</td>
			<td>
				<pre>
```
{
}
```
				</pre>
			</td>
			<td>
				<pre>
```
0
1
2
3
```
				</pre>
			</td>
		</tr>
		<tr>
			<td>
				<pre>
```
{{/for(var i = 0; i <= 3; i++)}}
{{:i}}
{{\}}
```
				</pre>
			</td>
			<td>
				<pre>
```
{
}
```
				</pre>
			</td>
			<td>
				<pre>
```
0
1
2
3
```
				</pre>
			</td>
		</tr>
	</tbody>
</table>

### Comments

<table>
	<thead>
		<tr>
			<th>Template</th>
			<th>Data</th>
			<th>Result</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td>
				<pre>
```
Hello {{--{{:it.name}}--}}
```
				</pre>
			</td>
			<td>
				<pre>
```
{
	name: 'Jake'
}
```
				</pre>
			</td>
			<td>
				<pre>
```
Hello
```
				</pre>
			</td>
		</tr>
	</tbody>
</table>

### Escape

<table>
	<thead>
		<tr>
			<th>Template</th>
			<th>Data</th>
			<th>Result</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td>
				<pre>
```
Hello {{`it.name}}
```
				</pre>
			</td>
			<td>
				<pre>
```
{
	name: 'Jake'
}
```
				</pre>
			</td>
			<td>
				<pre>
```
Hello {{it.name}}
```
				</pre>
			</td>
		</tr>
	</tbody>
</table>

Forked from
-----------

* [Laura Doktorova's doT](https://github.com/olado/doT)
* [Mario Gutierrez's doT](https://github.com/mgutz/doT)

License
-------

[MIT](http://www.opensource.org/licenses/mit-license.php) &copy; Baptiste Augrain