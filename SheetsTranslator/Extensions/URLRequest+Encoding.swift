//
//  URLRequest+Encoding.swift
//  SheetsTranslator
//
//  Created by Marcin Chojnacki on 02.08.2017.
//  Copyright © 2017 Droids On Roids. All rights reserved.
//

import Foundation

extension URLRequest {
    
    mutating func setURLEncodedParams(_ params: [String: String]) {
        let bodyString = params.map { key, value in
            urlEncode(string: key) + "=" + urlEncode(string: value)
        }.joined(separator: "&")
        
        let contentType = "Content-Type"
        
        if value(forHTTPHeaderField: contentType) == nil {
            addValue("application/x-www-form-urlencoded", forHTTPHeaderField: contentType)
        }
        
        httpBody = bodyString.data(using: .utf8)
    }
    
    private func urlEncode(string: String) -> String {
        let generalDelimitersToEncode = ":#[]@"
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        
        return string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
    }
}
