//
//  File.swift
//  
//
//  Created by Narek Sahakyan on 21.02.24.
//

import Foundation

fileprivate let moduleName = "BasicCompiler"
fileprivate let separator = "."

protocol LocalizedError: Foundation.LocalizedError {
    var localizationErrorKey: String { get }
    var localizationErrorArguments: [Any] { get }
    var localizationErrorDescription: String { get }    
}

protocol LocalizedErrorValue {
    var values: [Any] { get }
}

extension LocalizedError {
    var localizationErrorKey: String {
        let mirror = Mirror(reflecting: self)
        let typeNamePath = String(reflecting: type(of: self))
        let fullNamePath = typeNamePath.removingPrefix("\(moduleName)\(separator)")
        
        guard let child = mirror.children.first, let label = child.label else {
            let label = String(describing: self)
            let key = fullNamePath.appending("\(separator)\(label)")
            return key
        }
                          
        let key = fullNamePath.appending("\(separator)\(label)")
        return key
    }
    
    var localizationErrorArguments: [Any] {
        let mirror = Mirror(reflecting: self)
        
        guard let child = mirror.children.first else {
            return []
        }
        
        let associatedValues = Mirror(reflecting: child.value)
        let arguments = associatedValues
            .children
            .compactMap({ $0.value as? LocalizedErrorValue })
            .reduce([], { $0 + $1.values })
        return arguments
    }
    
    var localizationErrorDescription: String {
        let key = self.localizationErrorKey
        let arguments = self.localizationErrorArguments
        
        if arguments.isEmpty {
            return String(localized: .init(key), bundle: .module)
        }
                
        var stringInterpolation = String.LocalizationValue.StringInterpolation(literalCapacity: 0, interpolationCount: arguments.count)
        stringInterpolation.appendLiteral(key)
        stringInterpolation.appendLiteral("[")
        arguments.enumerated().forEach {
            if let formatSpecifiable = $0.element as? (any _FormatSpecifiable) {
                stringInterpolation.appendInterpolation(formatSpecifiable)
            } else if let string = $0.element as? String {
                stringInterpolation.appendInterpolation(string)
            } else {
                stringInterpolation.appendInterpolation("\($0.element)")
            }
            
            if $0.offset < arguments.count - 1 {
                stringInterpolation.appendLiteral("|")
            }
        }
        stringInterpolation.appendLiteral("]")

        return String(localized: .init(stringInterpolation: stringInterpolation), bundle: .module)
    }
    
    var errorDescription: String? {
        localizationErrorDescription
    }
}
