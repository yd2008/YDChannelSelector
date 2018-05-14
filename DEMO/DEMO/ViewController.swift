//
//  ViewController.swift
//  DEMO
//
//  Created by yudai on 2018/5/14.
//  Copyright © 2018年 TRS. All rights reserved.
//

import UIKit

class ViewController: UIViewController, YDChannelSelectorDataSource, YDChannelSelectorDelegate {
    
    // 数据源
    var selectorDataSource: [[SelectorItem]]? {
        didSet {
            selectorView.dataSource = selectorDataSource
        }
    }
    
    private lazy var selectorView: YDChannelSelector = {
        let sv = YDChannelSelector(frame: CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        sv.delegate = self
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
        view.addSubview(selectorView)
        
        // 数据源赋值 通过网络或者本地获取
        
        let mockData = [["头条","体育","数码","佛学","科技","娱乐","成都","二次元"],["独家","NBA","历史","军事","彩票","新闻学院","态度公开课","云课堂"]]
        
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
        
        selectorDataSource = selectorDataSource_t
        
        // 快捷创建
//        selectorDataSource = [["头条","体育","数码","佛学","科技","娱乐","成都","二次元"].map { SelectorItem(channelTitle: $0, isSubscribe: true, rawData: nil) }, ["独家","NBA","历史","军事","彩票","新闻学院","态度公开课","云课堂"].map { SelectorItem(channelTitle: $0, isSubscribe: false, rawData: nil) }]

    }
    
    @objc private func presentSelector() {
        guard selectorDataSource != nil else {
            print("数据源不能为空！")
            return
        }
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.selectorView.frame.origin.y = 0
        }
    }
}

// MARK: 代理方法
extension ViewController {
    
    func selector(_ selector: YDChannelSelector, didChangeDS newDataSource: [[SelectorItem]]) {
        print(newDataSource.map { $0.map { $0.channelTitle! } })
    }
    
    func selector(_ selector: YDChannelSelector, dismiss newDataSource: [[SelectorItem]]) {
        UIView.animate(withDuration: 0.3, animations: {
            selector.frame.origin.y = UIScreen.main.bounds.height
        })
    }
    
    func selector(_ selector: YDChannelSelector, didSelectChannel channelItem: SelectorItem) {
        print(channelItem.channelTitle!)
    }
    
}
