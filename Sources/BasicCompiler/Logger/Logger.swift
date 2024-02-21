//
//  Logger.swift
//
//
//  Created by Narek Sahakyan on 17.02.24.
//

import Foundation

final class Logger {
    static let shared = Logger()
    
    func error(_ message: LocalizedError) {
        print(message.localizedDescription)
    }
}
