Pod::Spec.new do |s|
  s.name         = "TenzingCore"
  s.version      = "0.1.0"
  s.summary      = "Some utilities for iOS."

  s.description  = <<-DESC
                   TenzingCore
                   ===========

                   Some utilities for iOS. See [Wiki](https://github.com/endSly/TenzingCore/wiki) for more info. 
                   DESC

  s.homepage     = "http://endika.net"

  s.license      = 'MIT (example)'
  s.author       = { "Endika Gutiérrez Salas" => "me@endika.net" }
  s.platform     = :ios
  s.source       = { :git => "https://github.com/endSly/TenzingCore.git", :tag => "0.1.0" }
  s.source_files  = 'TenzingCore', 'TenzingCore/**/*.{h,m}', 'TenzingCore-RESTService', 'TenzingCore-RESTService/**/*.{h,m}'
  s.requires_arc = true
end
