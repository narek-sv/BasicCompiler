//
//  File.swift
//  
//
//  Created by Narek Sahakyan on 8/21/22.
//

import Foundation

final class EnvironmentVariables {
    private var handlers = [ObjectIdentifier: (([TokenDescription]) throws -> ())]()
    static let shared = EnvironmentVariables()
    
    func setHandler(_ handler: @escaping (([TokenDescription]) throws -> ()), for instance: AnyObject) {
        handlers[ObjectIdentifier(instance)] = handler
    }
    
    func getHandler(for instance: AnyObject) -> (([TokenDescription]) throws -> ())? {
        handlers[ObjectIdentifier(instance)]
    }
    
    func removeHandler(for instance: AnyObject) {
        handlers[ObjectIdentifier(instance)] = nil
    }
}
