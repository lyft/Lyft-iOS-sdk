Pod::Spec.new do |s|
  s.name            = 'LyftSDK'
  s.version         = '1.0.3'
  s.summary         = 'The official Lyft iOS SDK.'
  s.homepage        = 'https://github.com/lyft/lyft-iOS-sdk'
  s.license         = { :type => 'Apache', :file => 'LICENSE' }
  s.author          = { 'Gilad Gurantz' => 'gilad@lyft.com' }
  s.source          = { :git => 'https://github.com/lyft/lyft-iOS-sdk.git', :tag => s.version.to_s }
  s.default_subspec = 'Core'
  s.ios.deployment_target = '8.0'

  s.subspec 'Core' do |core|
    core.source_files    = 'Sources/**/*.swift'
    core.resources       = ['Sources/LyftUI/Resources/**']
  end

  s.subspec 'API' do |api|
    api.source_files = 'Sources/{LyftAPI,LyftModels}/**/*.swift'
  end
end
