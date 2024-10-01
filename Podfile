# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'hdgeoguess' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'GoogleMaps', '7.3.0'
  pod 'MKRingProgressView', '2.3.0'
  pod 'UICountingLabel', '1.4.1'
  pod 'Kingfisher', '7.6.2'
  pod 'Toast-Swift', '5.0.1'
  pod 'SVProgressHUD', '2.2.5'
  pod 'SwiftyStoreKit', '0.16.1'
  pod 'ProgressHUD', '2.70'
  pod 'FirebaseAnalytics'
  pod 'FirebaseAuth'
  pod 'FirebaseFirestore'

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
        config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      end
    end
  end
  
end
