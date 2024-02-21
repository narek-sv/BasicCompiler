//
//  LocalizedErrorValue.swift
//
//
//  Created by Narek Sahakyan on 21.02.24.
//

import Foundation

extension LocalizedErrorValue {
    var values: [Any] {
        return [self]
    }
}

extension String: LocalizedErrorValue { }
extension Character: LocalizedErrorValue { }
extension Int: LocalizedErrorValue { }
extension Double: LocalizedErrorValue { }
extension TokenDescription: LocalizedErrorValue {
    var values: [Any] {
        return [line, offset, token]
    }
}
