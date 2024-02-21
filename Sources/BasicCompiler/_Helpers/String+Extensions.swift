//
//  String+Extensions.swift
//  Compiler
//
//  Created by Narek Sahakyan on 2/7/22.
//

import Foundation

extension String {
    subscript(offset: Int) -> Character? {
        if let index = index(startIndex, offsetBy: offset, limitedBy: index(before: endIndex)) {
            return self[index]
        }
        
        return nil
    }
    
    func offset(from index: String.Index) -> Int {
        distance(from: startIndex, to: index)
    }
    
    func removingPrefix(_ prefix: String) -> String {
        guard hasPrefix(prefix) else { return self }
        return String(dropFirst(prefix.count))
    }
    
    func removingSuffix(_ suffix: String) -> String {
        guard hasSuffix(suffix) else { return self }
        return String(dropLast(suffix.count))
    }
}

extension Character {
    var isStringQuote: Bool {
        return self == "\""
    }
    
    var isFloatingPointDot: Bool {
        return self == "."
    }
    
    var isAlphanumeric: Bool {
        return isLetter || isNumber
    }
    
    var isTerminalSymbol: Bool {
        return Operator.prefixes.contains(self) || Parenthesis.prefixes.contains(self) || isWhitespace || isStringQuote
    }
}
