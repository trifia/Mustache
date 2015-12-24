//
//  Renderer.swift
//  Mustache
//
//  Created by Stan Chang Khin Boon on 24/12/15.
//  Copyright © 2015 Trifia. All rights reserved.
//

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
