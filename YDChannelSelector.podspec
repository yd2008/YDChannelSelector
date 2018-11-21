#
# Be sure to run `pod lib lint YDChannelSelector.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    
  s.name             = 'YDChannelSelector'
  s.version          = '1.2.0'
  s.summary          = '一款精仿网易新闻频道选择器组件'
  
  s.description      = '一款精仿网易新闻频道选择器组件.'

  s.homepage         = 'https://github.com/yd2008/YDChannelSelector'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yd2008' => '332838156@qq.com' }
  s.source           = { :git => 'https://github.com/yd2008/YDChannelSelector.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'YDChannelSelector/Classes/**/*'
  
  s.resource_bundles = {
    'YDChannelSelector' => ['YDChannelSelector/Assets/*.png']
  }
  
end
