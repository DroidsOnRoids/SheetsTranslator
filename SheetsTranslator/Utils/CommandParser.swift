//
//  CommandParser.swift
//  SheetsTranslator
//
//  Created by Marcin Chojnacki on 05.08.2017.
//  Copyright © 2017 Droids On Roids. All rights reserved.
//

import Foundation

final class CommandParser {
    
    enum CommandParserError: LocalizedError {
        case illegalArgument
        case notEnoughArgumentsAfter
        case requiredArgumentNotFound
        case duplicatedArgument
        
        var errorDescription: String? {
            switch self {
            case .illegalArgument:
                return "Illegal argument"
            case .notEnoughArgumentsAfter:
                return "Not enough arguments"
            case .requiredArgumentNotFound:
                return "Required argument not found"
            case .duplicatedArgument:
                return "Duplicated argument"
            }
        }
    }
    
    private let argumentsToParse: [String]
    private var arguments = [CommandArgument]()
    
    init(argumentsToParse: [String] = Array(CommandLine.arguments[1..<CommandLine.arguments.count])) {
        self.argumentsToParse = argumentsToParse
    }
    
    func add(arguments: CommandArgument...) {
        self.arguments.append(contentsOf: arguments)
    }
    
    func parse() throws {
        var matchedArguments = [CommandArgument]()
        var i = 0
        
        while i < argumentsToParse.count {
            let matchingArguments = arguments.filter {
                $0.matches(argumentsToParse[i])
            }
            
            guard let matchingArgument = matchingArguments.first, matchingArguments.count == 1 else {
                throw CommandParserError.illegalArgument
            }
            
            guard !matchedArguments.contains(matchingArgument) else {
                throw CommandParserError.duplicatedArgument
            }
            
            let nextArgumentIndex = i + 1
            let afterArgumentsRange = nextArgumentIndex..<(nextArgumentIndex + matchingArgument.argumentsAfter)
            
            guard afterArgumentsRange.upperBound <= argumentsToParse.count else {
                throw CommandParserError.notEnoughArgumentsAfter
            }
            
            matchingArgument.addArgumentsAfter(Array(argumentsToParse[afterArgumentsRange]))
            matchedArguments.append(matchingArgument)
            
            i = afterArgumentsRange.upperBound
        }
        
        guard (arguments.filter { $0.required }.count) == (matchedArguments.filter { $0.required }.count) else {
            throw CommandParserError.requiredArgumentNotFound
        }
    }
    
    func usage(forProgramName programName: String) -> String {
        return "Usage: \(programName) [options]\n" + arguments.map { argument in
            "  -\(argument.shortFlag), --\(argument.longFlag):\n" +
            "      \(argument.usage)"
        }.joined(separator: "\n")
    }
}

class CommandArgument: Equatable, CustomStringConvertible {
    
    let shortFlag: String
    let longFlag: String
    let required: Bool
    let usage: String
    
    var isActive: Bool = false
    
    var argumentsAfter: Int {
        return 0
    }
    
    var description: String {
        return longFlag
    }
    
    init(shortFlag: String, longFlag: String, required: Bool, usage: String) {
        self.shortFlag = shortFlag
        self.longFlag = longFlag
        self.required = required
        self.usage = usage
    }
    
    static func == (lhs: CommandArgument, rhs: CommandArgument) -> Bool {
        return lhs.longFlag == rhs.longFlag
    }
    
    func matches(_ argument: String) -> Bool {
        return argument == "-\(shortFlag)" || argument == "--\(longFlag)"
    }
    
    func addArgumentsAfter(_ arguments: [String]) {
        isActive = true
    }
}

final class CommandStringArgument: CommandArgument {
    
    var value: String?
    
    override var argumentsAfter: Int {
        return 1
    }
    
    override func addArgumentsAfter(_ arguments: [String]) {
        super.addArgumentsAfter(arguments)
        value = arguments.first
    }
}
