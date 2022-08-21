//
//  EBNFDescription+Custom.swift
//  
//
//  Created by Narek Sahakyan on 5/2/22.
//

import Foundation

final class ProgramFormDescription: EBNFComplexDescription {
    static let form: [EBNFDescription] = [
        ProgramHeaderFormDescription(),
        VariableDefinitionsFormDescription(),
        ConcreteTokenFormDescription(.otherLexem(.begin)),
        StatementSequenceFormDescription(),
        ConcreteTokenFormDescription(.otherLexem(.end)),
        ConcreteTokenFormDescription(.operator(.dot))
    ]
    
    func evaluate(form: EBNFDescription, index: Int, usedTokens: [TokenInfo]) throws {
        if index == 0 {
            Generator.shared.startDataSegment()
        } else if index == 2 {
            Generator.shared.startCodeSegment()
        } else if index == 5 {
            Generator.shared.end()
        }
    }
}

final class ProgramHeaderFormDescription: EBNFComplexDescription {
    static let form: [EBNFDescription] = [
        ConcreteTokenFormDescription(.otherLexem(.program)),
        IdentifierFormDescription(),
        ConcreteTokenFormDescription(.operator(.semicolon))
    ]
    
    func evaluate(form: EBNFDescription, index: Int, usedTokens: [TokenInfo]) throws {
        if index == 1, case let .identifier(id) = usedTokens.first?.token {
            try Generator.shared.setProgramName(id)
        }
    }
}

final class VariableDefinitionsFormDescription: EBNFComplexDescription {
    static let form: [EBNFDescription] = [
        OptionalFormDescription([
            ConcreteTokenFormDescription(.otherLexem(.var)),
            VariableSequenceFormDescription(),
            SequenceFormDescription([
                VariableSequenceFormDescription()
            ])
        ])
    ]
}

final class VariableSequenceFormDescription: EBNFComplexDescription {
    static let form: [EBNFDescription] = [
        IdentifierFormDescription(),
        SequenceFormDescription([
            ConcreteTokenFormDescription(.operator(.comma)),
            IdentifierFormDescription()
        ]),
        ConcreteTokenFormDescription(.operator(.colon)),
        TypeFormDescription(),
        ConcreteTokenFormDescription(.operator(.semicolon))
    ]
    
    private var variableNames = [String]()
    
    func evaluate(form: EBNFDescription, index: Int, usedTokens: [TokenInfo]) throws {
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
            
            variableNames.removeAll()
        }
    }
}

final class StatementSequenceFormDescription: EBNFComplexDescription {
    static let form: [EBNFDescription] = [
        SequenceFormDescription([
            OrFormDescription([
                ComplexAssignmentFormDescription(),
                SimpleAssignmentFormDescription()
            ])
        ])
    ]
}

final class SimpleAssignmentFormDescription: EBNFComplexDescription {
    static let form: [EBNFDescription] = [
        IdentifierFormDescription(),
        ConcreteTokenFormDescription(.operator(.assign)),
        OperandFormDescription(),
        ConcreteTokenFormDescription(.operator(.semicolon))
    ]
    
    private(set) var variableName = ""
    
    func evaluate(form: EBNFDescription, index: Int, usedTokens: [TokenInfo]) throws {
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
}

final class ComplexAssignmentFormDescription: EBNFComplexDescription {
    static let form: [EBNFDescription] = [
        IdentifierFormDescription(),
        ConcreteTokenFormDescription(.operator(.assign)),
        OperandFormDescription(),
        MathOperationFormDescription(),
        OperandFormDescription(),
        ConcreteTokenFormDescription(.operator(.semicolon))
    ]
    
    private(set) var variableName = ""
    private(set) var lhsVar: String?
    private(set) var lhsLit: Literal?
    private(set) var operation: Operator = .plus
    
    func evaluate(form: EBNFDescription, index: Int, usedTokens: [TokenInfo]) throws {
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
            
            lhsVar = nil
            lhsLit = nil
        }
    }
}

final class OperandFormDescription: EBNFComplexDescription {
    static let form: [EBNFDescription] = [
        OrFormDescription([
            IdentifierFormDescription(),
            LiteralFormDescription()
        ])
    ]
}

final class TypeFormDescription: EBNFComplexDescription {
    static let form: [EBNFDescription] = [
        OrFormDescription([
            ConcreteTokenFormDescription(.otherLexem(.integer)),
            ConcreteTokenFormDescription(.otherLexem(.string))
        ])
    ]
    
    func evaluate(form: EBNFDescription, index: Int, usedTokens: [TokenInfo]) throws {
        if let first = usedTokens.first(where: { $0.token != .otherLexem(.integer) }) {
            if case let .otherLexem(id) = first.token {
                throw Compiler.Errors.notSupportedType(id: id.rawValue)
            }
        }
    }
}

final class MathOperationFormDescription: EBNFComplexDescription {
    static let form: [EBNFDescription] = [
        OrFormDescription([
            ConcreteTokenFormDescription(.operator(.plus)),
            ConcreteTokenFormDescription(.operator(.minus))
        ])
    ]
}

