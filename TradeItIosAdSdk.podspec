Pod::Spec.new do |s|
  s.name             = 'TradeItIosAdSdk'
  s.version          = '0.2.3'
  s.summary          = 'TradeIt iOS Ad SDK'

  s.description      = <<-DESC
    A library that provides tools for inserting ads into your iOS apps using the TradeIt platform.
                       DESC

  s.homepage         = 'https://github.com/tradingticket/TradeItIosAdSdk'
  s.license          = { :type => 'Apache License 2.0', :file => 'LICENSE' }
  s.author           = { 'Tradeing Ticket Inc.' => 'support@trade.it' }
  s.source           = { :git => 'https://github.com/tradingticket/TradeItIosAdSdk.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'TradeItIosAdSdk/**/*.swift'

  s.resource_bundles = {
    'TradeItIosAdSdk' => ['TradeItIosAdSdk/**/*.{xib,der}']
  }

  s.frameworks = 'UIKit'
end
