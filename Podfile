source 'https://github.com/CocoaPods/Specs.git'

abstract_target 'Envelope_Framework' do

  target 'Envelope-ios' do
    platform :ios, '8.0'
    use_frameworks!
    inhibit_all_warnings!

    pod 'Alamofire'

    target 'Envelope-ios-tests' do
      inherit! :search_paths
      pod 'Quick'
      pod 'Nimble'
    end
  end
end
