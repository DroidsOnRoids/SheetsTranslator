//
//  GoogleAPIClient.swift
//  SheetsTranslator
//
//  Created by Marcin Chojnacki on 16.07.2017.
//  Copyright © 2017 Droids On Roids. All rights reserved.
//

import Foundation

enum APIResult<Element> {
    case success(Element)
    case failure(Error?)
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

enum GoogleAPIRouter: URLRequestProtocol {
    
    private static let googleAPIVersion = 4
    
    private static let oauthBasePath = "https://www.googleapis.com/oauth2/v\(googleAPIVersion)"
    private static let sheetsBasePath = "https://sheets.googleapis.com/v\(googleAPIVersion)"

    case oauthToken(String)
    case spreadsheetsGet(String, Bool)
    
    var fullPath: String {
        switch self {
        case .oauthToken:
            return "\(GoogleAPIRouter.oauthBasePath)/token"
        case .spreadsheetsGet(let id, let includeGridData):
            return "\(GoogleAPIRouter.sheetsBasePath)/spreadsheets/\(id)?includeGridData=\(includeGridData)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .oauthToken: return .post
        case .spreadsheetsGet: return .get
        }
    }
    
    var urlEncodedParams: [String: String]? {
        switch self {
        case .oauthToken(let token):
            return [
                "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
                "assertion": token
            ]
        default: return nil
        }
    }
    
    var urlRequest: URLRequest {
        let urlPath = URL(string: fullPath)!
        var urlRequest = URLRequest(url: urlPath)
        
        urlRequest.httpMethod = method.rawValue
        if let urlEncodedParams = urlEncodedParams {
            urlRequest.setURLEncodedParams(urlEncodedParams)
        }
        
        return urlRequest
    }
}
