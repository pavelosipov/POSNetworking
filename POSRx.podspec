Pod::Spec.new do |s|
  s.name         = 'POSRx'
  s.version      = '0.20.1'
  s.license      = 'MIT'
  s.summary      = 'Utilities around ReactiveCocoa.'
  s.homepage     = 'https://github.com/pavelosipov/POSRx'
  s.authors      = { 'Pavel Osipov' => 'posipov84@gmail.com' }
  s.source       = { :git => 'https://github.com/pavelosipov/POSRx.git', :tag => s.version }
  s.requires_arc = true
  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.9'
  s.default_subspec = 'Networking'

  s.subspec 'Testing' do |ss|
    ss.source_files = 'POSRx/Testing/**/*.{h,m}'
    ss.dependency 'POSRx/Networking'
  end

  s.subspec 'Utils' do |ss|
    ss.source_files = 'POSRx/Utils/**/*.{h,m}'
  end

  s.subspec 'Scheduling' do |ss|
    ss.source_files = 'POSRx/Scheduling/**/*.{h,m}'
    ss.dependency 'POSRx/Utils'
    ss.dependency 'Aspects'
    ss.dependency 'ReactiveObjC'
  end

  s.subspec 'Networking' do |ss|
    ss.source_files = ['POSRx/Networking/**/*.{h,m}', 'POSRx/POSRx.h']
    ss.dependency 'POSRx/Scheduling'
  end

end
