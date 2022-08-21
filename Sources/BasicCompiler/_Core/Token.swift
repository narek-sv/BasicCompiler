//
//  Tokens.swift
//  
//
//  Created by Narek Sahakyan on 2/7/22.
//

import Foundation

protocol TokenParticle {
    static var maxLength: Int { get }
    static var prefixes: [Character] { get }
    static func satisfyingTokens(character: Character, iteration: Int, in tokens: [Self]) -> [Self]
}

protocol CaseIterableToken: TokenParticle where Self: CaseIterable & RawRepresentable, RawValue == String { }
extension TokenParticle where Self: CaseIterable & RawRepresentable, RawValue == String {
    static var maxLength: Int {
        return allCases.reduce(1, { max($0, $1.rawValue.count) })
    }
    
    static var prefixes: [Character] {
        return Array(Set(allCases.map { $0.rawValue.first! }))
    }
    
    static func satisfyingTokens(character: Character, iteration: Int, in tokens: [Self]) -> [Self] {
        return tokens.filter { $0.rawValue[iteration] == character }
    }
}

protocol PrettyPrintable: CustomStringConvertible { }
extension PrettyPrintable where Self: RawRepresentable {
    var description: String {
        return "\(rawValue)"
    }
}

enum Operator: String, CaseIterableToken, PrettyPrintable {
    case plus = "+"
    case minus = "-"
    case multiply = "*"
    case divide = "/"
    case mod = "%"
    case equals = "="
    case and = "&"
    case or = "|"
    case hashtag = "#"
    case greaterThan = ">"
    case equalsOrGreaterThan = ">="
    case lessThan = "<"
    case equalsOrLessThan = "<="
    case assign = ":="
    case comma = ","
    case dot = "."
    case colon = ":"
    case semicolon = ";"
}

enum Parenthesis: String, CaseIterableToken, PrettyPrintable {
    case openRound = "("
    case closeRound = ")"
    case openSquare = "["
    case closeSquare = "]"
    case openCurly = "{"
    case closeCurly = "}"
}

enum Literal: PrettyPrintable {
    case int(Int)
    case string(String)
    
    var description: String {
        switch self {
        case .int(let int):         return "int(\(int))"
        case .string(let string):   return "string(\(string))"
        }
    }
    
    var typeName: Lexem {
        switch self {
        case .int:      return .integer
        case .string:   return .string
        }
    }
    
    var value: Any {
        switch self {
        case .int(let int):         return int
        case .string(let string):   return string
        }
    }
}

enum Lexem: String, CaseIterableToken, PrettyPrintable {
    case or
    case and
    case div
    case mod
    case char
    case integer
    case string
    case boolean
    case not
    case until
    case loop
    case program
    case begin
    case end
    case elsif
    case procedure
    case const
    case type
    case module
    case `false`
    case `true`
    case `while`
    case `repeat`
    case `do`
    case `if`
    case `for`
    case `else`
    case `var`
    case `import`
}

struct TokenDescription {
    let line: Int
    let offset: Int
    let token: Token
}

enum Token: CustomStringConvertible, Equatable {
    case identifier(String)
    case otherLexem(Lexem)
    case parenthesis(Parenthesis)
    case literal(Literal)
    case `operator`(Operator)
    
    var description: String {
        switch self {
        case .identifier(let string):       return "identifier(" + string + ")"
        case .otherLexem(let lexem):        return "lexem(\(lexem))"
        case .parenthesis(let parenthesis): return "parenthesis(\(parenthesis))"
        case .literal(let literal):         return "literal(\(literal))"
        case .operator(let `operator`):     return "operator(\(`operator`))"
        }
    }
    
    static func == (lhs: Token, rhs: Token) -> Bool {
        return lhs.description == rhs.description
    }
}
