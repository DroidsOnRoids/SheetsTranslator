# SheetsTranslator

A tool to generate app translation (Localizable.strings, etc.) using Google Sheets API.

* It makes use of the official Google Sheets API
* It uses Google Service Account to give and revoke permissions
* It is super safe, using private/public key cryptography
* It is more integrated with Xcode and shows warnings during build
* It is centralized and possible to update with CocoaPods
* It's written in Swift :)

![Warnings](http://i.imgur.com/TOKT4G3.png)

## How to use it?

### Google Sheets integration
1. Create a new Google Sheet according to previously used template, it is:

.      |name/key      |en    |pl     |...
-------|--------------|------|-------|---
GENERAL|GENERAL_LOGOUT|Logout|Wyloguj|...
...    |...           |...   |...    |...

Check out sample translation sheet [here](https://docs.google.com/spreadsheets/d/1HZwNTyo2XRkADjNLvXlMMlZ_buzCNYxhjIzvwL6mid8/)

2. Click on **Share** button, and open **Advanced** panel
3. Invite **<your account>translator@sheetstranslator.iam.gserviceaccount.com** with **view** permissions
4. Copy spreadsheet ID

Now SheetsTranslator has an access to this sheet and is ready to use it!

### Project integration
1. Add this line to your Podfile and run **pod install**
```
pod 'SheetsTranslator'
```
2. Add this script as a build phase to your project
```
"${PODS_ROOT}/SheetsTranslator/sheets" -s <your sheet ID> -c <your credentials path> -o <your app directory>/Resources
```
##### Flags
 * ``-s, --sheet`` - Spreadsheet ID (required)
 * ``-c, --credentials`` - Credentials path (required)
 * ``-o, --output`` - Output translation path (or current directory if not provided)
 * ``-t, --tab`` - Sheet tab name(or first one if not provided
3. Replace your sheet ID and output directory
4. Build the project

![Build phase](http://i.imgur.com/GmvpJw0.png)

## Third-party code
This project uses code from third-party libraries licensed under MIT licence.
* SwiftyRSA by Scoop - Encryption/ASN1Parser.swift
* Guardian.swift by Auth0 - Extensions/Data+Base64URL.swift

### Enjoy!
