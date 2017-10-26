source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '7.0'
workspace 'POSRx'

abstract_target 'All' do
    pod 'ReactiveObjC', :git => 'https://github.com/pavelosipov/ReactiveObjC.git'

    target "POSRx" do
    end

    target "POSRxTests" do
        pod 'POSRx', :path => '.'
        pod 'POSAllocationTracker'
        pod 'OHHTTPStubs'
    end
end

