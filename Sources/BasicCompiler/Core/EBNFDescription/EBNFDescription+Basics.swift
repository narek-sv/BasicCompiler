//
//  EBNFDescription+Basics.swift
//  
//
//  Created by Narek Sahakyan on 5/2/22.
//

import Foundation

final class IdentifierFormDescription: EBNFDescription {
    func parse(tokens: [TokenInfo]) throws -> EBNFDescriptionParseResult {
        if let firstToken = tokens.first, case .identifier = firstToken.token {
            try evaluate(form: self, index: 0, usedTokens: [firstToken])
            return .success(used: [firstToken], unused: Array(tokens.dropFirst()))
        }
        
        return .failure(error: .wrongToken(token: tokens.first))
    }
}

final class LiteralFormDescription: EBNFDescription {
    func parse(tokens: [TokenInfo]) throws -> EBNFDescriptionParseResult {
        if let firstToken = tokens.first, case .literal = firstToken.token {
            try evaluate(form: self, index: 0, usedTokens: [firstToken])
            return .success(used: [firstToken], unused: Array(tokens.dropFirst()))
        }
        
        return .failure(error: .wrongToken(token: tokens.first))
    }
}

final class ConcreteTokenFormDescription: EBNFDescription {
    let token: Token
    
    init(_ token: Token) {
        self.token = token
    }
    
    func parse(tokens: [TokenInfo]) throws -> EBNFDescriptionParseResult {
        if let firstToken = tokens.first, token == firstToken.token {
            try evaluate(form: self, index: 0, usedTokens: [firstToken])
            return .success(used: [firstToken], unused: Array(tokens.dropFirst()))
        }
        
        return .failure(error: .wrongToken(token: tokens.first))
    }
}

final class OrFormDescription: EBNFDescription {
    let descriptors: [EBNFDescription]
    
    init(_ descriptors: [EBNFDescription]) {
        self.descriptors = descriptors
    }
    
    func parse(tokens: [TokenInfo]) throws -> EBNFDescriptionParseResult {
        for descriptor in descriptors {
            let result = try descriptor.parse(tokens: tokens)
            
            switch result {
            case let .success(used, _):
                try evaluate(form: self, index: 0, usedTokens: used)
                return result
            default:
                continue
            }
        }
        
        return .failure(error: Compiler.Errors.wrongToken(token: tokens.first))
    }
}

final class OptionalFormDescription: EBNFDescription {
    let descriptors: [EBNFDescription]
    
    init(_ descriptors: [EBNFDescription]) {
        self.descriptors = descriptors
    }
    
    func parse(tokens: [TokenInfo]) throws -> EBNFDescriptionParseResult {
        var usedTokens = [TokenInfo]()
        var unusedTokens = tokens
        
        for descriptor in descriptors {
            let result = try descriptor.parse(tokens: unusedTokens)
            
            switch result {
            case let .success(used, unused):
                usedTokens += used
                unusedTokens = unused
            case .failure:
                try evaluate(form: self, index: 0, usedTokens: [])
                return .success(used: [], unused: tokens)
            }
        }
        
        try evaluate(form: self, index: 0, usedTokens: usedTokens)
        return .success(used: usedTokens, unused: unusedTokens)
    }
}

final class SequenceFormDescription: EBNFDescription {
    let descriptors: [EBNFDescription]
    
    init(_ descriptors: [EBNFDescription]) {
        self.descriptors = descriptors
    }
    
    func parse(tokens: [TokenInfo]) throws -> EBNFDescriptionParseResult {
        var usedTokens = [TokenInfo]()
        var unusedTokens = tokens
        var lastOccurenceUsedTokens = usedTokens
        var lastOccurenceUnusedTokens = unusedTokens
        
        while true {
            for descriptor in descriptors {
                let result = try descriptor.parse(tokens: unusedTokens)

                switch result {
                case let .success(used, unused):
                    usedTokens += used
                    unusedTokens = unused
                case .failure:
                    try evaluate(form: self, index: 0, usedTokens: lastOccurenceUsedTokens)
                    return .success(used: lastOccurenceUsedTokens, unused: lastOccurenceUnusedTokens)
                }
            }
            
            lastOccurenceUsedTokens = usedTokens
            lastOccurenceUnusedTokens = unusedTokens
        }
    }
}
