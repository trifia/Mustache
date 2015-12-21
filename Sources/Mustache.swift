//
//  Mustache.swift
//  Mustache
//
//  Created by Stan Chang Khin Boon on 20/12/15.
//  Copyright © 2015 Trifia. All rights reserved.
//

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
