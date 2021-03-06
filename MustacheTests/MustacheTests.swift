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
        let string = "Hello {{name}}"
        do {
            let template = try Mustache.compile(string)
            let context: DictionaryContext = [
                "name": "Stan"
            ]
            print(template.render(context))
        } catch {
            XCTFail()
        }
    }
    
    func testExample2() {
        var lexer = Lexer("You have just won {{value}} dollars!")
        do {
            let tokens = try lexer.tokenize()
            let parser = Parser(tokens: tokens)
            let mainOperation = try parser.parse()
            let template = try! Template(operation: mainOperation)
            let context: DictionaryContext = [
                "value": "$5"
            ]
            print(template.render(context))
        } catch {
            XCTFail()
        }
    }
    
    func testExample3() {
        let string = "{{#in_ca}}\nWell, {{taxed_value}} dollars, after taxes.\n{{/in_ca}}{{^in_ca}}\nNo tax burden!\n{{/in_ca}}"
        do {
            let template = try Mustache.compile(string)
            
            let context: DictionaryContext = [
                "in_ca": ArrayContext([
                    DictionaryContext([
                        "taxed_value" : "$100"
                    ]),
                    DictionaryContext([
                        "taxed_value" : "$200"
                    ]),
                    DictionaryContext([
                        "taxed_value" : "$300"
                    ]),
                    DictionaryContext([
                        "taxed_value" : "$400"
                    ]),
                ])
            ]
            print(template.render(context))
            let context2: DictionaryContext = [
                "in_ca": DictionaryContext([
                    "taxed_value" : "$100"
                ]),
            ]
            print(template.render(context2))
            let context3: DictionaryContext = DictionaryContext(Dictionary<String, Contextual>())
            print(template.render(context3))
        } catch {
            XCTFail()
        }
    }
    
    func testExample4() {
        let string = "    * {{name}}\n    * {{age}}\n    * {{company}}\n    * {{{company}}}\n    * {{&company}}"
        do {
            let template = try Mustache.compile(string)
            let context: DictionaryContext = [
                "name": "Stan",
                "age": "29",
                "company": "trifia",
            ]
            print(template.render(context))
        } catch {
            XCTFail()
        }
    }
    
    func testExample5() {
        let string = "{{#a}}\n{{one}}\n{{#b}}\n{{one}}{{two}}{{one}}\n{{#c}}\n{{one}}{{two}}{{three}}{{two}}{{one}}\n{{#d}}\n{{one}}{{two}}{{three}}{{four}}{{three}}{{two}}{{one}}\n{{#e}}\n{{one}}{{two}}{{three}}{{four}}{{five}}{{four}}{{three}}{{two}}{{one}}\n{{/e}}\n{{one}}{{two}}{{three}}{{four}}{{three}}{{two}}{{one}}\n{{/d}}\n{{one}}{{two}}{{three}}{{two}}{{one}}\n{{/c}}\n{{one}}{{two}}{{one}}\n{{/b}}\n{{one}}\n{{/a}}"
        do {
            let template = try Mustache.compile(string)
            print(template.operation)
            let context: DictionaryContext = [
                "a" : DictionaryContext([ "one" : "1" ]),
                "b" : DictionaryContext([ "two" : "2" ]),
                "c" : DictionaryContext([ "three" : "3" ]),
                "d" : DictionaryContext([ "four" : "4" ]),
                "e" : DictionaryContext([ "five" : "5" ]),
            ]
            if let renderedString = template.render(context) {
                print(renderedString)
            }
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
