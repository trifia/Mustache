//
//  Stack.swift
//  Mustache
//
//  Created by Stan Chang Khin Boon on 22/12/15.
//  Copyright © 2015 Trifia. All rights reserved.
//

struct Stack<Element> {
    var items = [Element]()
    mutating func push(item: Element) {
        items.append(item)
    }
    mutating func pop() -> Element {
        return items.removeLast()
    }
}

extension Stack {
    var topItem: Element? {
        return items.isEmpty ? nil : items[items.count - 1]
    }
}
