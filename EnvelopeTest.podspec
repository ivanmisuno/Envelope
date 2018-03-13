Pod::Spec.new do |s|
  s.name             = "EnvelopeTest"
  s.version          = "0.0.1"
  s.summary          = "Envelope Testing extensions"
  s.description      = <<-DESC
EnvelopeTest contains a set of shared classes to aim writing unit tests for projects using Envelope frameworks.
                        DESC
  s.homepage         = "https://github.com/ivanmisuno/Envelope"
  s.license          = 'MIT'
  s.author           = { "Ivan Misuno" => "i.misuno@gmail.com" }
  s.source           = { :git => "https://github.com/ivanmisuno/Envelope.git", :tag => s.version.to_s }

  s.requires_arc          = true

  s.ios.deployment_target = '8.0'

  s.source_files          = 'EnvelopeTest/**/*.swift'

  s.framework              = 'XCTest'

  s.dependency 'EnvelopeNetwork', '~> 0.0.1'
  s.dependency 'EnvelopeNetworkRx', '~> 0.0.1'
  s.dependency 'Quick', '~> 1.2'
  s.dependency 'Nimble', '~> 7.0'
  s.dependency 'RxSwift', '~> 4.0'
  s.dependency 'RxTest', '~> 4.0'

  s.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO' }
end
