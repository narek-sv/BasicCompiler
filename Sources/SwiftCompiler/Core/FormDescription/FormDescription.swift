//
//  File.swift
//  
//
//  Created by Narek Sahakyan on 5/2/22.
//

import Foundation

protocol FormDescription {
    func parse(tokens: [TokenExpression]) throws -> FormDescriptorResult
    func evaluate(form: FormDescription, index: Int, usedTokens: [TokenExpression]) throws
}

extension FormDescription {
    func evaluate(form: FormDescription, index: Int, usedTokens: [TokenExpression]) throws { }
}

protocol ComplexFormDescription: FormDescription {
    static var form: [FormDescription] { get }
}

extension ComplexFormDescription {
    func parse(tokens: [TokenExpression]) throws -> FormDescriptorResult {
        var usedTokens = [TokenExpression]()
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

enum FormDescriptorResult: Error {
    case success(used: [TokenExpression], unused: [TokenExpression])
    case failure(error: Compiler.Errors)
}
