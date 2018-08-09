# YDChannelSelector
### **界面逻辑动态效果基本照搬网易新闻35.1（7及以后机型有震动回馈效果）**
### **无任何第三方依赖**
### **支持本地缓存用户操作**
### **创建使用简单(三步实现网易效果)**

## 效果展示
![动图](https://github.com/yd2008/YDChannelSelector/blob/master/GifPic.gif?raw=true)

## 创建
```
// 遵守协议和数据源代理
class ViewController: UIViewController, YDChannelSelectorDataSource, YDChannelSelectorDelegate

    // 设置数据源
    var selectorDataSource: [[SelectorItem]]? {
        didSet {
            selectorView.dataSource = selectorDataSource
        }
    }

    // bounds是屏幕大小即可
    private lazy var channelSelector: YDChannelSelector = {
        let cs = YDChannelSelector()
        cs.delegate = self
        return cs
    }()
```

## 弹出(直接用系统方法present即可)
```
    @objc private func presentSelector() {
        guard selectorDataSource != nil && selectorDataSource?.count != 0 else {
            print("DataSources can not be empty!")
            return
        }
        // 弹出频道选择器
        present(channelSelector, animated: true, completion: nil)
    }
```

#### SelectorItem (三个属性)
```
    /// 频道名称
    var channelTitle: String!
    /// 是否订阅
    var isSubscribe: Bool!
    /// 频道对应初始字典或模型
    var rawData: Any?
```

## 数据源传值
```

        // 数据源赋值 通过网络或者本地获取
        
        let mockData = [["头条","体育","数码","佛学","科技","娱乐","成都","二次元"],["独家","NBA","历史","军事","彩票","新闻学院","态度 公开课","云课堂"]]
        
        // 临时数组
        var selectorDataSource_t = [[SelectorItem]]()
        
        for (i,channelArr) in mockData.enumerated() {
            selectorDataSource_t.append([SelectorItem]())
            for channelTitle in channelArr {
                if channelTitle == "头条" { // 头条为固定栏目
                    let model = SelectorItem(channelTitle: channelTitle, isSubscribe: true, rawData: nil)
                    selectorDataSource_t[i].append(model)
                } else {
                    let model = SelectorItem(channelTitle: channelTitle, isSubscribe: false, rawData: nil)
                    selectorDataSource_t[i].append(model)
                }
            }
         }

        // 数据源属性赋值
        selectorDataSource = selectorDataSource_t
```

## 代理方法
```
    // 数据源发生变化时调用 (排序 增加 删除)
    func selector(_ selector: YDChannelSelector, didChangeDS newDataSource: [[SelectorItem]]) {
        print(newDataSource.map { $0.map { $0.channelTitle! } })
    }
    
    // 退下按钮点击时调用
    func selector(_ selector: YDChannelSelector, dismiss newDataSource: [[SelectorItem]]) {
       print(newDataSource.map { $0.map { $0.channelTitle! } })
    }
    
    // 选择了我的栏目中频道时调用 (点最近删除或更多栏目不会调)
    func selector(_ selector: YDChannelSelector, didSelectChannel channelItem: SelectorItem) {
        print(channelItem.channelTitle!)
    }
```

## 后续增添功能
### 网易如果有新效果或逻辑会陆续跟新
### oc版本支持
### 更多接口开放，提高自定义性
### 支持cocoapods  

如果有任何问题或者其他好的建议欢迎提出，大家共同交流进步！
## 如果觉得还不错的请star，谢谢！
