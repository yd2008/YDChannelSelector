
Pod::Spec.new do |spec|

  spec.name         = "YDChannelSelector"
  spec.version      = "1.3.0"
  spec.summary      = "一款精仿网易新闻频道选择器组件"

  spec.description  = "一款精仿网易新闻频道选择器组件. 界面样式细节基本达到 1：1 使用简单 维护容易 扩展性强"
                   

  spec.homepage     = "https://github.com/yd2008/YDChannelSelector"

  spec.license      = "MIT"

  spec.author             = { "yudai" => "332838156@qq.com" }
  
  spec.platform     = :ios, "10.0"

  spec.source       = { :git => "https://github.com/yd2008/YDChannelSelector.git", :tag => "#{spec.version}" }

  spec.source_files  = "YDChannelSelector", "YDChannelSelector/*.swift"

  spec.resource_bundles = {
    'YDChannelSelector' => ['YDChannelSelector/Assets/*.png']
  }

  spec.framework  = "UIKit"
  spec.requires_arc  = true
  spec.swift_version = "4.2"


end
