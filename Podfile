# Uncomment the next line to define a global platform for your project
# platform :ios, '13.0'

target 'SocialMediaApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for SocialMediaApp
  pod 'IQKeyboardManagerSwift'
  pod 'Firebase'
  pod 'Firebase/Auth'
  pod 'Firebase/Messaging'
  pod 'Firebase/Storage'
  pod 'Firebase/Database'
  pod 'FirebaseFirestoreSwift', '~> 10.2.0'
  
  pod 'CodableFirebase'
  pod 'NVActivityIndicatorView'
  pod 'SDWebImage'
  pod 'CropViewController'
  pod 'VBRRollingPit'
  pod 'BetterSegmentedControl'
  pod 'CHTCollectionViewWaterfallLayout'
#  pod 'FYPhoto'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end

    if target.name == 'BoringSSL-GRPC'
      target.source_build_phase.files.each do |file|
        if file.settings && file.settings['COMPILER_FLAGS']
          flags = file.settings['COMPILER_FLAGS'].split
          flags.reject! { |flag| flag == '-GCC_WARN_INHIBIT_ALL_WARNINGS' }
          file.settings['COMPILER_FLAGS'] = flags.join(' ')
        end
      end
    end
  end
end
