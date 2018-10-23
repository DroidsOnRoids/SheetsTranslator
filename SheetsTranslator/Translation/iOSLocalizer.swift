//
//  iOSLocalizer.swift
//  SheetsTranslator
//
//  Created by Marcin Chojnacki on 02.08.2017.
//  Copyright © 2017 Droids On Roids. All rights reserved.
//

import Foundation

private extension Dictionary {
    
    init(elements: [(Key, Value)]) {
        self.init()
        
        for (key, value) in elements {
            updateValue(value, forKey: key)
        }
    }
}

struct iOSLocalizer: Localizer {
    
    func localize(translations: Translations) -> [FilePath: FileContent] {
        return Dictionary(elements: translations.supportedLanguages.map { language in
            let path = "\(language).lproj/Localizable.strings"
            let content = contentFor(language: language, translations: translations)
            
            return (path, content)
        })
    }
    
    private func contentFor(language: Language, translations: Translations) -> FileContent {
        let entryList = translations.allKeys.map { key -> String in
            guard let translation = translations.for(key: key, language: language) else { return "" }
            
            let fixedTranslation = translation
                .replacingOccurrences(of: "\n", with: "\\n")
                .replacingOccurrences(of: "\"", with: "\\\"")
            
            return "\"\(key)\" = \"\(fixedTranslation)\";"
        }
        
        return entryList.filter { !$0.isEmpty }.joined(separator: "\n")
    }
}
