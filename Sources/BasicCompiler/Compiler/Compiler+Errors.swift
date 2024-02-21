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

//        var errorDescription: String? {
//            switch self {
//            case let .programEnd(token: token):
//                return "Expected to end the program at line: \(token.line), offset: \(token.offset), but found: \(token.token) instead"
//            case let .wrongToken(token: token):
//                if let token = token {
//                    return "Unexpected token at line: \(token.line), offset: \(token.offset)"
//                } else {
//                    return "Unexpected end of file"
//                }
//            case .redeclaration(id: let id):
//                return "Invalid redeclaration of '\(id)'"
//            case .cannotFindInScope(id: let id):
//                return "Cannot find '\(id)' in scope"
//            case .typeMismatch(real: let real, given: let given):
//                return "Cannot assign value of type '\(real)' to type '\(given)'"
//            case .notSupportedType(let id):
//                return "'\(id)' type currently is not supported"
//            case .notInitialized(let id):
//                return "Variable '\(id)' used before being initialized"
//            case .sourceFileNotProvided:
//                return "Please provide the source file path"
//            case .sourceFileDoesnNotExist(let filename):
//                return
//            }
//        }
    }
}
