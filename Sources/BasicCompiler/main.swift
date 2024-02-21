//
//  main.swift
//  Compiler
//
//  Created by Narek Sahakyan on 2/7/22.
//

import Foundation

func run(arguments: [String]) {
    Generator.shared.clear()
        
    guard arguments.indices.contains(1) else {
        Logger.shared.error(Compiler.Error.sourceFileNotProvided)
        return
    }
    
    let filePath = arguments[1]
    let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    
    let url: URL
    if FileManager.default.fileExists(atPath: currentDirectoryURL.appendingPathComponent(filePath).absoluteString) {
        url = currentDirectoryURL.appendingPathComponent(filePath)
    } else if FileManager.default.fileExists(atPath: filePath) {
        url = URL(fileURLWithPath: filePath)
    } else {
        Logger.shared.error(Compiler.Error.sourceFileDoesnNotExist(filename: filePath))
        return
    }
        
    do {
        let data = try String(contentsOf: url)
        let complier = Compiler(parser: Parser(input: data))
        try complier.compile()
        
        let sourceFileName = URL(fileURLWithPath: filePath).deletingPathExtension().lastPathComponent
        let asmFileURL = currentDirectoryURL.appendingPathComponent(sourceFileName).appendingPathExtension("s")
        try Generator.shared.assemblyCode.data(using: .utf8)?.write(to: asmFileURL)
    } catch let error as LocalizedError {
        Logger.shared.error(error)
    } catch {
        Logger.shared.error(Compiler.Error.other(error: "\(error)"))
    }
}

run(arguments: CommandLine.arguments)

