//
//  EBNFDescription+Custom.swift
//  
//
//  Created by Narek Sahakyan on 5/2/22.
//

import Foundation

final class EBNFProgramDescription: EBNFComplexDescription {
    static let description: [EBNFDescription] = [
        EBNFProgramHeaderDescription(),
        EBNFVariableDefinitionsDescription(),
        EBNFConcreteTokenDescription(.otherLexem(.begin)),
        EBNFStatementSequenceDescription(),
        EBNFConcreteTokenDescription(.otherLexem(.end)),
        EBNFConcreteTokenDescription(.operator(.dot))
    ]
    
    func generate(description: EBNFDescription, index: Int, usedTokens: [TokenDescription]) throws {
        if index == 0 {
            Generator.shared.startDataSegment()
        } else if index == 2 {
            Generator.shared.startCodeSegment()
        } else if index == 5 {
            Generator.shared.end()
        }
    }
}

final class EBNFProgramHeaderDescription: EBNFComplexDescription {
    static let description: [EBNFDescription] = [
        EBNFConcreteTokenDescription(.otherLexem(.program)),
        EBNFIdentifierDescription(),
        EBNFConcreteTokenDescription(.operator(.semicolon))
    ]
    
    func generate(description: EBNFDescription, index: Int, usedTokens: [TokenDescription]) throws {
        if index == 1, case let .identifier(id) = usedTokens.first?.token {
            try Generator.shared.setProgramName(id)
        }
    }
}

final class EBNFVariableDefinitionsDescription: EBNFComplexDescription {
    static let description: [EBNFDescription] = [
        EBNFOptionalDescription([
            EBNFConcreteTokenDescription(.otherLexem(.var)),
            EBNFVariableSequenceDescription(),
            EBNFSequenceDescription([
                EBNFVariableSequenceDescription()
            ])
        ])
    ]
}

final class EBNFVariableSequenceDescription: EBNFComplexDescription {
    private var variableNames = [String]()

    static let description: [EBNFDescription] = [
        EBNFIdentifierDescription(),
        EBNFSequenceDescription([
            EBNFConcreteTokenDescription(.operator(.comma)),
            EBNFIdentifierDescription()
        ]),
        EBNFConcreteTokenDescription(.operator(.colon)),
        EBNFTypeDescription(),
        EBNFConcreteTokenDescription(.operator(.semicolon))
    ]    
    
    func generate(description: EBNFDescription, index: Int, usedTokens: [TokenDescription]) throws {
        if index == 0, case let .identifier(id) = usedTokens.first?.token {
            variableNames.append(id)
        } else if index == 1 {
            for (index, element) in usedTokens.enumerated() where index % 2 == 1 {
                if case let .identifier(id) = element.token {
                    variableNames.append(id)
                }
            }
        } else if index == 3, case let .otherLexem(type) = usedTokens.first?.token {
            try variableNames.forEach {
                try Generator.shared.declareVariable(name: $0, type: type.rawValue)
            }
        }
    }
    
    func clearCache() {
        variableNames.removeAll()
    }
}

final class EBNFStatementSequenceDescription: EBNFComplexDescription {
    static let description: [EBNFDescription] = [
        EBNFSequenceDescription([
            EBNFOrDescription([
                EBNFComplexAssignmentDescription(),
                EBNFSimpleAssignmentDescription()
            ])
        ])
    ]
}

final class EBNFSimpleAssignmentDescription: EBNFComplexDescription {
    private(set) var variableName = ""

    static let description: [EBNFDescription] = [
        EBNFIdentifierDescription(),
        EBNFConcreteTokenDescription(.operator(.assign)),
        EBNFOperandDescription(),
        EBNFConcreteTokenDescription(.operator(.semicolon))
    ]
    
    func generate(description: EBNFDescription, index: Int, usedTokens: [TokenDescription]) throws {
        if index == 0, case let .identifier(id) = usedTokens.first?.token {
            variableName = id
        } else if index == 2 {
            if case let .identifier(id) = usedTokens.first?.token {
                try Generator.shared.doSimpleAssignment(variable: variableName, value: id)
            } else if case let .literal(literal) = usedTokens.first?.token {
                try Generator.shared.doSimpleAssignment(variable: variableName, literal: literal)
            }
        }
    }
    
    func clearCache() {
        variableName = ""
    }
}

final class EBNFComplexAssignmentDescription: EBNFComplexDescription {
    private(set) var variableName = ""
    private(set) var lhsVar: String?
    private(set) var lhsLit: Literal?
    private(set) var operation: Operator = .plus
    
    static let description: [EBNFDescription] = [
        EBNFIdentifierDescription(),
        EBNFConcreteTokenDescription(.operator(.assign)),
        EBNFOperandDescription(),
        EBNFMathOperationDescription(),
        EBNFOperandDescription(),
        EBNFConcreteTokenDescription(.operator(.semicolon))
    ]
        
    func generate(description: EBNFDescription, index: Int, usedTokens: [TokenDescription]) throws {
        if index == 0, case let .identifier(id) = usedTokens.first?.token {
            variableName = id
        } else if index == 2 {
            if case let .identifier(id) = usedTokens.first?.token {
                lhsVar = id
            } else if case let .literal(literal) = usedTokens.first?.token {
                lhsLit = literal
            }
        } else if index == 3, case let .operator(mathOperation) = usedTokens.first?.token {
            operation = mathOperation
        } else if index == 4 {
            if case let .identifier(id) = usedTokens.first?.token {
                if let lhsVar = lhsVar {
                    try Generator.shared.doComplexAssignment(variable: variableName, lhs: lhsVar, rhs: id, operation: operation)
                } else if let lhsLit = lhsLit {
                    try Generator.shared.doComplexAssignment(variable: variableName, lhs: lhsLit, rhs: id, operation: operation)
                }
            } else if case let .literal(lit) = usedTokens.first?.token {
                if let lhsVar = lhsVar {
                    try Generator.shared.doComplexAssignment(variable: variableName, lhs: lhsVar, rhs: lit, operation: operation)
                } else if let lhsLit = lhsLit {
                    try Generator.shared.doComplexAssignment(variable: variableName, lhs: lhsLit, rhs: lit, operation: operation)
                }
            }
        }
    }
    
    func clearCache() {
        variableName = ""
        lhsVar = nil
        lhsLit = nil
        operation = .plus
    }
}

final class EBNFOperandDescription: EBNFComplexDescription {
    static let description: [EBNFDescription] = [
        EBNFOrDescription([
            EBNFIdentifierDescription(),
            EBNFLiteralDescription()
        ])
    ]
}

final class EBNFTypeDescription: EBNFComplexDescription {
    static let description: [EBNFDescription] = [
        EBNFOrDescription([
            EBNFConcreteTokenDescription(.otherLexem(.integer)),
            EBNFConcreteTokenDescription(.otherLexem(.string))
        ])
    ]
    
    func generate(description: EBNFDescription, index: Int, usedTokens: [TokenDescription]) throws {
        if let first = usedTokens.first(where: { $0.token != .otherLexem(.integer) }) {
            if case let .otherLexem(id) = first.token {
                throw Compiler.Errors.notSupportedType(id: id.rawValue)
            }
        }
    }
}

final class EBNFMathOperationDescription: EBNFComplexDescription {
    static let description: [EBNFDescription] = [
        EBNFOrDescription([
            EBNFConcreteTokenDescription(.operator(.plus)),
            EBNFConcreteTokenDescription(.operator(.minus))
        ])
    ]
}
