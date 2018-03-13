Pod::Spec.new do |s|
  s.name             = "EnvelopeNetwork"
  s.version          = "0.0.1"
  s.summary          = "Swift protocol-based networking abstractions."
  s.description      = <<-DESC
  EnvelopeNetwork is a Swift protocol-based abstraction layer over Alamofire SessionManager.
                        DESC
  s.homepage         = "https://github.com/ivanmisuno/Envelope"
  s.license          = 'MIT'
  s.author           = { "Ivan Misuno" => "i.misuno@gmail.com" }
  s.source           = { :git => "https://github.com/ivanmisuno/Envelope.git", :tag => s.version.to_s }

  s.requires_arc          = true

  s.ios.deployment_target = '8.0'

  s.source_files          = 'EnvelopeNetwork/**/*.swift'

  s.dependency 'Alamofire', '~> 4.5'

end
