//
//  Parser+Errors.swift
//  
//
//  Created by Narek Sahakyan on 8/21/22.
//

import Foundation

extension Parser {
    enum Errors: Error, LocalizedError {
        case exceededLexemeLength(line: Int, offset: Int)
        case notClosedString(line: Int, offset: Int)
        case notSupportedSymbol(line: Int, offset: Int, symbol: Character)
        case invalidLexeme(line: Int, offset: Int, lexeme: String)
        
        var errorDescription: String? {
            return "\(self)"
        }
    }
}
