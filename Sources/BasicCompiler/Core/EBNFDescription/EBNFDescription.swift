//
//  EBNFDescription.swift
//  
//
//  Created by Narek Sahakyan on 5/2/22.
//

import Foundation

protocol EBNFDescription {
    func parse(tokens: [TokenInfo]) throws -> EBNFDescriptionParseResult
    func evaluate(form: EBNFDescription, index: Int, usedTokens: [TokenInfo]) throws
}

extension EBNFDescription {
    func evaluate(form: EBNFDescription, index: Int, usedTokens: [TokenInfo]) throws { }
}

protocol EBNFComplexDescription: EBNFDescription {
    static var form: [EBNFDescription] { get }
}

extension EBNFComplexDescription {
    func parse(tokens: [TokenInfo]) throws -> EBNFDescriptionParseResult {
        var usedTokens = [TokenInfo]()
        var unusedTokens = tokens
        
        for (index, descriptor) in Self.form.enumerated() {
            let result = try descriptor.parse(tokens: unusedTokens)
            
            switch result {
            case .failure:
                return result
            case let .success(used, unused):
                unusedTokens = unused
                usedTokens += used
                
                try evaluate(form: descriptor, index: index, usedTokens: used)
            }
        }
        
        return .success(used: usedTokens, unused: unusedTokens)
    }
}

enum EBNFDescriptionParseResult: Error {
    case success(used: [TokenInfo], unused: [TokenInfo])
    case failure(error: Compiler.Errors)
}
