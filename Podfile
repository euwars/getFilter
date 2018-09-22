# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'
inhibit_all_warnings!

pod 'SQLite.swift', '~> 0.11.5'
pod 'Moya', '~> 11.0.2'
pod 'PromiseKit', '~> 6.3.4'
pod 'CryptoSwift', '~> 0.10.0'
pod 'Zephyr', '~> 3.1.2'
pod 'PhoneNumberKit', '~> 2.1.0'
pod 'OneSignal', '~> 2.8.5'
pod 'KeyboardWrapper', '~> 4.0.0'

target 'Block' do
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!
    
    # Pods for Block
    
end

target 'filter' do
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!
    
    # Pods for filter
    
end

target 'getFilter' do
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!
    
    # Pods for getFilter
    
end

target 'Unwanted' do
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!
    
    # Pods for Unwanted
    
end


post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == 'KeyboardWrapper' ||  target.name == 'QRCodeReader.swift'
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.0'
            end
        end
    end
end
