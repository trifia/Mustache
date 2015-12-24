//
// Renderer.swift
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

protocol Renderable {
    func renderWithOperation(operation: Operation) -> String?
    func renderWithOperations(operations: [Operation]) -> String?
}

// Renderer render the operation(s) with the provided context if possible.
// Otherwise, it give control to the context, which based on its underlying implementation provide some form of control flow. The context might pass back control to renderer to attempt to rendering its subcontext. This resultant in a recursive rendering process.
struct Renderer {
    static func renderContext(context: Contextual, withOperation operation: Operation) -> String? {
        switch operation {
        case .Main(operations: let operations):
            return context.renderWithOperations(operations)
        case .RenderPartial(name: _):
            // FIXME: (stan@trifia.com) Handle partial
            return nil
        case .RenderValue(value: let value):
            return value
        case .RenderVariable(name: let name, escaped: _):
            // FIXME: (stan@trifia.com) Handle escaped
            return context.contextForName(name)?.description
        case .Section(name: let name, operations: let operations):
            guard let newContext = context.contextForName(name) else {
                return nil
            }
            return newContext.renderWithOperations(operations)
        case .InvertedSection(name: let name, operations: let operations):
            guard context.contextForName(name) == nil else {
                return nil
            }
            return context.renderWithOperations(operations)
        }
    }
    
    static func renderContext(context: Contextual, withOperations operations: [Operation]) -> String? {
        var stringBuffer = ""
        for operation in operations {
            if let renderedString = context.renderWithOperation(operation) {
                stringBuffer.appendContentsOf(renderedString)
            }
        }
        return stringBuffer.isEmpty ? nil : stringBuffer
    }
    
    static func renderContexts(contexts: [Contextual], withOperation operation: Operation) -> String? {
        var stringBuffer = ""
        for context in contexts {
            if let renderedString = renderContext(context, withOperation: operation) {
                stringBuffer.appendContentsOf(renderedString)
            }
        }
        return stringBuffer.isEmpty ? nil : stringBuffer
    }
    
    static func renderContexts(contexts: [Contextual], withOperations operations: [Operation]) -> String? {
        var stringBuffer = ""
        for context in contexts {
            if let renderedString = renderContext(context, withOperations: operations) {
                stringBuffer.appendContentsOf(renderedString)
            }
        }
        return stringBuffer.isEmpty ? nil : stringBuffer
    }
}
