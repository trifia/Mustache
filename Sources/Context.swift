//
//  Context.swift
//  Mustache
//
//  Created by Stan Chang Khin Boon on 24/12/15.
//  Copyright © 2015 Trifia. All rights reserved.
//

protocol Contextual : CustomStringConvertible, Renderable {
    func contextForName(name: String) -> Contextual?
}

// MARK: Extensions

// The extension will use the renderer to render instead.

extension String : Contextual {
    func contextForName(name: String) -> Contextual? {
        return nil
    }
    public var description: String {
        return self
    }
    func renderWithOperation(operation: Operation) -> String? {
        return Renderer.renderContext(self, withOperation: operation)
    }
    func renderWithOperations(operations: [Operation]) -> String? {
        return Renderer.renderContext(self, withOperations: operations)
    }
}

// FIXME: (stan@trifia.com) [Swift 2.1 Limitation, rdar://23196859] Constrainted extension can't inherited protocol
//extension Dictionary /*: Contextual*/ where Key:Hashable, Value:Contextual {
//}
// Workaround for the above limitation…
struct DictionaryContext : Contextual, DictionaryLiteralConvertible {
    typealias Key = String
    typealias Value = Contextual
    
    let _value: [Key : Value]
    init(_ value: [Key : Value]) {
        self._value = value
    }
    init(dictionaryLiteral elements: (Key, Value)...) {
        // FIXME: (stan@trifia.com) Swift 2.1 limitation…
        //self._value = Dictionary<Key, Value>(dictionaryLiteral: elements)
        var dictionary = Dictionary<Key, Value>()
        for (key, value) in elements {
            dictionary[key] = value
        }
        self.init(dictionary)
    }
    func contextForName(name: String) -> Contextual? {
        return self._value[name]
    }
    var description: String {
        return self._value.description
    }
    func renderWithOperation(operation: Operation) -> String? {
        return Renderer.renderContext(self, withOperation: operation)
    }
    func renderWithOperations(operations: [Operation]) -> String? {
        return Renderer.renderContext(self, withOperations: operations)
    }
}

// FIXME: (stan@trifia.com) [Swift 2.1 Limitation, rdar://23196859] Constrainted extension can't inherited protocol
//extension Array /*: Contextual*/ where Element:Contextual {
//}
// Workaround for the above limitation…
struct ArrayContext : Contextual, ArrayLiteralConvertible {
    typealias Element = Contextual
    let _value: Array<Element>
    init(_ value: Array<Element>) {
        self._value = value
    }
    init(arrayLiteral elements: Element...) {
        self._value = elements
    }
    func contextForName(name: String) -> Contextual? {
        return nil
    }
    var description: String {
        return self._value.description
    }
    func renderWithOperation(operation: Operation) -> String? {
        return Renderer.renderContexts(self._value, withOperation: operation)
    }
    func renderWithOperations(operations: [Operation]) -> String? {
        return Renderer.renderContexts(self._value, withOperations: operations)
    }
}
