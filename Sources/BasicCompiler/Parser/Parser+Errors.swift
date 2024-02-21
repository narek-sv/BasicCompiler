//
//  Parser+Errors.swift
//  
//
//  Created by Narek Sahakyan on 8/21/22.
//

import Foundation

extension Parser {
    enum Error: LocalizedError {
        case exceededLexemeLength(line: Int, offset: Int)
        case notClosedString(line: Int, offset: Int)
        case notSupportedSymbol(symbol: Character, line: Int, offset: Int)
        case invalidLexeme(lexeme: String, line: Int, offset: Int)
    }
}
