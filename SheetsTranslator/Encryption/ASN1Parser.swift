//
//  ASN1Parser.swift
//  SheetsTranslator
//
//  Created by Marcin Chojnacki on 16.07.2017.
//  Copyright © 2017 Scoop. All rights reserved.
//

import Foundation

private extension Data {
    
    var firstByte: UInt8 {
        var byte: UInt8 = 0
        copyBytes(to: &byte, count: MemoryLayout<UInt8>.size)
        
        return byte
    }
    
    var integer: Int {
        guard !isEmpty else { return 0 }
        
        var int: UInt32 = 0
        var offset: Int32 = Int32(count - 1)
        
        forEach { byte in
            let byte32 = UInt32(byte)
            let shifted = byte32 << (UInt32(offset) * 8)
            int = int | shifted
            offset -= 1
        }
        
        return Int(int)
    }
}

private class Scanner {
    
    enum ScannerError: Error {
        case outOfBounds
    }
    
    private let data: Data
    private var index: Int = 0
    
    var isComplete: Bool {
        return index >= data.count
    }

    init(data: Data) {
        self.data = data
    }

    func consume(length: Int) throws -> Data {
        guard length > 0 else { return Data() }
        guard index + length <= data.count else { throw ScannerError.outOfBounds }
        
        let subdata = data.subdata(in: index..<index + length)
        index += length
        
        return subdata
    }
    
    func consumeLength() throws -> Int {
        let lengthByte = try consume(length: 1).firstByte

        guard lengthByte >= 0x80 else { return Int(lengthByte) }
        
        let nextByteCount = lengthByte - 0x80
        let length = try consume(length: Int(nextByteCount))
        
        return length.integer
    }
}

enum ASN1Parser {
    
    enum ParserError: Error {
        case noType
        case invalidType(value: UInt8)
    }
    
    enum Node {
        case sequence(nodes: [Node])
        case integer(data: Data)
        case objectIdentifier(data: Data)
        case null
        case bitString(data: Data)
        case octetString(data: Data)
    }
    
    static func parse(data: Data) throws -> Node {
        let scanner = Scanner(data: data)
        let node = try parseNode(scanner: scanner)
        
        return node
    }
    
    private static func parseNode(scanner: Scanner) throws -> Node {
        let firstByte = try scanner.consume(length: 1).firstByte
        
        // sequence
        if firstByte == 0x30 {
            let length = try scanner.consumeLength()
            let data = try scanner.consume(length: length)
            let nodes = try parseSequence(data: data)
            
            return .sequence(nodes: nodes)
        }
        
        // integer
        if firstByte == 0x02 {
            let length = try scanner.consumeLength()
            let data = try scanner.consume(length: length)
            
            return .integer(data: data)
        }
        
        // object identifier
        if firstByte == 0x06 {
            let length = try scanner.consumeLength()
            let data = try scanner.consume(length: length)
            
            return .objectIdentifier(data: data)
        }
        
        // null
        if firstByte == 0x05 {
            _ = try scanner.consume(length: 1)
            return .null
        }
        
        // bit string
        if firstByte == 0x03 {
            let length = try scanner.consumeLength()
            _ = try scanner.consume(length: 1)
            let data = try scanner.consume(length: length - 1)
            
            return .bitString(data: data)
        }
        
        // octet string
        if firstByte == 0x04 {
            let length = try scanner.consumeLength()
            let data = try scanner.consume(length: length)
            
            return .octetString(data: data)
        }
        
        throw ParserError.invalidType(value: firstByte)
    }

    private static func parseSequence(data: Data) throws -> [Node] {
        let scanner = Scanner(data: data)
        var nodes: [Node] = []
        
        while !scanner.isComplete {
            let node = try parseNode(scanner: scanner)
            nodes.append(node)
        }
        
        return nodes
    }
}
