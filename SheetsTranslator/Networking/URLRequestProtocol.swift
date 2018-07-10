//
//  URLRequestProtocol
//  SheetsTranslator
//
//  Created by Marcin Chojnacki on 02.08.2017.
//  Copyright © 2017 Droids On Roids. All rights reserved.
//

import Foundation

protocol URLRequestProtocol {
    var urlRequest: URLRequest { get }
}

extension URLRequest: URLRequestProtocol {
    
    var urlRequest: URLRequest {
        return self
    }
}
