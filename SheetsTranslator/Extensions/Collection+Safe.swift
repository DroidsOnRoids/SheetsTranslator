//
//  Collection+Safe.swift
//  SheetsTranslator
//
//  Created by Marcin Chojnacki on 03.08.2017.
//  Copyright © 2017 Droids On Roids. All rights reserved.
//

extension Collection where Indices.Iterator.Element == Index {
    
    subscript(safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
