//
//  Delimiter.swift
//  Mustache
//
//  Created by Stan Chang Khin Boon on 22/12/15.
//  Copyright © 2015 Trifia. All rights reserved.
//

extension Lexer {
    struct Delimiter {
        let open: String
        let close: String
        
        init(open: String = "{{", close: String = "}}") {
            self.open = open
            self.close = close
        }
        
        func modifiedDelimiterWithOpen(open: String, close: String = "") -> Delimiter {
            return Delimiter(open: self.open + open, close: close + self.close)
        }
    }
}