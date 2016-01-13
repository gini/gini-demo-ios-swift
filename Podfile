source 'https://github.com/gini/gini-podspecs.git'
source 'https://github.com/CocoaPods/Specs.git'

# Uncomment this line to define a global platform for your project
platform :ios, '8.0'
# Uncomment this line if you're using Swift
use_frameworks!

target 'gini-swift-demo-ios' do
    pod 'GiniVisionSDK'
    pod 'Gini-iOS-SDK'
end

target 'gini-swift-demo-iosTests' do

end

target 'gini-swift-demo-iosUITests' do

end

post_install do | installer |
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-gini-swift-demo-ios/Pods-gini-swift-demo-ios-acknowledgements.plist', 'gini-swift-demo-ios/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end