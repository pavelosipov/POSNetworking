source 'https://cdn.cocoapods.org/'

platform :ios, '8.0'
workspace 'POSNetworking'

abstract_target 'All' do
    pod 'Aspects', :inhibit_warnings => true
    pod 'ReactiveObjC', :inhibit_warnings => true
    pod 'POSErrorHandling', :git => 'https://github.com/pavelosipov/POSErrorHandling.git'
    pod 'POSScheduling', :git => 'https://github.com/pavelosipov/POSScheduling.git'
    target 'POSNetworking'
    target 'POSNetworkingTests' do
        pod 'POSNetworking', :path => '.'
        pod 'POSAllocationTracker'
        pod 'OHHTTPStubs'
    end
end
