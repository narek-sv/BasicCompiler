//
//  Compiler.swift
//  
//
//  Created by Narek Sahakyan on 5/2/22.
//

import Foundation

final class Compiler {
    let parser: Parser
    
    init(parser: Parser) {
        self.parser = parser
    }
    
    func compile() throws {
        let description = EBNFProgramDescription()
        let result = try description.resolve(tokens: try parser.parse())
        
        switch result {
        case let .success(used: _, unused: unused) where unused.isEmpty:
            break
        case let .success(used: _, unused: unused):
            throw Compiler.Error.programEnd(token: unused[0])
        case let .failure(error: error):
            throw error
        }
    }
}
