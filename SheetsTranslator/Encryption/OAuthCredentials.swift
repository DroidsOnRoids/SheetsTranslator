//
//  OAuthCredentials.swift
//  SheetsTranslator
//
//  Created by Marcin Chojnacki on 16.07.2017.
//  Copyright © 2017 Droids On Roids. All rights reserved.
//

import Foundation

struct OAuthCredentials {
    
    enum OAuthCredentialsError: Error {
        case malformedCredentialsFile
    }
    
    let privateKey: PrivateKey
    let clientEmail: String
    
    init(fromData data: Data) throws {
        let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
        guard let json = jsonData as? [String: Any] else {
            throw OAuthCredentialsError.malformedCredentialsFile
        }
        
        guard let privateKey = json["private_key"] as? String,
              let clientEmail = json["client_email"] as? String else {
            throw OAuthCredentialsError.malformedCredentialsFile
        }
        
        self.privateKey = try NativePrivateKey(fromPemString: privateKey)
        self.clientEmail = clientEmail
    }
    
    init(fromFilePath filePath: String) throws {
        let jsonData = try Data(contentsOf: URL(fileURLWithPath: filePath))
        
        try self.init(fromData: jsonData)
    }
}
