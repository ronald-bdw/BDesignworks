platform :ios, '9.1'
source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

abstract_target 'Abstract' do
    
    # Database
    pod 'Realm'
    pod 'RealmSwift'
    
    # Helpers
    pod 'FSHelpers+Swift', :git => 'https://github.com/fs/FSHelper.git', :branch => 'master'
    pod 'XCGLogger', :git => 'https://github.com/DaveWoodCom/XCGLogger.git', :branch => 'swift_3.0'
    
    # Analytics
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'Heap'
    pod 'Flurry-iOS-SDK/FlurrySDK'
    
    # Libraries
    pod 'Alamofire'
    pod 'ObjectMapper'
    pod 'SDWebImage'
    pod 'SVProgressHUD'
    pod 'Smooch', '= 5.1.0'
    pod 'SWRevealViewController'
    
    #secure
    pod 'SAMKeychain'
    
    #TARGETS
    target 'BDesignworks' do
    end
    
    target 'BDesignworksTests' do
        pod 'Nocilla'
    end
    
    target 'BDesignworksUITests' do
    end
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end

# Helpers
#pod 'SDWebImage'
#pod 'NSDate-Extensions'
#pod 'Reachability'
#pod 'SVProgressHUD'
#pod 'SSKeychain'
#pod 'MKStoreKit'
