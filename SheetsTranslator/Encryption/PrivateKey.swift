//
//  PrivateKey.swift
//  SheetsTranslator
//
//  Created by Marcin Chojnacki on 16.07.2017.
//  Copyright © 2017 Droids On Roids. All rights reserved.
//

import Foundation

enum SignatureType {
    case sha256WithRsa
}

protocol PrivateKey {
    func sign(type: SignatureType, data: Data) throws -> Data
}
