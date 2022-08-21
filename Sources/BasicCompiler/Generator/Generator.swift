//
//  Generator.swift
//  
//
//  Created by Narek Sahakyan on 5/2/22.
//

import Foundation

protocol GeneratorInterface {
    
    // Program Configurations
    func clear()
    func setProgramName(_ name: String) throws
    func startDataSegment()
    func startCodeSegment()
    func end()
    
    // Variables
    func declareVariable(name: String, type: String) throws
    
    // Simple Assignment
    func doSimpleAssignment(variable: String, literal: Literal) throws
    func doSimpleAssignment(variable: String, value: String) throws
    
    // Complex Assignment
    func doComplexAssignment(variable: String, lhs: String, rhs: String, operation: Operator) throws
    func doComplexAssignment(variable: String, lhs: String, rhs: Literal, operation: Operator) throws
    func doComplexAssignment(variable: String, lhs: Literal, rhs: String, operation: Operator) throws
    func doComplexAssignment(variable: String, lhs: Literal, rhs: Literal, operation: Operator) throws
}

final class Generator: GeneratorInterface {
    static let shared = Generator()
    private var programName: String?
    private var variables = [String: String]()
    private var values = [String: Bool]()
    private var lastAssignmentVariable = ""
    private(set) var assemblyCode = ""
    
    func clear() {
        programName = nil
        variables = [:]
        values = [:]
        lastAssignmentVariable = ""
        assemblyCode = ""
    }
    
    // Program Name
    
    func setProgramName(_ name: String) throws {
        programName = name

        assemblyCode += "# set program name to: \(name)\n"
    }
    
    func startDataSegment() {
        assemblyCode += "\n\n# start data segment\n"
        assemblyCode += ".data"
    }
    
    func startCodeSegment() {
        assemblyCode += "\n\n# start code segment\n"
        assemblyCode += ".text\n"
        assemblyCode += ".globl main\n"
        assemblyCode += "main:"
    }
    
    func end() {
        assemblyCode += "\n\n# end\n"
        assemblyCode += "mov $60, %rax\n"
        assemblyCode += "mov \(lastAssignmentVariable), %rdi\n"
        assemblyCode += "syscall"
    }
    
    func declareVariable(name: String, type: String) throws {
        guard name != programName else {
            throw Compiler.Errors.redeclaration(id: name)
        }
        
        guard variables[name] == nil else {
            throw Compiler.Errors.redeclaration(id: name)
        }
        
        variables[name] = type
        
        assemblyCode += "\n\n# declare variable with name: \(name), and type: \(type)\n"
        assemblyCode += ".comm \(name), 8"
    }
    
    // Simple Assignment
    
    func doSimpleAssignment(variable: String, literal: Literal) throws {
        guard let type = variables[variable] else {
            throw Compiler.Errors.cannotFindInScope(id: variable)
        }
        
        guard type == literal.typeName.rawValue else {
            throw Compiler.Errors.typeMismatch(real: type, given: literal.typeName.rawValue)
        }
        
        values[variable] = true
        lastAssignmentVariable = variable
        
        assemblyCode += "\n\n# do simple assignment on variable: \(variable) with literal: \(literal)\n"
        assemblyCode += "movq $\(literal.value), \(variable)"
    }
    
    func doSimpleAssignment(variable: String, value: String) throws {
        guard let type = variables[variable] else {
            throw Compiler.Errors.cannotFindInScope(id: variable)
        }
        
        guard let vType = variables[value] else {
            throw Compiler.Errors.cannotFindInScope(id: value)
        }
        
        guard type == vType else {
            throw Compiler.Errors.typeMismatch(real: type, given: vType)
        }
        
        guard values[value] == true else {
            throw Compiler.Errors.notInitialized(id: value)
        }
        
        values[variable] = true
        lastAssignmentVariable = variable
        
        assemblyCode += "\n\n# do simple assignment on variable: \(variable) with value: \(value)\n"
        assemblyCode += "movq \(value), %rax\n"
        assemblyCode += "movq %rax, \(variable)"
    }
    
    // Complex Assignment
    
