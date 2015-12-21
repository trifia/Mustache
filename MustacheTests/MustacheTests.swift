//
//  MustacheTests.swift
//  MustacheTests
//
//  Created by Stan Chang Khin Boon on 20/12/15.
//  Copyright © 2015 Trifia. All rights reserved.
//

import XCTest
@testable import Mustache

class MustacheTests: XCTestCase {
    func testExample() {
        var lexer = Lexer("Hello {{name}}")
        do {
            let tokens = try lexer.tokens()
            print(tokens)
        } catch {
            XCTFail()
        }
    }
    
    func testExample2() {
        var lexer = Lexer("You have just won {{value}} dollars!")
        do {
            let tokens = try lexer.tokens()
            print(tokens)
        } catch {
            XCTFail()
        }
    }
    
    func testExample3() {
        var lexer = Lexer("{{#in_ca}}\nWell, {{taxed_value}} dollars, after taxes.\n{{/in_ca}}")
        do {
            let tokens = try lexer.tokens()
            print(tokens)
        } catch {
            XCTFail()
        }
    }
    
    func testExample4() {
        var lexer = Lexer("    * {{name}}\n    * {{age}}\n    * {{company}}\n    * {{{company}}}")
        do {
            let tokens = try lexer.tokens()
            print(tokens)
        } catch {
            XCTFail()
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
