//
//  LocalizableGenerator.swift
//  SheetsTranslator
//
//  Created by Marcin Chojnacki on 02.08.2017.
//  Copyright © 2017 Droids On Roids. All rights reserved.
//

import Foundation

typealias FilePath = String
typealias FileContent = String

protocol Localizer {
    func localize(translations: Translations) -> [FilePath: FileContent]
}

private extension FileContent {
    
    func writeRecursively(to url: URL, encoding: String.Encoding) throws {
        let fileManager = FileManager.default
        let baseURL = url.deletingLastPathComponent()
        
        try fileManager.createDirectory(at: baseURL, withIntermediateDirectories: true)
        try write(to: url, atomically: false, encoding: encoding)
    }
}

struct LocalizableGenerator {
    
    let localizer: Localizer
    let translations: Translations
    
    func saveLocalizations(to directory: String) throws {
        let pathContentMap = localizer.localize(translations: translations)
        
        try pathContentMap.forEach { path, content in
            let dirURL = URL(fileURLWithPath: directory)
            let url = dirURL.appendingPathComponent(path)
            try content.writeRecursively(to: url, encoding: .utf8)
        }
    }
}
