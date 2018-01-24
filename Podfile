source 'https://github.com/CocoaPods/Specs.git'

abstract_target 'Envelope_Framework' do

  target 'EnvelopeNetwork-ios' do
    platform :ios, '8.0'
    use_frameworks!
    inhibit_all_warnings!

    pod 'Alamofire'

    target 'EnvelopeNetwork-ios-tests' do
      inherit! :search_paths
      pod 'Quick'
      pod 'Nimble'
    end
  end

  target 'EnvelopeNetworkRx-ios' do
    platform :ios, '8.0'
    use_frameworks!
    inhibit_all_warnings!

    pod 'Alamofire'
    pod 'RxSwift'

    target 'EnvelopeNetworkRx-ios-tests' do
      inherit! :search_paths
      pod 'Quick'
      pod 'Nimble'
      pod 'RxTest'
    end
  end
end
