//
//  JSONWebToken.swift
//  SheetsTranslator
//
//  Created by Marcin Chojnacki on 15.07.2017.
//  Copyright © 2017 Droids On Roids. All rights reserved.
//

import Foundation

enum AuthScope: String {
    case spreadsheetsReadOnly = "spreadsheets.readonly"
}

struct JSONWebToken {
    
    enum JSONWebTokenError: Error {
        case dataEncodingFailure
    }
    
    private static let tokenExpirationInterval = 3600
    
    private static let header = [
        "alg": "RS256",
        "typ": "JWT"
    ]
    
    let token: String
    let creationTime: Int
    let expirationTime: Int
    
    var isExpired: Bool {
        return expirationTime >= JSONWebToken.currentTime
    }
    
    init(credentials: OAuthCredentials, scope: AuthScope) throws {
        self.creationTime = JSONWebToken.currentTime
        self.expirationTime = self.creationTime + JSONWebToken.tokenExpirationInterval
        
        let claims: [String: Any] = [
            "iss": credentials.clientEmail,
            "scope": "https://www.googleapis.com/auth/\(scope.rawValue)",
            "aud": "https://www.googleapis.com/oauth2/v4/token",
            "exp": self.expirationTime,
            "iat": self.creationTime
        ]
        
        let jsonHeader = try JSONSerialization.data(withJSONObject: JSONWebToken.header, options: [])
        let jsonPayload = try JSONSerialization.data(withJSONObject: claims, options: [])
        let message = jsonHeader.base64URLEncodedString() + "." + jsonPayload.base64URLEncodedString()
        
        guard let data = message.data(using: .utf8) else {
            throw JSONWebTokenError.dataEncodingFailure
        }
        
        let signature = try credentials.privateKey.sign(type: .sha256WithRsa, data: data)
        self.token = message + "." + signature.base64URLEncodedString()
    }
    
    static var currentTime: Int {
        return Int(Date().timeIntervalSince1970)
    }
}
