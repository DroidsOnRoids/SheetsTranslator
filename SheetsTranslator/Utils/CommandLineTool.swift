//
//  CommandLineTool.swift
//  SheetsTranslator
//
//  Created by Marcin Chojnacki on 05.08.2017.
//  Copyright © 2017 Droids On Roids. All rights reserved.
//

import Foundation

struct CommandLineTool {
    
    static let shared = CommandLineTool()
    
    let parser = CommandParser()
    let programPath: String
    let programName: String
    
    private let semaphore = DispatchSemaphore(value: 0)
    private let helpArgument = CommandArgument(shortFlag: "h",
                                               longFlag: "help",
                                               required: false,
                                               usage: "Displays this message")
    
    private init() {
        if let programCall = CommandLine.arguments.first,
            let programURL = URL(string: programCall) {
            self.programPath = programURL.deletingLastPathComponent().absoluteString
            self.programName = programURL.lastPathComponent
        } else {
            self.programPath = "./"
            self.programName = "example"
        }
        
        parser.add(arguments: helpArgument)
    }
    
    func parseOrExit() {
        helpArgument.isActive = false
        
        do {
            try parser.parse()
        } catch let error {
            print(error.localizedDescription)
            print()
            print(parser.usage(forProgramName: programName))
            complete(64)
        }
        
        if helpArgument.isActive {
            print(parser.usage(forProgramName: programName))
            complete(0)
        }
    }
    
    func waitForCompletion() {
        semaphore.wait()
    }
    
    func complete(_ code: Int? = nil) {
        exit(Int32(code ?? 0))
    }
}
