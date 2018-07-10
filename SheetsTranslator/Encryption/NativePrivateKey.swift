//
//  NativePrivateKey.swift
//  SheetsTranslator
//
//  Created by Marcin Chojnacki on 16.07.2017.
//  Copyright © 2017 Droids On Roids. All rights reserved.
//

import Foundation

struct NativePrivateKey: PrivateKey {
    
    enum NativePrivateKeyError: Error {
        case invalidASN1Structure
        case secCreateKeyFailure
        case secCreateTransformFailure
        case secAttributeFailure
        case secSignFailure
        case internalError
    }
    
    let secKey: SecKey
    
    init(fromData data: Data) throws {
        let sizeInBits = data.count * 8
        let keyDict: [CFString: Any] = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPrivate,
            kSecAttrKeySizeInBits: NSNumber(value: sizeInBits)
        ]
        
        guard let secKey = SecKeyCreateWithData(data as CFData, keyDict as CFDictionary, nil) else {
            throw NativePrivateKeyError.secCreateKeyFailure
        }
        
        self.secKey = secKey
    }
    
    init(fromPemString pemString: String) throws {
        let lines = pemString.components(separatedBy: "\n").filter { line in
            return !line.hasPrefix("-----BEGIN") && !line.hasPrefix("-----END")
        }
        
        let keyString = lines.joined(separator: "")
        
        guard let keyData = Data(base64Encoded: keyString) else {
            throw NativePrivateKeyError.internalError
        }
        
        try self.init(fromData: try NativePrivateKey.stripKeyHeader(keyData: keyData))
    }
    
    func sign(type: SignatureType, data: Data) throws -> Data {
        switch type {
        case .sha256WithRsa:
            return try signSHA256WithRSA(data: data)
        }
    }
    
    private func signSHA256WithRSA(data: Data) throws -> Data {
        guard let signTransform = SecSignTransformCreate(secKey, nil) else {
            throw NativePrivateKeyError.secCreateTransformFailure
        }
        
        var digestLength = 256
        guard let cfDigestLength = CFNumberCreate(kCFAllocatorDefault, .intType, &digestLength) else {
            throw NativePrivateKeyError.internalError
        }
        
        try setTransform(signTransform, key: kSecTransformInputAttributeName, value: data as NSData)
        try setTransform(signTransform, key: kSecPaddingKey, value: kSecPaddingPKCS1Key)
        try setTransform(signTransform, key: kSecDigestTypeAttribute, value: kSecDigestSHA2)
        try setTransform(signTransform, key: kSecDigestLengthAttribute, value: cfDigestLength)
        
        guard let signature = SecTransformExecute(signTransform, nil) as? Data else {
            throw NativePrivateKeyError.secSignFailure
        }
        
        return signature
    }
    
    private func setTransform(_ transform: SecTransform, key: CFString, value: CFTypeRef) throws {
        guard SecTransformSetAttribute(transform, key, value, nil) else {
            throw NativePrivateKeyError.secAttributeFailure
        }
    }
    
    private static func stripKeyHeader(keyData: Data) throws -> Data {
        let node = try ASN1Parser.parse(data: keyData)
        
        guard case .sequence(let nodes) = node else {
            throw NativePrivateKeyError.invalidASN1Structure
        }
        
        let onlyHasIntegers = nodes.filter { node in
            if case .integer(_) = node {
                return false
            } else {
                return true
            }
        }.isEmpty
        
        if onlyHasIntegers {
            return keyData
        }
        
        if let last = nodes.last, case .bitString(let data) = last {
            return data
        }
        
        if let last = nodes.last, case .octetString(let data) = last {
            return data
        }
        
        throw NativePrivateKeyError.invalidASN1Structure
    }
}
