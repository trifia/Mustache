//
//  Lexer.swift
//  Mustache
//
//  Created by Stan Chang Khin Boon on 20/12/15.
//  Copyright © 2015 Trifia. All rights reserved.
//

// The lexical analysis phase is near context free. The only exception is to implement Set Delimiter Tag which modify how the lexer find subsequent tags.
struct Lexer {
    // Context
    
    /// The delimiter used to identify tag. Default to `{{` and `}}`.
    var delimiter = Delimiter()
    
    // States
    
    var scanner: Scanner
    var lookahead: Token?
    
    init(_ data: String) {
        self.scanner = Scanner(string: data)
    }
    
    func hasNext() -> Bool {
        if self.lookahead != nil {
            return true
        } else {
            return self.scanner.hasNext()
        }
    }
    
    /// Consume the next token from the lexer.
    mutating func next() throws -> Token {
        if let lookahead = self.lookahead {
            self.lookahead = nil
            return lookahead
        }
        
        assert(self.scanner.hasNext())
        var delimiter = self.delimiter
        var result = self.scanner.scanUntil(delimiter.open.characters)
        
        var nextToken: Token? = nil
        if let staticCharacters = result.beforeCharacters {
            let staticToken = Token.Static(value: String(staticCharacters))
            nextToken = staticToken
        }
        
        if let openDelimiterRange = result.match {
            func __scanForTagRangeWithDelimiter(inout scanner: Scanner, delimiter: Delimiter, openDelimiterRange: Range<String.CharacterView.Index>) throws -> Range<String.CharacterView.Index> {
                let closeResult = scanner.scanUntil(delimiter.close.characters)
                guard let closeDelimiterRange = closeResult.match else {
                    throw Error.SyntaxError("No matching closing delimiter. Expecting \(delimiter.close)…")
                }
                let tagRange = openDelimiterRange.endIndex..<closeDelimiterRange.startIndex
                guard !tagRange.isEmpty else {
                    throw Error.SyntaxError("Empty tag is not allowed…")
                }
                return tagRange
            }
            
            var peekResult = self.scanner.peek()
            
            guard let peekRange = peekResult.match else {
                throw Error.SyntaxError("Could not determine section… Likely reached end of file…")
            }
            let matchCharacter = peekResult.characters[peekRange]
            var tagToken: Token!
            switch String(matchCharacter) {
            case "#": // Section Begin
                self.scanner.skip(&peekResult)
                let updatedOpenDelimiterRange = openDelimiterRange.startIndex..<peekRange.endIndex
                let tagRange = try __scanForTagRangeWithDelimiter(&self.scanner, delimiter: delimiter, openDelimiterRange: updatedOpenDelimiterRange)
                tagToken = Token.SectionBegin(name: String(self.scanner[tagRange]), inverted: false)
            case "^": // Section Begin (Inverted)
                self.scanner.skip(&peekResult)
                let updatedOpenDelimiterRange = openDelimiterRange.startIndex..<peekRange.endIndex
                let tagRange = try __scanForTagRangeWithDelimiter(&self.scanner, delimiter: delimiter, openDelimiterRange: updatedOpenDelimiterRange)
                tagToken = Token.SectionBegin(name: String(self.scanner[tagRange]), inverted: true)
            case "/": // Section End
                self.scanner.skip(&peekResult)
                let updatedOpenDelimiterRange = openDelimiterRange.startIndex..<peekRange.endIndex
                let tagRange = try __scanForTagRangeWithDelimiter(&self.scanner, delimiter: delimiter, openDelimiterRange: updatedOpenDelimiterRange)
                tagToken = Token.SectionEnd(name: String(self.scanner[tagRange]))
            case "!": // Comment
                self.scanner.skip(&peekResult)
                let updatedOpenDelimiterRange = openDelimiterRange.startIndex..<peekRange.endIndex
                let tagRange = try __scanForTagRangeWithDelimiter(&self.scanner, delimiter: delimiter, openDelimiterRange: updatedOpenDelimiterRange)
                tagToken = Token.Comment(value: String(self.scanner[tagRange]))
            case ">": // Partial
                self.scanner.skip(&peekResult)
                let updatedOpenDelimiterRange = openDelimiterRange.startIndex..<peekRange.endIndex
                let tagRange = try __scanForTagRangeWithDelimiter(&self.scanner, delimiter: delimiter, openDelimiterRange: updatedOpenDelimiterRange)
                tagToken = Token.Partial(name: String(self.scanner[tagRange]))
            case "=": // Set Delimiter
                // FIXME: (stan@trifia.com) Update the delimiter.
                fallthrough
            case "{": // {
                self.scanner.skip(&peekResult)
                delimiter = delimiter.modifiedDelimiterWithOpen("{", close: "}")
                let updatedOpenDelimiterRange = openDelimiterRange.startIndex..<peekRange.endIndex
                let tagRange = try __scanForTagRangeWithDelimiter(&self.scanner, delimiter: delimiter, openDelimiterRange: updatedOpenDelimiterRange)
                tagToken = Token.Variable(name: String(self.scanner[tagRange]), escaped: false)
            default: // Treated as variables
                let tagRange = try __scanForTagRangeWithDelimiter(&self.scanner, delimiter: delimiter, openDelimiterRange: openDelimiterRange)
                tagToken = Token.Variable(name: String(self.scanner[tagRange]), escaped: false)
            }
            
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
    
    mutating func tokenize() throws -> [Token] {
        var tokens = [Token]()
        while self.hasNext() {
            tokens.append(try self.next())
        }
        assert(!self.hasNext())
        return tokens
    }
}
