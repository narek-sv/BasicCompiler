//
//  File.swift
//  
//
//  Created by Narek Sahakyan on 5/2/22.
//

import Foundation

final class ProgramFormDescription {
    func evaluate(form: FormDescription, index: Int, usedTokens: [TokenExpression]) throws {
        if index == 0 {
            Evaluator.shared.startDataSegment()
        } else if index == 2 {
            Evaluator.shared.startCodeSegment()
        } else if index == 5 {
            Evaluator.shared.end()
        }
    }
}

final class ProgramHeaderFormDescription {
    func evaluate(form: FormDescription, index: Int, usedTokens: [TokenExpression]) throws {
        if index == 1, case let .identifier(id) = usedTokens.first?.token {
            try Evaluator.shared.setProgramName(id)
        }
    }
}

final class VariableSequenceFormDescription {
    private var variableNames = [String]()
    
    func evaluate(form: FormDescription, index: Int, usedTokens: [TokenExpression]) throws {
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
                try Evaluator.shared.declareVariable(name: $0, type: type.rawValue)
            }
            
            variableNames.removeAll()
        }
    }
}

final class SimpleAssignmentFormDescription {
    private(set) var variableName = ""
    
    func evaluate(form: FormDescription, index: Int, usedTokens: [TokenExpression]) throws {
        if index == 0, case let .identifier(id) = usedTokens.first?.token {
            variableName = id
        } else if index == 2 {
            if case let .identifier(id) = usedTokens.first?.token {
                try Evaluator.shared.doSimpleAssignment(variable: variableName, value: id)
            } else if case let .literal(literal) = usedTokens.first?.token {
                try Evaluator.shared.doSimpleAssignment(variable: variableName, literal: literal)
            }
        }
    }
}

final class ComplexAssignmentFormDescription {
    private(set) var variableName = ""
    private(set) var lhsVar: String?
    private(set) var lhsLit: Literal?
    private(set) var operation: Operator = .plus
    
    func evaluate(form: FormDescription, index: Int, usedTokens: [TokenExpression]) throws {
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
                    try Evaluator.shared.doComplexAssignment(variable: variableName, lhs: lhsVar, rhs: id, operation: operation)
                } else if let lhsLit = lhsLit {
                    try Evaluator.shared.doComplexAssignment(variable: variableName, lhs: lhsLit, rhs: id, operation: operation)
                }
            } else if case let .literal(lit) = usedTokens.first?.token {
                if let lhsVar = lhsVar {
                    try Evaluator.shared.doComplexAssignment(variable: variableName, lhs: lhsVar, rhs: lit, operation: operation)
                } else if let lhsLit = lhsLit {
                    try Evaluator.shared.doComplexAssignment(variable: variableName, lhs: lhsLit, rhs: lit, operation: operation)
                }
            }
            
            lhsVar = nil
            lhsLit = nil
        }
    }
}

final class TypeFormDescription {
    func evaluate(form: FormDescription, index: Int, usedTokens: [TokenExpression]) throws {
        if let first = usedTokens.first(where: { $0.token != .otherLexem(.integer) }) {
            if case let .otherLexem(id) = first.token {
                throw Compiler.Errors.notSupportedType(id: id.rawValue)
            }
        }
    }
}


final class VariableDefinitionsFormDescription { }
final class StatementSequenceFormDescription { }
final class OperandFormDescription { }
final class MathOperationFormDescription { }
