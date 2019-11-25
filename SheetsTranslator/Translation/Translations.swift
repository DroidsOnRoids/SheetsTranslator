//
//  Translations.swift
//  SheetsTranslator
//
//  Created by Marcin Chojnacki on 02.08.2017.
//  Copyright © 2017 Droids On Roids. All rights reserved.
//

typealias Key = String
typealias Language = String

private extension Array where Element: Hashable {
    
    var unique: Array {
        return Array(Set(self))
    }
}

struct Translations: CustomStringConvertible {
    
    private var data = [Key: [Language: String]]()
    
    var description: String {
        return String(describing: data)
    }
    
    var allKeys: [Key] {
        return Array(data.keys).sorted()
    }
    
    var supportedLanguages: [Language] {
        let allLanguages = Array(data.values).flatMap { Array($0.keys) }
        
        return allLanguages.unique
    }
    
    mutating func add(_ translation: String, key: Key, language: Language) {
        if data[key] != nil {
            data[key]![language] = translation
        } else {
            data[key] = [language: translation]
        }
    }
    
    func `for`(key: Key, language: Language) -> String? {
        return data[key]?[language]
    }
}

extension Translations {
    
    private static let headerRow = 0
    private static let keyColumn = 1
    
    private static let minColumns = 3
    private static let minRows = 2
    
    private static let supportedLanguageLength = 2...5
    
    static func from(spreadsheet: Spreadsheet, tabName: String?) -> Translations? {
        let formatter = SpreadsheetFormatter(spreadsheet: spreadsheet, tabName: tabName)
        
        guard formatter.columns >= minColumns && formatter.rows >= minRows else { return nil }
        
        let languages = formatter[headerRow].enumerated().filter { index, content in
            index > keyColumn && supportedLanguageLength.contains(content.count)
        }.map { index, content in
            (column: index, language: content)
        }
        
        var translations = Translations()
        
        languages.forEach { language in
            for rowIndex in (headerRow + 1)..<formatter.rows {
                let translation = formatter[rowIndex, language.column]
                let key = formatter[rowIndex, keyColumn]
                
                guard !key.isEmpty else { continue }
                
                translations.add(translation, key: key, language: language.language)
            }
        }
        
        return translations
    }
}
