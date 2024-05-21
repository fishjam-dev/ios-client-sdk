#
# Be sure to run `pod lib lint MembraneRTC.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FishjamClient'
  s.version          = '0.3.0'
  s.summary          = 'Fishjam SDK fully compatible with `Membrane RTC Engine` for iOS.'

  s.homepage         = 'https://github.com/fishjam-dev/ios-client-sdk'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'Apache-2.0 license', :file => 'LICENSE' }
  s.author           = { 'Software Mansion' => 'https://swmansion.com' }
  s.source           = { :git => 'https://github.com/fishjam-dev/ios-client-sdk.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'

  s.source_files = 'Sources/**/*'

  s.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO' }
  
  s.dependency 'WebRTC-SDK', '114.5735.08'
  s.dependency 'SwiftProtobuf', '~> 1.18.0'
  s.dependency 'Starscream', '~> 4.0.0'
  s.dependency 'MockingbirdFramework', '0.20.0'
  s.dependency 'PromisesSwift'
  s.dependency 'SwiftPhoenixClient', '~> 5.0.0'
  s.dependency 'SwiftLogJellyfish', '1.5.2'

  s.subspec "Broadcast" do |spec|
    spec.source_files = "Sources/MembraneRTC/Media/BroadcastSampleSource.swift", "Sources/MembraneRTC/IPC/**/*.{h,m,mm,swift}"
  end
end