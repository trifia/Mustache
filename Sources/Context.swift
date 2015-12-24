//
// Context.swift
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
