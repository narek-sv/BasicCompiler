//
//  File.swift
//  
//
//  Created by Narek Sahakyan on 5/2/22.
//

import Foundation

extension ProgramFormDescription: ComplexFormDescription {
    static let form: [FormDescription] = [
        ProgramHeaderFormDescription(),
        VariableDefinitionsFormDescription(),
        ConcreteTokenFormDescription(.otherLexem(.begin)),
        StatementSequenceFormDescription(),
        ConcreteTokenFormDescription(.otherLexem(.end)),
        ConcreteTokenFormDescription(.operator(.dot))
    ]
}

extension ProgramHeaderFormDescription: ComplexFormDescription {
    static let form: [FormDescription] = [
        ConcreteTokenFormDescription(.otherLexem(.program)),
        IdentifierFormDescription(),
        ConcreteTokenFormDescription(.operator(.semicolon))
    ]
}

extension VariableDefinitionsFormDescription: ComplexFormDescription {
    static let form: [FormDescription] = [
        OptionalFormDescription([
            ConcreteTokenFormDescription(.otherLexem(.var)),
            VariableSequenceFormDescription(),
            SequenceFormDescription([
                VariableSequenceFormDescription()
            ])
        ])
    ]
}

extension VariableSequenceFormDescription: ComplexFormDescription {
    static let form: [FormDescription] = [
        IdentifierFormDescription(),
        SequenceFormDescription([
            ConcreteTokenFormDescription(.operator(.comma)),
            IdentifierFormDescription()
        ]),
        ConcreteTokenFormDescription(.operator(.colon)),
        TypeFormDescription(),
        ConcreteTokenFormDescription(.operator(.semicolon))
    ]
}

extension StatementSequenceFormDescription: ComplexFormDescription {
    static let form: [FormDescription] = [
        SequenceFormDescription([
            OrFormDescription([
                ComplexAssignmentFormDescription(),
                SimpleAssignmentFormDescription()
            ])
        ])
    ]
}

extension SimpleAssignmentFormDescription: ComplexFormDescription {
    static let form: [FormDescription] = [
        IdentifierFormDescription(),
        ConcreteTokenFormDescription(.operator(.assign)),
        OperandFormDescription(),
        ConcreteTokenFormDescription(.operator(.semicolon))
    ]
}

extension ComplexAssignmentFormDescription: ComplexFormDescription {
    static let form: [FormDescription] = [
        IdentifierFormDescription(),
        ConcreteTokenFormDescription(.operator(.assign)),
        OperandFormDescription(),
        MathOperationFormDescription(),
        OperandFormDescription(),
        ConcreteTokenFormDescription(.operator(.semicolon))
    ]
}

extension OperandFormDescription: ComplexFormDescription {
    static let form: [FormDescription] = [
        OrFormDescription([
            IdentifierFormDescription(),
            LiteralFormDescription()
        ])
    ]
}

extension TypeFormDescription: ComplexFormDescription {
    static let form: [FormDescription] = [
        OrFormDescription([
            ConcreteTokenFormDescription(.otherLexem(.integer)),
            ConcreteTokenFormDescription(.otherLexem(.string))
        ])
    ]
}

extension MathOperationFormDescription: ComplexFormDescription {
    static let form: [FormDescription] = [
        OrFormDescription([
            ConcreteTokenFormDescription(.operator(.plus)),
            ConcreteTokenFormDescription(.operator(.minus))
        ])
    ]
}

final class Compiler: ComplexFormDescription {
    static var form: [FormDescription] { [ProgramFormDescription()] }
    let parser: Parser
    
    init(parser: Parser) {
        self.parser = parser
    }
    
    func compile() throws {
        let result = try parse(tokens: try parser.parse())
        
        switch result {
        case let .success(used: _, unused: unused) where unused.isEmpty:
            return
        case let .success(used: _, unused: unused):
            throw Compiler.Errors.programEnd(token: unused[0])
        case let .failure(error: error):
            throw error
        }
    }
}

extension Compiler {
    enum Errors: Error, LocalizedError {
        case programEnd(token: TokenExpression)
        case wrongToken(token: TokenExpression?)
        case redeclaration(id: String)
        case cannotFindInScope(id: String)
        case typeMismatch(real: String, given: String)
        case notSupportedType(id: String)
        case notInitialized(id: String)
        case sourceFileNotProvided
        case sourceFileDoesnNotExist(filename: String)

        var errorDescription: String? {
            switch self {
            case let .programEnd(token: token):
                return "Expected to end the program at line: \(token.line), offset: \(token.offset), but found: \(token.token) instead"
            case let .wrongToken(token: token):
                if let token = token {
                    return "Unexpected token at line: \(token.line), offset: \(token.offset)"
                } else {
                    return "Unexpected end of file"
                }
            case .redeclaration(id: let id):
                return "Invalid redeclaration of '\(id)'"
            case .cannotFindInScope(id: let id):
                return "Cannot find '\(id)' in scope"
            case .typeMismatch(real: let real, given: let given):
                return "Cannot assign value of type '\(real)' to type '\(given)'"
            case .notSupportedType(let id):
                return "'\(id)' type currently is not supported"
            case .notInitialized(let id):
                return "Variable '\(id)' used before being initialized"
            case .sourceFileNotProvided:
                return "Please provide the source file path"
            case .sourceFileDoesnNotExist(let filename):
                return "Provided source file (\(filename)) does not exist"
            }
        }
    }
}
