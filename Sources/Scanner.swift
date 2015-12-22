//
//  Scanner.swift
//  Mustache
//
//  Created by Stan Chang Khin Boon on 21/12/15.
//  Copyright © 2015 Trifia. All rights reserved.
//

import Foundation

struct ScanResult {
    /// The characters being scanned.
    let characters: String.CharacterView
    
    let before: Range<String.CharacterView.Index>
    let match: Range<String.CharacterView.Index>?
    private(set) var consumed: Bool
    
    var beforeCharacters: String.CharacterView? {
        let before = self.before
        if !before.isEmpty {
            return self.characters[before]
        } else {
            return nil
        }
    }
    
    var matchCharacters: String.CharacterView? {
        if let match = self.match {
            return self.characters[match]
        } else {
            return nil
        }
    }
    
    var visited: Range<String.CharacterView.Index> {
        return before.startIndex..<(self.match?.endIndex ?? before.endIndex)
    }
    
    func hasMatch() -> Bool {
        return self.match != nil
    }
    
    init(characters: String.CharacterView, before: Range<String.CharacterView.Index>, match: Range<String.CharacterView.Index>?, consumed: Bool) {
        self.characters = characters
        self.before = before
        self.match = match
        self.consumed = consumed
    }
}

/// `Scanner` provides for lexical scanning operations on characters (`String.CharacterView`).
struct Scanner {
    /// The characters to scan.
    let characters: String.CharacterView
    
    /// The scan position that marks the end.
    let endIndex: String.CharacterView.Index
    
    /// The current scan position.
    var index: String.CharacterView.Index
    
    init(characters: String.CharacterView, range: Range<String.CharacterView.Index>) {
        assert(range.endIndex <= characters.endIndex)
        self.characters = characters
        self.index = range.startIndex
        self.endIndex = range.endIndex
    }
    
    init(string: String) {
        let characters = string.characters
        let range = characters.startIndex..<characters.endIndex
        self.init(characters: string.characters, range: range)
    }
    
    subscript(range: Range<String.CharacterView.Index>) -> String.CharacterView {
        return self.characters[range]
    }
    
    func peek(distance: String.CharacterView.Index.Distance = 1) -> ScanResult {
        let endIndex = self.index.advancedBy(distance, limit: self.endIndex)
        if self.index.distanceTo(endIndex) == distance {
            return ScanResult(characters: self.characters, before: self.index..<self.index, match: self.index..<endIndex, consumed: false)
        } else {
            return ScanResult(characters: self.characters, before: self.index..<self.index, match: nil, consumed: false)
        }
    }
    
    /// Returns `true` if scan position has not reach the end.
    func hasNext() -> Bool {
        return self.index < self.endIndex
    }
    
    /// Tries to match with `characters` at current position.
    /// If there's a match, the scanner advances the `index` and returns the matched range.
    /// Otherwise, the scanner return `nil`.
    mutating func scan(characters: String.CharacterView) -> ScanResult {
        var consumed = false
        let charactersCount = characters.count
        let startIndex = self.index
        let endIndex = startIndex.advancedBy(charactersCount, limit: self.endIndex)
        let before = startIndex..<startIndex
        guard startIndex.distanceTo(endIndex) == charactersCount else {
            return ScanResult(characters: self.characters, before: before, match: nil, consumed: consumed)
        }
        let range = startIndex..<endIndex
        guard characters.elementsEqual(self.characters[range]) else {
            return ScanResult(characters: self.characters, before: before, match: nil, consumed: consumed)
        }
        self.index = endIndex
        consumed = true
        return ScanResult(characters: self.characters, before: startIndex..<startIndex, match: range, consumed: consumed)
    }
    
    /// Scans the string _until_ the `characters` is matched.
    /// If there's a match, returns the range up to the beginning of the match (`before`) and the matched range (`match`), advancing the `index` to the end of the match.
    /// Otherwise, returns the range up to the end index (`before`) and `nil` (`match`).
    mutating func scanUntil(characters: String.CharacterView) -> ScanResult {
        var consumed = false
        let charactersCount = characters.count
        var index = self.index
        while index < self.endIndex {
            let startIndex = index
            let endIndex = startIndex.advancedBy(charactersCount, limit: self.endIndex)
            guard startIndex.distanceTo(endIndex) == charactersCount else {
                let before = self.index..<endIndex
                return ScanResult(characters: self.characters, before: before, match: nil, consumed: consumed)
            }
            let range = startIndex..<endIndex
            guard characters.elementsEqual(self.characters[range]) else {
                index = index.successor()
                continue
            }
            let before = self.index..<range.startIndex
            self.index = range.endIndex
            consumed = true
            return ScanResult(characters: self.characters, before: before, match: range, consumed: consumed)
        }
        let before = self.index..<self.endIndex
        return ScanResult(characters: self.characters, before: before, match: nil, consumed: consumed)
    }
    
    mutating func skip(inout scanResult: ScanResult) {
        assert(scanResult.consumed == false)
        let visited = scanResult.visited
        assert(visited.startIndex == self.index)
        assert(visited.endIndex <= self.endIndex)
        self.index = visited.endIndex
        scanResult.consumed = true
    }
}
