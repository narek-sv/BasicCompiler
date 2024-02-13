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
        return distance(from: startIndex, to: index)
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
