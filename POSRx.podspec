Pod::Spec.new do |s|
  s.name         = 'POSRx'
  s.version      = '0.8.8'
  s.license      = 'MIT'
  s.summary      = 'Utilities around ReactiveCocoa.'
  s.homepage     = 'https://github.com/pavelosipov/POSRx'
  s.authors      = { 'Pavel Osipov' => 'posipov84@gmail.com' }
  s.source       = { :git => 'https://github.com/pavelosipov/POSRx.git', :tag => '0.8.8' }
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files = 'POSRx/**/*.{h,m}'
  s.dependency     'Aspects'
  s.dependency     'ReactiveCocoa', '< 3.0'
end
