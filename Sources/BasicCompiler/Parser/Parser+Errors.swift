//
//  Parser+Errors.swift
//  
//
//  Created by Narek Sahakyan on 8/21/22.
//

import Foundation

extension Parser {
    enum Errors: Error, LocalizedError {
        case exceededLexemLength(line: Int, offset: Int)
        case notClosedString(line: Int, offset: Int)
        case notSupportedSymbol(line: Int, offset: Int, symbol: Character)
        case invalidLexem(line: Int, offset: Int, lexem: String)
        
        var errorDescription: String? {
            return "\(self)"
        }
    }
}
