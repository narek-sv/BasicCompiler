//
//  Parser.swift
//  
//
//  Created by Narek Sahakyan on 2/7/22.
//

import Foundation

final class Parser {
    static let maxLexemeLength = 128

    private let input: String
    private var index: String.Index
    private var line = 1

    init(input: String) {
        self.input = input
        self.index = input.startIndex
    }

    private var currentCharacter: Character? {
        return input.indices.contains(index) ? input[index] : nil
    }
    
    private var offset: Int {
        return input.offset(from: index)
    }

    private func nextIndex() {
        input.formIndex(after: &index)
    }
    
    private func readInteger() throws -> String? {
        var string = String([currentCharacter!])
        nextIndex()
        
        var length = 1
        while let character = currentCharacter, !character.isTerminalSymbol {
            length += 1
            if length > Parser.maxLexemeLength {
                throw Error.exceededLexemeLength(line: line, offset: offset)
            }
            
            string.append(character)
            nextIndex()
        }
        
        return string
    }

    private func readIdentifier() throws -> String? {
        var string = String([currentCharacter!])
        nextIndex()

        var length = 1
        while let character = currentCharacter, !character.isTerminalSymbol {
            length += 1
            if length > Parser.maxLexemeLength {
                throw Error.exceededLexemeLength(line: line, offset: offset)
            }
            
            string.append(character)
            nextIndex()
        }
        
        return string
    }
    
    private func readString() throws -> String? {
        var string = String([currentCharacter!])
        nextIndex()

        var length = 1
        while let character = currentCharacter, !character.isStringQuote, !character.isNewline {
            length += 1
            if length > Parser.maxLexemeLength {
                throw Error.exceededLexemeLength(line: line, offset: offset)
            }
            
            string.append(character)
            nextIndex()
        }
        
        if currentCharacter?.isStringQuote == true {
            string.append(currentCharacter!)
            nextIndex()
            return string
        }
        
        throw Error.notClosedString(line: line, offset: offset)
    }
    
    private func readToken<T: CaseIterableToken>() -> T? {
        var possibleTokens = T.allCases as! [T]
        var possibleToken = ""
        
        for i in 0...T.maxLength {
            guard let currentCharacter = currentCharacter else {
                return T(rawValue: possibleToken)
            }
            
            possibleTokens = T.satisfyingTokens(character: currentCharacter, iteration: i, in: possibleTokens)

            if possibleTokens.isEmpty {
                return T(rawValue: possibleToken)
            }
            
            possibleToken.append(currentCharacter)
            
            if possibleTokens.count == 1, let token = T(rawValue: possibleToken) {
                nextIndex()
                return token
            }
            
            nextIndex()
        }
        
        return nil
    }

    private func nextToken() throws -> TokenDescription? {
        while let currentCharacter = currentCharacter, currentCharacter.isWhitespace {
            if currentCharacter.isNewline {
                line += 1
            }
                
            nextIndex()
        }
        
        guard let currentCharacter = currentCharacter else {
            return nil
        }
        
        if Parenthesis.prefixes.contains(currentCharacter), let token: Parenthesis = readToken() {
            return .init(line: line, offset: offset, token: .parenthesis(token))
        }
        
        if Operator.prefixes.contains(currentCharacter), let token: Operator = readToken() {
            return .init(line: line, offset: offset, token: .operator(token))
        }
        
        if currentCharacter.isStringQuote, let token = try readString() {
            return .init(line: line, offset: offset, token: .literal(.string(token)))
        }
        
        if currentCharacter.isNumber, let token = try readInteger() {
            if let int = Int(token) {
                return .init(line: line, offset: offset, token: .literal(.int(int)))
            }
            
            throw Error.invalidLexeme(lexeme: token, line: line, offset: offset)
        }
        
        if currentCharacter.isLetter, let token = try readIdentifier() {
            if let lexeme = Lexeme(rawValue: token) {
                return .init(line: line, offset: offset, token: .otherLexeme(lexeme))
            }
            
            return .init(line: line, offset: offset, token: .identifier(token))
        }
        
        throw Error.notSupportedSymbol(symbol: currentCharacter, line: line, offset: offset)
    }

    func parse() throws -> [TokenDescription] {
        var tokens = [TokenDescription]()
        
        while let token = try nextToken() {
            tokens.append(token)
        }
        
        return tokens
    }
}

