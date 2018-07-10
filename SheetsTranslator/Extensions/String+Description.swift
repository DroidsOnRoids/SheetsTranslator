//
//  String+Description.swift
//  SheetsTranslator
//
//  Created by Marcin Chojnacki on 03.08.2017.
//  Copyright © 2017 Droids On Roids. All rights reserved.
//

extension String {
    
    init?<Subject>(describingOptional optionalInstance: Subject?) {
        guard let instance = optionalInstance else { return nil }
        self.init(describing: instance)
    }
}
