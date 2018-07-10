//
//  Spreadsheet.swift
//  SheetsTranslator
//
//  Created by Marcin Chojnacki on 03.08.2017.
//  Copyright © 2017 Droids On Roids. All rights reserved.
//

import Foundation

struct ExtendedValue: CustomStringConvertible {
    
    let numberValue: Int?
    let stringValue: String?
    let boolValue: Bool?
    let formulaValue: String?
    
    init(json: [String: Any]) {
        self.numberValue = json["numberValue"] as? Int
        self.stringValue = json["stringValue"] as? String
        self.boolValue = json["boolValue"] as? Bool
        self.formulaValue = json["formulaValue"] as? String
    }
    
    var description: String {
        return String(describingOptional: numberValue) ??
            String(describingOptional: stringValue) ??
            String(describingOptional: boolValue) ??
            String(describingOptional: formulaValue) ?? ""
    }
}

struct CellData: CustomStringConvertible {
    
    let userEnteredValue: ExtendedValue?
    let effectiveValue: ExtendedValue?
    
    init?(json: [String: Any]) {
        if let userEnteredValue = json["userEnteredValue"] as? [String: Any] {
            self.userEnteredValue = ExtendedValue(json: userEnteredValue)
        } else {
            self.userEnteredValue = nil
        }
        
        if let effectiveValue = json["effectiveValue"] as? [String: Any] {
            self.effectiveValue = ExtendedValue(json: effectiveValue)
        } else {
            self.effectiveValue = nil
        }
    }
    
    var description: String {
        return String(describingOptional: effectiveValue) ?? ""
    }
}

struct RowData {
    
    let values: [CellData]
    
    init?(json: [String: Any]) {
        guard let values = json["values"] as? [[String: Any]] else { return nil }
        self.values = values.compactMap { CellData(json: $0) }
    }
}

struct GridData {
    
    let startRow: Int?
    let startColumn: Int?
    let rowData: [RowData]
    
    init?(json: [String: Any]) {
        guard let rowData = json["rowData"] as? [[String: Any]] else { return nil }
        
        self.startRow = json["startRow"] as? Int
        self.startColumn = json["startColumn"] as? Int
        self.rowData = rowData.compactMap { RowData(json: $0) }
    }
}

struct Sheet {
    
    let data: [GridData]
    
    init?(json: [String: Any]) {
        guard let data = json["data"] as? [[String: Any]] else { return nil }
        self.data = data.compactMap { GridData(json: $0) }
    }
}

struct Spreadsheet {
    
    let spreadsheetId: String
    let sheets: [Sheet]
    let spreadsheetUrl: String
    
    init?(json: [String: Any]) {
        guard let spreadsheetId = json["spreadsheetId"] as? String,
            let sheets = json["sheets"] as? [[String: Any]],
            let spreadsheetUrl = json["spreadsheetUrl"] as? String else { return nil }
        
        self.spreadsheetId = spreadsheetId
        self.sheets = sheets.compactMap { Sheet(json: $0) }
        self.spreadsheetUrl = spreadsheetUrl
    }
}
