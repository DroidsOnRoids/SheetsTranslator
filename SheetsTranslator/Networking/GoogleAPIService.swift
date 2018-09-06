//
//  GoogleAPIService.swift
//  SheetsTranslator
//
//  Created by Marcin Chojnacki on 02.08.2017.
//  Copyright © 2017 Droids On Roids. All rights reserved.
//

import Foundation

typealias APIResultCallback = (APIResult<[String: Any]>) -> ()

final class GoogleAPIService {
    
    private static let timeout: TimeInterval = 10
    
    private var token: String?
    
    private let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout
        
        return URLSession(configuration: configuration)
    }()
    
    func refreshToken(jwt: JSONWebToken, completion: @escaping APIResultCallback) {
        jsonRequest(GoogleAPIRouter.oauthToken(jwt.token).urlRequest) { [weak self] result in
            if case let .success(data) = result, let accessToken = data["access_token"] as? String {
                self?.token = accessToken
            }
            
            completion(result)
        }
    }
    
    func authorizedRequest(_ request: GoogleAPIRouter, completion: @escaping APIResultCallback) {
        var urlRequest = request.urlRequest
        if let token = token {
            urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        jsonRequest(urlRequest, completion: completion)
    }
    
    private func jsonRequest(_ request: URLRequestProtocol, completion: @escaping APIResultCallback) {
        session.dataTask(with: request.urlRequest) { data, _, error in
            guard let data = data else {
                completion(.failure(error))
                return
            }
            
            let jsonData = try? JSONSerialization.jsonObject(with: data, options: [])
            if let json = jsonData as? [String: Any] {
                completion(.success(json))
            }
        }.resume()
    }
}
