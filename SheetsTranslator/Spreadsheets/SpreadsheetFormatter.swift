//
//  SpreadsheetFormatter.swift
//  SheetsTranslator
//
//  Created by Marcin Chojnacki on 03.08.2017.
//  Copyright © 2017 Droids On Roids. All rights reserved.
//

struct SpreadsheetFormatter: CustomStringConvertible {
    
    let spreadsheet: Spreadsheet
    let tabName: String?
    
    var rows: Int {
        return rowData?.count ?? 0
    }
    
    var columns: Int {
        guard let rowData = rowData else { return 0 }
        return rowData.map { $0.values.count }.max() ?? 0
    }
    
    var description: String {
        guard let rowData = rowData else { return "" }
        return String(describing: rowData.map { $0.values })
    }
    
    subscript(row: Int) -> [String] {
        return rowData?[safe: row]?.values.map { $0.description } ?? []
    }
    
    subscript(row: Int, column: Int) -> String {
        return rowData?[safe: row]?.values[safe: column]?.description ?? ""
    }
    
    private var rowData: [RowData]? {
        let sheet = spreadsheet.sheets.first { $0.name == tabName } ?? spreadsheet.sheets.first
        return sheet?.data.first?.rowData
    }
}
