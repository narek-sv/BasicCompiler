//
//  EBNFDescription.swift
//  
//
//  Created by Narek Sahakyan on 5/2/22.
//

import Foundation

protocol EBNFDescription {
    func parse(tokens: [TokenDescription]) throws -> EBNFDescriptionParseResult
    func generate(description: EBNFDescription, index: Int, usedTokens: [TokenDescription]) throws
}

extension EBNFDescription {
    func generate(description: EBNFDescription, index: Int, usedTokens: [TokenDescription]) throws { }
}

protocol EBNFComplexDescription: EBNFDescription {
    static var description: [EBNFDescription] { get }
}

extension EBNFComplexDescription {
    func parse(tokens: [TokenDescription]) throws -> EBNFDescriptionParseResult {
        var usedTokens = [TokenDescription]()
        var unusedTokens = tokens
        
        for (index, description) in Self.description.enumerated() {
            let result = try description.parse(tokens: unusedTokens)
            
            switch result {
            case .failure:
                return result
            case let .success(used, unused):
                unusedTokens = unused
                usedTokens += used
                
                try generate(description: description, index: index, usedTokens: used)
            }
        }
        
        return .success(used: usedTokens, unused: unusedTokens)
    }
}

enum EBNFDescriptionParseResult: Error {
    case success(used: [TokenDescription], unused: [TokenDescription])
    case failure(error: Compiler.Errors)
}
