//
//  Compiler+Error.swift
//  
//
//  Created by Narek Sahakyan on 8/21/22.
//

import Foundation

extension Compiler {
    enum Error: LocalizedError {
        case programEnd(token: TokenDescription)
        case wrongToken(token: TokenDescription?)
        case redeclaration(id: String)
        case cannotFindInScope(id: String)
        case typeMismatch(real: String, given: String)
        case notSupportedType(id: String)
        case notInitialized(id: String)
        case sourceFileNotProvided
        case sourceFileDoesnNotExist(filename: String)
        case other(error: String)
    }
}
