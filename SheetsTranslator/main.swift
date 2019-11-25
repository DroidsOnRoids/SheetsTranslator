//
//  main.swift
//  SheetsTranslator
//
//  Created by Marcin Chojnacki on 14.07.2017.
//  Copyright © 2017 Droids On Roids. All rights reserved.
//

import Foundation

private let sheetArgument =
    CommandStringArgument(shortFlag: "s",
                          longFlag: "sheet",
                          required: true,
                          usage: "Spreadsheet ID (required)")

private let credentialsArgument =
    CommandStringArgument(shortFlag: "c",
                          longFlag: "credentials",
                          required: true,
                          usage: "Credentials path (required)")

private let outputArgument =
    CommandStringArgument(shortFlag: "o",
                          longFlag: "output",
                          required: false,
                          usage: "Output translation path (or current directory if not provided)")

private let tabNameArgument =
CommandStringArgument(shortFlag: "t",
                      longFlag: "tab",
                      required: false,
                      usage: "Sheet tab name(or first one if not provided)")

CommandLineTool.shared.parser.add(arguments: sheetArgument, tabNameArgument, credentialsArgument, outputArgument)
CommandLineTool.shared.parseOrExit()

private let credentialsPath = credentialsArgument.value ?? CommandLineTool.shared.programPath + "credentials.json"
private let outputPath = outputArgument.value ?? "."

private func warningAndExit(_ message: String) {
    print("warning: Translation failed - \(message)")
    CommandLineTool.shared.complete()
}

private func parseResult(_ result: APIResult<[String: Any]>) {
    switch result {
    case .success(let json):        
        guard let sheet = Spreadsheet(json: json) else {
            warningAndExit("Failed to parse sheet")
            return
        }
        
        guard let translation = Translations.from(spreadsheet: sheet, tabName: tabNameArgument.value) else {
            warningAndExit("Failed to parse translations")
            return
        }
        
        do {
            try LocalizableGenerator(localizer: iOSLocalizer(),
                                     translations: translation).saveLocalizations(to: outputPath)
        } catch let error {
            warningAndExit(error.localizedDescription)
        }
    case .failure(let error):
        let errorSuffix = (error?.localizedDescription).map { " (\($0))" } ?? ""
        warningAndExit("Networking error" + errorSuffix)
    }
}

do {
    let credentials = try OAuthCredentials(fromFilePath: credentialsPath)
    let jwt = try JSONWebToken(credentials: credentials, scope: .spreadsheetsReadOnly)
    let apiClient = GoogleAPIService()
    
    apiClient.refreshToken(jwt: jwt) { _ in
        apiClient.authorizedRequest(GoogleAPIRouter.spreadsheetsGet(sheetArgument.value!, true)) { result in
            parseResult(result)
            CommandLineTool.shared.complete()
        }
    }
} catch let error {
    warningAndExit(error.localizedDescription)
}

CommandLineTool.shared.waitForCompletion()
