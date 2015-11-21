Pod::Spec.new do |s|
  s.name             = "QRCodeKit"
  s.version          = "0.1.0"
  s.summary          = "QRCodeKit is a library for capturing and generating QR code in Swift."
  s.description      = <<-DESC
                         QRCodeKit is a library for capturing and generating QR code in Swift.
                       DESC

  s.homepage         = "https://github.com/hokuron/QRCodeKit"
  s.license          = 'MIT'
  s.author           = { "Takuma Shimizu" => "anti.soft.b@gmail.com" }
  s.source           = { :git => "https://github.com/hokuron/QRCodeKit.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/hokuron'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Lib/QRCodeKit/*.swift'
end
