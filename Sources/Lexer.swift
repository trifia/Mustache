//
//  Lexer.swift
//  Mustache
//
//  Created by Stan Chang Khin Boon on 20/12/15.
//  Copyright © 2015 Trifia. All rights reserved.
//

extension String.CharacterView : Equatable {
}
public func ==(lhs: String.CharacterView, rhs: String.CharacterView) -> Bool {
    if lhs.count == rhs.count {
        for (lc, rc) in zip(lhs, rhs) {
            if lc != rc {
                return false
            }
        }
        return true
    } else {
        return false
    }
}

// The lexical analysis phase is near context free. The only exception is to implement Set Delimiter Tag which modify how the lexer find subsequent tags.
struct Lexer {
    enum Token {
        // Tag Types
        case Variable(name: String)
        case SectionBegin(name: String, inverted: Bool)
        case SectionEnd(name: String)
        case Comment(value: String)
        case Partial(name: String)
        case SetDelimiter(value: String)
        
        // Others
        case Static(value: String)
    }
    
    struct Delimiter {
        let open = "{{"
        let close = "}}"
    }
    
    // Context
    
    /// The delimiter used to identify tag. Default to `{{` and `}}`.
    var delimiter = Delimiter()
    
    // States
    
    var scanner: Scanner
    var lookahead: Token?
    
    init(_ data: String) {
        self.scanner = Scanner(string: data)
    }
    
    /// Consume the next token from the lexer.
    mutating func next() throws -> Token {
        if let lookahead = self.lookahead {
            self.lookahead = nil
            return lookahead
        }
        
        assert(self.scanner.hasNext())
        var result = self.scanner.scanUntil(self.delimiter.open.characters)
        
        var nextToken: Token? = nil
        if let staticCharacters = result.beforeCharacters {
            let staticToken = Token.Static(value: String(staticCharacters))
            nextToken = staticToken
        }
        
        if let openDelimiterRange = result.match {
            let closeResult = self.scanner.scanUntil(self.delimiter.close.characters)
            guard let closeDelimiterRange = closeResult.match else {
                throw Error.SyntaxError("No matching closing delimiter. Expecting \(self.delimiter.close)…")
            }
            
            let tagRange = openDelimiterRange.endIndex..<closeDelimiterRange.startIndex
            let tagToken = Token.Variable(name: String(self.scanner[tagRange]))
            if nextToken == nil {
                nextToken = tagToken
            } else {
                assert(self.lookahead == nil)
                self.lookahead = tagToken
            }
        } else {
            self.scanner.skip(&result)
            assert(result.consumed)
        }
        return nextToken!
    }
    
    mutating func tokens() throws -> [Token] {
        var tokens = [Token]()
        while self.scanner.hasNext() {
            tokens.append(try self.next())
        }
        assert(!self.scanner.hasNext())
        return tokens
    }
}
