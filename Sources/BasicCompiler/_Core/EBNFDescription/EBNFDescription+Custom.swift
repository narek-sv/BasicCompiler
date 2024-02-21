//
//  EBNFDescription+Custom.swift
//  
//
//  Created by Narek Sahakyan on 5/2/22.
//

import Foundation

final class EBNFProgramDescription: EBNFComplexDescription {
    lazy var descriptions: [EBNFDescription] = [
        EBNFProgramHeaderDescription().inject(resolveDataSegment),
        EBNFVariableDefinitionsDescription(),
        EBNFConcreteTokenDescription(.otherLexeme(.begin)).inject(resolveCodeSegment),
        EBNFStatementSequenceDescription(),
        EBNFConcreteTokenDescription(.otherLexeme(.end)),
        EBNFConcreteTokenDescription(.operator(.dot)).inject(resolveProgramEnd)
    ]
    
    func resolveDataSegment(_ usedTokens: [TokenDescription]) throws {
        Generator.shared.startDataSegment()
    }
    
    func resolveCodeSegment(_ usedTokens: [TokenDescription]) throws {
        Generator.shared.startCodeSegment()
    }
    
    func resolveProgramEnd(_ usedTokens: [TokenDescription]) throws {
        Generator.shared.end()
    }
}

final class EBNFProgramHeaderDescription: EBNFComplexDescription {
    lazy var descriptions: [EBNFDescription] = [
        EBNFConcreteTokenDescription(.otherLexeme(.program)),
        EBNFIdentifierDescription().inject(resolveProgramName),
        EBNFConcreteTokenDescription(.operator(.semicolon))
    ]
    
    func resolveProgramName(usedTokens: [TokenDescription]) throws {
        if case let .identifier(id) = usedTokens.first?.token {
            try Generator.shared.setProgramName(id)
        }
    }
}

final class EBNFVariableDefinitionsDescription: EBNFComplexDescription {
    lazy var descriptions: [EBNFDescription] = [
        EBNFOptionalDescription([
            EBNFConcreteTokenDescription(.otherLexeme(.var)),
            EBNFVariableSequenceDescription(),
            EBNFSequenceDescription([
                EBNFVariableSequenceDescription()
            ])
        ])
    ]
}

final class EBNFVariableSequenceDescription: EBNFComplexDescription {
    private var variableNames = [String]()

    lazy var descriptions: [EBNFDescription] = [
        EBNFIdentifierDescription().inject(resolveVariableName),
        EBNFSequenceDescription([
            EBNFConcreteTokenDescription(.operator(.comma)),
            EBNFIdentifierDescription()
        ]).inject(resolveVariableNames),
        EBNFConcreteTokenDescription(.operator(.colon)),
        EBNFTypeDescription().inject(resolveVariableType),
        EBNFConcreteTokenDescription(.operator(.semicolon))
    ]
    
    func resolveVariableName(usedTokens: [TokenDescription]) throws {
        if case let .identifier(id) = usedTokens.first?.token {
            variableNames.append(id)
        }
    }
    
    func resolveVariableNames(usedTokens: [TokenDescription]) throws {
        for (index, element) in usedTokens.enumerated() where index % 2 == 1 {
            if case let .identifier(id) = element.token {
                variableNames.append(id)
            }
        }
    }
    
    func resolveVariableType(usedTokens: [TokenDescription]) throws {
        if case let .otherLexeme(type) = usedTokens.first?.token {
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
    lazy var descriptions: [EBNFDescription] = [
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

    lazy var descriptions: [EBNFDescription] = [
        EBNFIdentifierDescription().inject(resolveVariableName),
        EBNFConcreteTokenDescription(.operator(.assign)),
        EBNFOperandDescription().inject(resolveVariableValue),
        EBNFConcreteTokenDescription(.operator(.semicolon))
    ]
    
    func resolveVariableName(usedTokens: [TokenDescription]) throws {
        if case let .identifier(id) = usedTokens.first?.token {
            variableName = id
        }
    }
    
    func resolveVariableValue(usedTokens: [TokenDescription]) throws {
        if case let .identifier(id) = usedTokens.first?.token {
            try Generator.shared.doSimpleAssignment(variable: variableName, value: id)
        } else if case let .literal(literal) = usedTokens.first?.token {
            try Generator.shared.doSimpleAssignment(variable: variableName, literal: literal)
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
    
    lazy var descriptions: [EBNFDescription] = [
        EBNFIdentifierDescription().inject(resolveVariableName),
        EBNFConcreteTokenDescription(.operator(.assign)),
        EBNFOperandDescription().inject(resolveLHS),
        EBNFMathOperationDescription().inject(resolveOperation),
        EBNFOperandDescription().inject(resolveRHS),
        EBNFConcreteTokenDescription(.operator(.semicolon))
    ]
    
    func resolveVariableName(usedTokens: [TokenDescription]) throws {
        if case let .identifier(id) = usedTokens.first?.token {
            variableName = id
        }
    }
    
    func resolveLHS(usedTokens: [TokenDescription]) throws {
        if case let .identifier(id) = usedTokens.first?.token {
            lhsVar = id
        } else if case let .literal(literal) = usedTokens.first?.token {
            lhsLit = literal
        }
    }
    
    func resolveOperation(usedTokens: [TokenDescription]) throws {
        if case let .operator(mathOperation) = usedTokens.first?.token {
            operation = mathOperation
        }
    }
    
    func resolveRHS(usedTokens: [TokenDescription]) throws {
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
    
    func clearCache() {
        variableName = ""
        lhsVar = nil
        lhsLit = nil
        operation = .plus
    }
}

final class EBNFOperandDescription: EBNFComplexDescription {
    lazy var descriptions: [EBNFDescription] = [
        EBNFOrDescription([
            EBNFIdentifierDescription(),
            EBNFLiteralDescription()
        ])
    ]
}

final class EBNFTypeDescription: EBNFComplexDescription {
    lazy var descriptions: [EBNFDescription] = [
        EBNFOrDescription([
            EBNFConcreteTokenDescription(.otherLexeme(.integer)),
            EBNFConcreteTokenDescription(.otherLexeme(.string))
        ]).inject(resolveType)
    ]
    
    func resolveType(usedTokens: [TokenDescription]) throws {
        if let first = usedTokens.first(where: { $0.token != .otherLexeme(.integer) }) {
            if case let .otherLexeme(id) = first.token {
                throw Compiler.Error.notSupportedType(id: id.rawValue)
            }
        }
    }
}

final class EBNFMathOperationDescription: EBNFComplexDescription {
    lazy var descriptions: [EBNFDescription] = [
        EBNFOrDescription([
            EBNFConcreteTokenDescription(.operator(.plus)),
            EBNFConcreteTokenDescription(.operator(.minus))
        ])
    ]
}

