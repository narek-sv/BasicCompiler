//
//  EBNFDescription.swift
//  
//
//  Created by Narek Sahakyan on 5/2/22.
//

import Foundation

final class EBNFIdentifierDescription: EBNFDescription {
    func parse(tokens: [TokenDescription]) throws -> EBNFDescriptionParseResult {
        if let firstToken = tokens.first, case .identifier = firstToken.token {
            try generate(description: self, index: 0, usedTokens: [firstToken])
            return .success(used: [firstToken], unused: Array(tokens.dropFirst()))
        }
        
        return .failure(error: .wrongToken(token: tokens.first))
    }
}

final class EBNFLiteralDescription: EBNFDescription {
    func parse(tokens: [TokenDescription]) throws -> EBNFDescriptionParseResult {
        if let firstToken = tokens.first, case .literal = firstToken.token {
            try generate(description: self, index: 0, usedTokens: [firstToken])
            return .success(used: [firstToken], unused: Array(tokens.dropFirst()))
        }
        
        return .failure(error: .wrongToken(token: tokens.first))
    }
}

final class EBNFConcreteTokenDescription: EBNFDescription {
    let token: Token
    
    init(_ token: Token) {
        self.token = token
    }
    
    func parse(tokens: [TokenDescription]) throws -> EBNFDescriptionParseResult {
        if let firstToken = tokens.first, token == firstToken.token {
            try generate(description: self, index: 0, usedTokens: [firstToken])
            return .success(used: [firstToken], unused: Array(tokens.dropFirst()))
        }
        
        return .failure(error: .wrongToken(token: tokens.first))
    }
}

final class EBNFOrDescription: EBNFDescription {
    let descriptors: [EBNFDescription]
    
    init(_ descriptors: [EBNFDescription]) {
        self.descriptors = descriptors
    }
    
    func parse(tokens: [TokenDescription]) throws -> EBNFDescriptionParseResult {
        for descriptor in descriptors {
            let result = try descriptor.parse(tokens: tokens)
            
            switch result {
            case let .success(used, _):
                try generate(description: self, index: 0, usedTokens: used)
                return result
            default:
                continue
            }
        }
        
        return .failure(error: Compiler.Errors.wrongToken(token: tokens.first))
    }
}

final class EBNFOptionalDescription: EBNFDescription {
    let descriptors: [EBNFDescription]
    
    init(_ descriptors: [EBNFDescription]) {
        self.descriptors = descriptors
    }
    
    func parse(tokens: [TokenDescription]) throws -> EBNFDescriptionParseResult {
        var usedTokens = [TokenDescription]()
        var unusedTokens = tokens
        
        for descriptor in descriptors {
            let result = try descriptor.parse(tokens: unusedTokens)
            
            switch result {
            case let .success(used, unused):
                usedTokens += used
                unusedTokens = unused
            case .failure:
                try generate(description: self, index: 0, usedTokens: [])
                return .success(used: [], unused: tokens)
            }
        }
        
        try generate(description: self, index: 0, usedTokens: usedTokens)
        return .success(used: usedTokens, unused: unusedTokens)
    }
}

final class EBNFSequenceDescription: EBNFDescription {
    let descriptors: [EBNFDescription]
    
    init(_ descriptors: [EBNFDescription]) {
        self.descriptors = descriptors
    }
    
    func parse(tokens: [TokenDescription]) throws -> EBNFDescriptionParseResult {
        var usedTokens = [TokenDescription]()
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
                    try generate(description: self, index: 0, usedTokens: lastOccurenceUsedTokens)
                    return .success(used: lastOccurenceUsedTokens, unused: lastOccurenceUnusedTokens)
                }
            }
            
            lastOccurenceUsedTokens = usedTokens
            lastOccurenceUnusedTokens = unusedTokens
        }
    }
}
