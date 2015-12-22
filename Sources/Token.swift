//
//  Token.swift
//  Mustache
//
//  Created by Stan Chang Khin Boon on 22/12/15.
//  Copyright © 2015 Trifia. All rights reserved.
//

import Foundation

extension Lexer {
    enum Token {
        case Static(value: String)
        
        // Tag Types
        case Variable(name: String, escaped: Bool)
        case SectionBegin(name: String, inverted: Bool)
        case SectionEnd(name: String)
        case Comment(value: String)
        case Partial(name: String)
        case SetDelimiter(open: String, close: String)
    }
}
