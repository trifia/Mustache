//
// Parser.swift
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

struct Parser {
    enum Scope {
        case Main
        case Section(name: String, inverted: Bool)
    }
    enum Operation {
        case RenderValue(value: String)
        case RenderVariable(name: String, escaped: Bool)
        case RenderPartial(name: String)
        
        indirect case Main(operations: [Operation])
        indirect case Section(name: String, operations: [Operation])
        indirect case InvertedSection(name: String, operations: [Operation])
    }
    
    let tokens: Array<Lexer.Token>
    
    init(tokens: Array<Lexer.Token>) {
        self.tokens = tokens
    }
    
    func parse() throws -> Operation {
        var generator = tokens.generate()
        var stack = Stack<(Scope, [Operation])>()
        
        var operations = [Operation]()
        var scope = Scope.Main
        while let token = generator.next() {
            switch token {
            case .Static(let value):
                operations.append(Operation.RenderValue(value: value))
            case .Variable(let name, let escaped):
                operations.append(Operation.RenderVariable(name: name, escaped: escaped))
            case .SectionBegin(let name, let inverted):
                stack.push((scope, operations))
                (scope, operations) = (Scope.Section(name: name, inverted: inverted), [Operation]())
            case .SectionEnd(let endName):
                switch scope {
                case .Section(let name, let inverted) where name == endName:
                    let section = inverted ? Operation.InvertedSection(name: name, operations: operations) : Operation.Section(name: name, operations: operations)
                    (scope, operations) = stack.pop()
                    operations.append(section)
                default:
                    throw Error.SyntaxError("Section ended before it began…")
                }
            case .Partial(let name):
                operations.append(Operation.RenderPartial(name: name))
                break;
            case .SetDelimiter:
                // Set Delimiter is handled by the lexer… Ignoring…
                break
            case .Comment:
                // Comments are naturally being ignored…
                break
            }
        }
        switch scope {
        case .Main:
            return Operation.Main(operations: operations)
        default:
            throw Error.SyntaxError("Section not closed before file ended…")
        }
    }
}
