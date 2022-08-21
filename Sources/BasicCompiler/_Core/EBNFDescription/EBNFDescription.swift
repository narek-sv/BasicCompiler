//
//  EBNFDescription.swift
//  
//
//  Created by Narek Sahakyan on 5/2/22.
//

import Foundation

protocol EBNFDescription: AnyObject {    
    func resolve(tokens: [TokenDescription]) throws -> EBNFDescriptionParseResult
    func clearCache()
}

extension EBNFDescription {
    func inject(_ handler: @escaping ([TokenDescription]) throws -> ()) -> Self {
        EnvironmentVariables.shared.setHandler(handler, for: self)
        return self
    }
    
    var handler: (([TokenDescription]) throws -> ())? {
        EnvironmentVariables.shared.getHandler(for: self)
    }
    
    func clearCache() { }
}

protocol EBNFComplexDescription: EBNFDescription {
    var descriptions: [EBNFDescription] { get }
}

extension EBNFComplexDescription {
    func resolve(tokens: [TokenDescription]) throws -> EBNFDescriptionParseResult {
        var usedTokens = [TokenDescription]()
        var unusedTokens = tokens
        
        for description in descriptions {
            let result = try description.resolve(tokens: unusedTokens)
            
            switch result {
            case .failure:
                description.clearCache()
                clearCache()
                return result
            case let .success(used, unused):
                unusedTokens = unused
                usedTokens += used
            }
        }
        
        try handler?(usedTokens)
        self.clearCache()
        return .success(used: usedTokens, unused: unusedTokens)
    }
}

enum EBNFDescriptionParseResult: Error {
    case success(used: [TokenDescription], unused: [TokenDescription])
    case failure(error: Compiler.Errors)
}
