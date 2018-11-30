//
//  ViewController.swift
//  YDChannelSelectorDemo
//
//  Created by yudai on 2018/11/22.
//  Copyright © 2018 yudai. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let mockDataSource = [["头条","体育","数码","佛学","科技","娱乐","成都","二次元"],["独家","NBA","历史","军事","彩票","新闻学院","态度公开课","云课堂"]]
   
    private lazy var channelSelector: YDChannelSelector = {
        let cv = YDChannelSelector()
        cv.dataSource = self
        cv.delegate = self
        // 是否支持本地缓存用户功能 默认支持
//        cv.isCacheLastest = false
        return cv
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
    }
    
    @objc private func presentSelector() {
//        guard selectorDataSource != nil && selectorDataSource?.count != 0 else {
//            print("DataSources can not be empty!")
//            return
//        }
//        present(channelSelector, animated: true, completion: nil)
        channelSelector.show()
    }
    
}

// MARK: 数据源方法
extension ViewController: YDChannelSelectorDataSource {
    
    func numberOfSections(in selector: YDChannelSelector) -> Int {
        return mockDataSource.count
    }
    
    func selector(_ selector: YDChannelSelector, numberOfItemsInSection section: Int) -> Int {
        return mockDataSource[section].count
    }
    
    func selector(_ selector: YDChannelSelector, itemAt indexPath: IndexPath) -> SelectorItem {
        let title = mockDataSource[indexPath.section][indexPath.row]
        // 默认头条为固定栏目
        let selectorItem = SelectorItem(channelTitle: title, isFixation: title == "头条", rawData: nil)
        return selectorItem
    }
    
}

// MARK: 代理方法
extension ViewController: YDChannelSelectorDelegate {
    
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

