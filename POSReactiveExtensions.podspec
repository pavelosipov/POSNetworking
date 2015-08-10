Pod::Spec.new do |s|
  s.name         = 'POSReactiveExtensions'
  s.version      = '0.5.2'
  s.license      = 'MIT'
  s.summary      = 'Utilities around ReactiveCocoa.'
  s.homepage     = 'https://github.com/pavelosipov/POSReactiveExtensions'
  s.authors      = { 'Pavel Osipov' => 'posipov84@gmail.com' }
  s.source       = { :git => 'https://github.com/pavelosipov/POSReactiveExtensions.git', :tag => '0.5.2' }
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files = 'POSReactiveExtensions/*.{h,m}'
  s.dependency     'Aspects'
  s.dependency     'ReactiveCocoa', '< 3.0'
end
