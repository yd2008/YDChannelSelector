# YDChannelSelector

[![Version](https://img.shields.io/cocoapods/v/YDChannelSelector.svg?style=flat)](https://cocoapods.org/pods/YDChannelSelector)
[![License](https://img.shields.io/cocoapods/l/YDChannelSelector.svg?style=flat)](https://cocoapods.org/pods/YDChannelSelector)
[![Platform](https://img.shields.io/cocoapods/p/YDChannelSelector.svg?style=flat)](https://cocoapods.org/pods/YDChannelSelector)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
- iOS 10.0
- Swift 4.x
- Xcode 10

## Installation

###### cocoapods
YDChannelSelector is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'YDChannelSelector'
```

###### 非cocoapods
直接拖YDChannelSelector进入项目

## Features
- [x] 界面逻辑基本1:1 还原网易新闻 扩展性强 自定义性强
- [x] 注释思路详尽 不管是自己定制还是参考思路或者直接使用都没问题
- [x] 支持cocoapods或者直接拖入项目使用
- [x] 纯净无任何依赖耦合 接口简单易用
- [x] 网易后续界面逻辑同步更新
- [x] 支持本地缓存用户操作

    <div>
        <img src="https://github.com/yd2008/YDChannelSelector/blob/master/Assets/Screen%20Shot1%20.png" width = "30%" div/>
        <img src="https://github.com/yd2008/YDChannelSelector/blob/master/Assets/Screen%20Shot2%20.png" width = "30%" div/>
    </div>

# Usage

## 初始化 
创建频道选择器只需要三个参数： 代理，是否缓存用户操作（默认缓存），数据源（网络获取到后再赋值即可）
```swift
    class ViewController: UIViewController, YDChannelSelectorDataSource, YDChannelSelectorDelegate {

    // 数据源
    var selectorDataSource: [[SelectorItem]]? {
        didSet {
            channelSelector.dataSource = selectorDataSource
        }
    }

    // 频道选择器
    private lazy var channelSelector: YDChannelSelector = {
            let sv = YDChannelSelector()
            sv.delegate = self
            // 是否支持本地缓存用户功能
            //        sv.isCacheLastest = false
            return sv
    }()
    
    .........
```

## 数据源创建
SelectorItem中有三个属性 channelTitle即为频道标题 isFixation 是否是固定栏目 rawData ** 原始数据 模型或者字典皆可 **
```swift
    // 数据源赋值 通过网络或者本地获取
    let mockData = [["头条","体育","数码","佛学","科技","娱乐","成都","二次元"],["独家","NBA","历史","军事","彩票","新闻学院","态度公开课","云课堂"]]

    var selectorDataSource_t = [[SelectorItem]]()

    for (i,channelArr) in mockData.enumerated() {
        selectorDataSource_t.append([SelectorItem]())
        for channelTitle in channelArr {
            // 头条为固定栏目
            let model = SelectorItem(channelTitle: channelTitle, isFixation: channelTitle == "头条", rawData: nil)
            // 添加进对应组
            selectorDataSource_t[i].append(model)
        }
    }

    selectorDataSource = selectorDataSource_t
```

## 代理
```swift

    // 数据源发生变化
    func selector(_ selector: YDChannelSelector, didChangeDS newDataSource: [[SelectorItem]]) {
        print(newDataSource.map { $0.map { $0.channelTitle! } })
    }

    // 用户退出操作时
    func selector(_ selector: YDChannelSelector, dismiss newDataSource: [[SelectorItem]]) {
        print(newDataSource.map { $0.map { $0.channelTitle! } })
    }

    // 用户选中新频道时
    func selector(_ selector: YDChannelSelector, didSelectChannel channelItem: SelectorItem) {
        print(channelItem.channelTitle!)
    }

```


## Author

yd2008, 332838156@qq.com

## License

YDChannelSelector is available under the MIT license. See the LICENSE file for more info.
