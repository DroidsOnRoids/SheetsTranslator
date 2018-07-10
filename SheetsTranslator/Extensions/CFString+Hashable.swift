//
//  CFString+Hashable.swift
//  SheetsTranslator
//
//  Created by Marcin Chojnacki on 16.07.2017.
//  Copyright © 2017 Droids On Roids. All rights reserved.
//

import Foundation

extension CFString: Hashable {
    
    public var hashValue: Int {
        return (self as String).hashValue
    }
    
    static public func == (lhs: CFString, rhs: CFString) -> Bool {
        return lhs as String == rhs as String
    }
}
