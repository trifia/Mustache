//
//  Lookahead.swift
//  Mustache
//
//  Created by Stan Chang Khin Boon on 22/12/15.
//  Copyright © 2015 Trifia. All rights reserved.
//

extension Lexer {
    struct Lookahead {
        let tokens: Array<Token>
        var index: Array<Token>.Index
        
        init(tokens: Array<Token>) {
            self.tokens = tokens
            self.index = self.tokens.startIndex
        }
        
        func hasNextToken() -> Bool {
            return self.index < self.tokens.endIndex
        }
        
        mutating func nextToken() -> (token: Token, end: Bool)? {
            guard self.hasNextToken() else {
                return nil
            }
            let token = self.tokens[self.index]
            self.index = self.index.successor()
            return (token, !self.hasNextToken())
        }
    }
}
