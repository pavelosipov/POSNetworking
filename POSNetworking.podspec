Pod::Spec.new do |s|
  s.name         = 'POSNetworking'
  s.version      = '3.0.1'
  s.license      = 'MIT'
  s.summary      = 'Reactive network components which are made in compliance with Schedulable Architecture design pattern.'
  s.homepage     = 'https://github.com/pavelosipov/POSNetworking'
  s.authors      = { 'Pavel Osipov' => 'posipov84@gmail.com' }
  s.source       = { :git => 'https://github.com/pavelosipov/POSNetworking.git', :tag => s.version }
  s.requires_arc = true
  s.ios.deployment_target = '8.0'
  s.default_subspec = 'Networking'
  s.resource_bundle = { 'POSNetworking-Resources' => ['Resources/*.lproj'] }
  s.preserve_paths = 'Resources'

  s.subspec 'Networking' do |ss|
    ss.source_files = 'Classes/Networking/**/*.{h,m}'
    ss.dependency 'POSScheduling'
    ss.dependency 'ReactiveObjC'
    ss.dependency 'POSErrorHandling'
  end

  s.subspec 'Testing' do |ss|
    ss.source_files = 'Classes/Testing/**/*.{h,m}'
    ss.dependency 'POSNetworking/Networking'
  end
end
