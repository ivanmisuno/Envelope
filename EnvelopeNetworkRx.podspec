Pod::Spec.new do |s|
  s.name             = "EnvelopeNetworkRx"
  s.version          = "0.0.1"
  s.summary          = "RxSwift extensions over EnvelopeNetwork"
  s.description      = <<-DESC
  EnvelopeNetworkRx contains a set of RxSwift extensions over EnvelopeNetwork abstraction layer.
                        DESC
  s.homepage         = "https://github.com/ivanmisuno/Envelope"
  s.license          = 'MIT'
  s.author           = { "Ivan Misuno" => "i.misuno@gmail.com" }
  s.source           = { :git => "https://github.com/ivanmisuno/Envelope.git", :tag => s.version.to_s }

  s.requires_arc          = true

  s.ios.deployment_target = '8.0'

  s.source_files          = 'EnvelopeNetworkRx/**/*.swift'

  s.dependency 'EnvelopeNetwork', '~> 0.0.1'
  s.dependency 'RxSwift', '~> 4.0'

end
