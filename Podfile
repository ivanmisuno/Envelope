source 'https://github.com/CocoaPods/Specs.git'

abstract_target 'Envelope_Framework' do

  target 'EnvelopeNetwork-ios' do
    platform :ios, '8.0'
    use_frameworks!
    inhibit_all_warnings!

    pod 'Alamofire'

    target 'AllTests-ios' do
      inherit! :search_paths

      pod 'RxSwift'
      pod 'RxTest'
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
  end

  target 'EnvelopeTests-ios' do
    platform :ios, '8.0'
    use_frameworks!
    inhibit_all_warnings!

    pod 'Alamofire'
    pod 'RxSwift'
    pod 'RxTest'
    pod 'Quick'
    pod 'Nimble'
  end
end
