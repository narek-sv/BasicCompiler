//
//  EBNFDescription.swift
//  
//
//  Created by Narek Sahakyan on 5/2/22.
//

import Foundation

protocol EBNFDescription {
    func resolve(tokens: [TokenDescription]) throws -> EBNFDescriptionParseResult
}

protocol EBNFSelfContainingDescription: EBNFDescription {
    func generate(description: EBNFDescription, index: Int, usedTokens: [TokenDescription]) throws
    func clearCache()
}

protocol EBNFComplexDescription: EBNFSelfContainingDescription {
    static var description: [EBNFDescription] { get }
}

extension EBNFComplexDescription {
    func resolve(tokens: [TokenDescription]) throws -> EBNFDescriptionParseResult {
        var usedTokens = [TokenDescription]()
        var unusedTokens = tokens
        
        for (index, description) in Self.description.enumerated() {
            let result = try description.resolve(tokens: unusedTokens)
            
            switch result {
            case .failure:
                clearCache()
                return result
            case let .success(used, unused):
                unusedTokens = unused
                usedTokens += used
                
                try generate(description: description, index: index, usedTokens: used)
            }
        }
        
        clearCache()
        return .success(used: usedTokens, unused: unusedTokens)
    }
    
    func generate(description: EBNFDescription, index: Int, usedTokens: [TokenDescription]) throws { }
    func clearCache() { }
}

enum EBNFDescriptionParseResult: Error {
    case success(used: [TokenDescription], unused: [TokenDescription])
    case failure(error: Compiler.Errors)
}
