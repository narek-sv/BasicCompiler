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
        print(Compiler.Errors.sourceFileNotProvided.localizedDescription)
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
        print(Compiler.Errors.sourceFileDoesnNotExist(filename: filePath).localizedDescription)
        return
    }
        
    do {
        let data = try String(contentsOf: url)
        let complier = Compiler(parser: Parser(input: data))
        try complier.compile()
        
        let sourceFileName = URL(fileURLWithPath: filePath).deletingPathExtension().lastPathComponent
        let asmFileURL = currentDirectoryURL.appendingPathComponent(sourceFileName).appendingPathExtension("s")
//        try Evaluator.shared.assemblyCode.data(using: .utf8)?.write(to: asmFileURL)
        
        
        let testFile = try! String(contentsOf: URL(fileURLWithPath: "/Users/narek.sahakyan/Documents/Projects/SwiftCompiler/BasicCompiler/Sources/test.s"))
        print(testFile)
        print(Generator.shared.assemblyCode)
        
        if (testFile.trimmingCharacters(in: .whitespacesAndNewlines) != Generator.shared.assemblyCode.trimmingCharacters(in: .whitespacesAndNewlines)) {
            fatalError()
        }
    } catch let error as Parser.Errors {
        print("Failed to parse the file with error: \(error.localizedDescription)")
    } catch let error as Compiler.Errors {
        print("Failed to compile the file with error: \(error.localizedDescription)")
    } catch {
        print("Failed with error: \(error.localizedDescription)")
    }
}

run(arguments: ["", "/Users/narek.sahakyan/Documents/Projects/SwiftCompiler/BasicCompiler/Sources/test.pas"])
//run(arguments: ["", "../test.pas"])
//run(arguments: ["", "aaaaa.aaaa"])

//run(arguments: CommandLine.arguments)