    func doComplexAssignment(variable: String, lhs: String, rhs: String, operation: Operator) throws {
        guard let type = variables[variable] else {
            throw Compiler.Errors.cannotFindInScope(id: variable)
        }
        
        guard let lType = variables[lhs] else {
            throw Compiler.Errors.cannotFindInScope(id: lhs)
        }
        
        guard let rType = variables[rhs] else {
            throw Compiler.Errors.cannotFindInScope(id: rhs)
        }
        
        guard type == lType else {
            throw Compiler.Errors.typeMismatch(real: type, given: lType)
        }
        
        guard type == rType else {
            throw Compiler.Errors.typeMismatch(real: type, given: rType)
        }
        
        guard values[lhs] == true else {
            throw Compiler.Errors.notInitialized(id: lhs)
        }
        
        guard values[rhs] == true else {
            throw Compiler.Errors.notInitialized(id: rhs)
        }
        
        var operatorStatement = ""
        if case .plus = operation {
            operatorStatement = "add"
        } else if case .minus = operation {
            operatorStatement = "sub"
        }
        
        values[variable] = true
        lastAssignmentVariable = variable
        
        assemblyCode += "\n\n# do complex assignment on variable: \(variable) with: \(lhs), \(operation), \(rhs)\n"
        assemblyCode += "movq \(lhs), %rax\n"
        assemblyCode += "movq \(rhs), %rbx\n"
        assemblyCode += "\(operatorStatement) %rbx, %rax\n"
        assemblyCode += "movq %rax, \(variable)"
    }
    
    func doComplexAssignment(variable: String, lhs: String, rhs: Literal, operation: Operator) throws {
        guard let type = variables[variable] else {
            throw Compiler.Errors.cannotFindInScope(id: variable)
        }
        
        guard let lType = variables[lhs] else {
            throw Compiler.Errors.cannotFindInScope(id: lhs)
        }
        
        guard type == lType else {
            throw Compiler.Errors.typeMismatch(real: type, given: lType)
        }
        
        guard type == rhs.typeName.rawValue else {
            throw Compiler.Errors.typeMismatch(real: type, given: rhs.typeName.rawValue)
        }
        
        guard values[lhs] == true else {
            throw Compiler.Errors.notInitialized(id: lhs)
        }
        
        var operatorStatement = ""
        if case .plus = operation {
            operatorStatement = "add"
        } else if case .minus = operation {
            operatorStatement = "sub"
        }
        
        values[variable] = true
        lastAssignmentVariable = variable

        assemblyCode += "\n\n# do complex assignment on variable: \(variable) with: \(lhs), \(operation), \(rhs)\n"
        assemblyCode += "movq \(lhs), %rax\n"
        assemblyCode += "movq $\(rhs.value), %rbx\n"
        assemblyCode += "\(operatorStatement) %rbx, %rax\n"
        assemblyCode += "movq %rax, \(variable)"
    }
    
    func doComplexAssignment(variable: String, lhs: Literal, rhs: String, operation: Operator) throws {
        guard let type = variables[variable] else {
            throw Compiler.Errors.cannotFindInScope(id: variable)
        }
        
        guard let rType = variables[rhs] else {
            throw Compiler.Errors.cannotFindInScope(id: rhs)
        }
        
        guard type == lhs.typeName.rawValue else {
            throw Compiler.Errors.typeMismatch(real: type, given: lhs.typeName.rawValue)
        }
        
        guard type == rType else {
            throw Compiler.Errors.typeMismatch(real: type, given: rType)
        }
        
        guard values[rhs] == true else {
            throw Compiler.Errors.notInitialized(id: rhs)
        }
        
        var operatorStatement = ""
        if case .plus = operation {
            operatorStatement = "add"
        } else if case .minus = operation {
            operatorStatement = "sub"
        }
        
        values[variable] = true
        lastAssignmentVariable = variable

        assemblyCode += "\n\n# do complex assignment on variable: \(variable) with: \(lhs), \(operation), \(rhs)\n"
        assemblyCode += "movq $\(lhs.value), %rax\n"
        assemblyCode += "movq \(rhs), %rbx\n"
        assemblyCode += "\(operatorStatement) %rbx, %rax\n"
        assemblyCode += "movq %rax, \(variable)"
    }
    
    func doComplexAssignment(variable: String, lhs: Literal, rhs: Literal, operation: Operator) throws {
        guard let type = variables[variable] else {
            throw Compiler.Errors.cannotFindInScope(id: variable)
        }
        
        guard type == lhs.typeName.rawValue else {
            throw Compiler.Errors.typeMismatch(real: type, given: lhs.typeName.rawValue)
        }
        
        guard type == rhs.typeName.rawValue else {
            throw Compiler.Errors.typeMismatch(real: type, given: rhs.typeName.rawValue)
        }
        
        guard case let .int(lhsInt) = lhs, case let .int(rhsInt) = rhs else {
            throw Compiler.Errors.notSupportedType(id: "string")
        }
        
        var optimized = 0
        if case .plus = operation {
            optimized = lhsInt + rhsInt
        } else if case .minus = operation {
            optimized = lhsInt - rhsInt
        }
        
        values[variable] = true
        lastAssignmentVariable = variable
        
        assemblyCode += "\n\n# do complex assignment on variable: \(variable) with: \(lhs), \(operation), \(rhs)\n"
        assemblyCode += "movq $\(optimized), \(variable)"
    }
}
