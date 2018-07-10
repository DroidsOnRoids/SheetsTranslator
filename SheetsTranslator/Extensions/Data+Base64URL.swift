//
//  Data+Base64URL.swift
//  SheetsTranslator
//
//  Created by Marcin Chojnacki on 16.07.2017.
//  Copyright © 2016 Auth0. All rights reserved.
//

import Foundation

extension Data {
    
    init?(base64URLEncoded string: String) {
        let base64Encoded = string
            .replacingOccurrences(of: "_", with: "/")
            .replacingOccurrences(of: "-", with: "+")
        
        let padLength = (4 - (base64Encoded.count % 4)) % 4
        let base64EncodedWithPadding = base64Encoded + String(repeating: "=", count: padLength)
        
        self.init(base64Encoded: base64EncodedWithPadding)
    }
    
    func base64URLEncodedString() -> String {
        return self.base64EncodedString()
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "=", with: "")
    }
}
