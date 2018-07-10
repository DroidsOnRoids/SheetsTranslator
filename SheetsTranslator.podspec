Pod::Spec.new do |s|
  s.name           = 'SheetsTranslator'
  s.version        = '0.1'
  s.summary        = 'App translation generator using Google Sheets API'
  s.homepage       = 'https://github.com/DroidsOnRoids/SheetsTranslator'
  s.license        = { :type => 'MIT', :file => 'LICENSE' }
  s.author         = { 'Marcin Chojnacki' => 'marcin.chojnacki@droidsonroids.pl' }
  s.source         = { :http => "#{s.homepage}/releases/download/#{s.version}/sheetstranslator.zip" }
  s.preserve_paths = '*'
  s.exclude_files  = '**/file.zip'
end
