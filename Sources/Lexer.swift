//
// Lexer.swift
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

// The lexical analysis phase is near context free. The only exception is to implement Set Delimiter Tag which modify how the lexer find subsequent tags.
struct Lexer {
    // MARK: Context
    
    /// The delimiter used to identify tag. Default to `{{` and `}}`.
    var delimiter = Delimiter()
    
    // MARK: States
    
    var scanner: Scanner
    var lookahead: Lookahead?
    
    init(_ string: String) {
        self.scanner = Scanner(string: string)
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
        if let (token, end) = self.lookahead?.nextToken() {
            if end {
                self.lookahead = nil
            }
            return token
        } else {
            var lookahead = try self.nextLookahead()
            guard let (token, end) = lookahead.nextToken() else {
                throw Error.SyntaxError("Unexpected end of file…")
            }
            if !end {
                self.lookahead = lookahead
            } else {
                self.lookahead = nil
            }
            return token
        }
    }
    
    mutating func nextLookahead() throws -> Lookahead {
        assert(self.scanner.hasNext())
        
        var tokens = [Token]()
        
        var delimiter = self.delimiter
        var openResult = self.scanner.scanUntil(delimiter.open.characters)
        
        if let staticCharacters = openResult.beforeCharacters {
            let value = String(staticCharacters)
            let staticToken = Token.Static(value: value)
            tokens.append(staticToken)
        }
        
        if let openDelimiterRange = openResult.match {
            var peekResult = self.scanner.peek()
            guard let peekRange = peekResult.match else {
                throw Error.SyntaxError("Could not determine section… Likely reached end of file…")
            }
            let matchCharacter = peekResult.characters[peekRange]
            
            func __remainingTagBeforeCloseDelimiter(inout scanner: Scanner, delimiter: Delimiter) throws -> String.CharacterView {
                let closeResult = scanner.scanUntil(delimiter.close.characters)
                guard closeResult.match != nil else {
                    throw Error.SyntaxError("No matching closing delimiter. Expecting \(delimiter.close)…")
                }
                guard let tag = closeResult.beforeCharacters else {
                    throw Error.SyntaxError("Empty tag is not allowed…")
                }
                return tag
            }
            
            switch String(matchCharacter) {
            case "#": // Section Begin
                self.scanner.skip(&peekResult)
                let name = String(try __remainingTagBeforeCloseDelimiter(&self.scanner, delimiter: delimiter))
                let sectionBeginToken = Token.SectionBegin(name: name, inverted: false)
                tokens.append(sectionBeginToken)
                
            case "^": // Inverted Section Begin
                self.scanner.skip(&peekResult)
                let name = String(try __remainingTagBeforeCloseDelimiter(&self.scanner, delimiter: delimiter))
                let sectionBeginToken = Token.SectionBegin(name: name, inverted: true)
                tokens.append(sectionBeginToken)
                
            case "/": // Section End
                self.scanner.skip(&peekResult)
                let name = String(try __remainingTagBeforeCloseDelimiter(&self.scanner, delimiter: delimiter))
                let sectionEndToken = Token.SectionEnd(name: name)
                tokens.append(sectionEndToken)
                
            case "!": // Comment
                self.scanner.skip(&peekResult)
                let value = String(try __remainingTagBeforeCloseDelimiter(&self.scanner, delimiter: delimiter))
                let commentToken = Token.Comment(value: value)
                tokens.append(commentToken)
                
            case ">": // Partial
                self.scanner.skip(&peekResult)
                let name = String(try __remainingTagBeforeCloseDelimiter(&self.scanner, delimiter: delimiter))
                let partialToken = Token.Partial(name: name)
                tokens.append(partialToken)
                
            case "=": // Set Delimiter
                self.scanner.skip(&peekResult)
                delimiter = delimiter.modifiedDelimiterWithOpen("=", close: "=")
                let characters = try __remainingTagBeforeCloseDelimiter(&self.scanner, delimiter: delimiter)
                let delimiterComponents = characters.split(" ", maxSplit: Int.max, allowEmptySlices: false)
                guard delimiterComponents.count == 2 else {
                    throw Error.SyntaxError("Define an invalid number of delimiters.")
                }
                let open = String(delimiterComponents[0])
                let close = String(delimiterComponents[1])
                self.delimiter = Delimiter(open: open, close: close)
                let setDelimiterToken = Token.SetDelimiter(open: open, close: close)
                tokens.append(setDelimiterToken)
                
            case "{": // Variable (Unescaped)
                delimiter = delimiter.modifiedDelimiterWithOpen("{", close: "}")
                fallthrough
            case "&": // Variable (Unescaped)
                self.scanner.skip(&peekResult)
                let name = String(try __remainingTagBeforeCloseDelimiter(&self.scanner, delimiter: delimiter))
                let variableToken = Token.Variable(name: name, escaped: false)
                tokens.append(variableToken)
                
            default: // Variable
                let name = String(try __remainingTagBeforeCloseDelimiter(&self.scanner, delimiter: delimiter))
                let variableToken = Token.Variable(name: name, escaped: true)
                tokens.append(variableToken)
            }
        } else {
            self.scanner.skip(&openResult)
            assert(openResult.consumed)
        }
        
        return Lookahead(tokens: tokens)
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
