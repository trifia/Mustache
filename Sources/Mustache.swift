//
// Mustache.swift
//
// Copyright (c) 2015 Trifia (http://trifia.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

/*
Context: Stacked, key are look up recursively upwards (child -> parent -> grandparent)
Context can be hash, lambdas, or object

Mustache Tags

- Multi???

- Static
 - just text
- Variables
 - HTML escaped by default (double mustache {{}}), triple mustache {{{}}} or prepend with & to return unescaped HTML
 - Variable miss return an empty string by default, but can throw an error if configured
- Sections
 - {{#begin}} {{/end}}
- Inverted Sections
 - {{^begin}} {{/end}}
- Comments
 - {{! comment }}
 - may contain new line
- Partials
- Set Delimiters
*/

enum Error : ErrorType {
    case SyntaxError(String)
}



// The parser
