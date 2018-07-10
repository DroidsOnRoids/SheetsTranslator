#!/bin/sh
set -e
rm -rf build
xcodebuild -project SheetsTranslator.xcodeproj
ln -s SheetsTranslator build/Release/sheets
zip -j sheetstranslator.zip build/Release/sheets LICENSE