//
//  ViewController.swift
//  YDChannelSelectorDemo
//
//  Created by yudai on 2018/11/22.
//  Copyright © 2018 yudai. All rights reserved.
//

import UIKit

class ViewController: UIViewController, YDChannelSelectorDataSource, YDChannelSelectorDelegate {
    
    // 数据源
    var selectorDataSource: [[SelectorItem]]? {
        didSet {
            channelSelector.dataSource = selectorDataSource
        }
    }
    
    private lazy var channelSelector: YDChannelSelector = {
        let sv = YDChannelSelector()
        sv.delegate = self
        // 是否支持本地缓存用户功能
        //        sv.isCacheLastest = false
        return sv
    }()
    
    private lazy var showBtn: UIButton = {
        let sb = UIButton()
        sb.setTitle("弹出", for: .normal)
        sb.sizeToFit()
        sb.center = view.center
        sb.addTarget(self, action: #selector(presentSelector), for: .touchUpInside)
        sb.setTitleColor(UIColor.red, for: .normal)
        return sb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(showBtn)
        
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
        
    }
    
    @objc private func presentSelector() {
        guard selectorDataSource != nil && selectorDataSource?.count != 0 else {
            print("DataSources can not be empty!")
            return
        }
        present(channelSelector, animated: true, completion: nil)
    }
    
}

// MARK: 代理方法
extension ViewController {
    
    func selector(_ selector: YDChannelSelector, didChangeDS newDataSource: [[SelectorItem]]) {
        print(newDataSource.map { $0.map { $0.channelTitle! } })
    }
    
    func selector(_ selector: YDChannelSelector, dismiss newDataSource: [[SelectorItem]]) {
        print(newDataSource.map { $0.map { $0.channelTitle! } })
    }
    
    func selector(_ selector: YDChannelSelector, didSelectChannel channelItem: SelectorItem) {
        print(channelItem.channelTitle!)
    }
    
}

