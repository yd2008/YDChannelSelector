//
//  YDChannelSelectorHeader.swift
//  YDChannelSelectorViewDemo
//
//  Created by yudai on 2018/3/12.
//  Copyright © 2018年 TRS. All rights reserved.
//

import UIKit

let YDChannelSelectorHeaderID = "YDChannelSelectorHeaderID"
/// header内部间距
fileprivate let headerMargin: CGFloat = 10

class YDChannelSelectorHeader: UICollectionReusableView {
    
    open var isHiddenEdit: Bool = true {
        didSet{
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    open var isEdit: Bool = false {
        didSet{
            editBtn.isSelected = isEdit
        }
    }
    
    open var title: String? {
        didSet{
            titleLabel.text = title
        }
    }
    
    open var tips: String? {
        didSet{
            tipsLabel.text = tips
        }
    }
    
    open var editStatusChangedBlock: ((_ isEdit: Bool) -> Void)?
    
    private lazy var titleLabel: UILabel = {
        let tl = UILabel()
        tl.textColor = UIColor.black
        tl.font = UIFont.systemFont(ofSize: 15)
        tl.textAlignment = .center
        tl.numberOfLines = 0
        return tl
    }()
    
    private lazy var tipsLabel: UILabel = {
        let tl = UILabel()
        tl.textColor = UIColor.lightGray
        tl.font = UIFont.systemFont(ofSize: 12.5)
        tl.textAlignment = .left
        tl.sizeToFit()
        return tl
    }()
    
    private lazy var editBtn: UIButton = {
        let eb = UIButton()
        eb.layer.borderColor = UIColor.red.cgColor
        eb.layer.masksToBounds = true
        eb.layer.borderWidth = 1
        eb.setTitle("编辑", for: .normal)
        eb.setTitle("完成", for: .selected)
        eb.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        eb.setTitleColor(UIColor.red, for: .normal)
        eb.addTarget(self, action: #selector(btnDidClicked(btn:)), for: .touchDown)
        return eb
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isHiddenEdit == true {
            editBtn.isHidden = true
        } else {
            editBtn.isHidden = false
        }
        
        // headerMargin
        titleLabel.frame = CGRect(x: 0, y: 0, width: 65, height: bounds.height)
        
        tipsLabel.frame = CGRect(x: titleLabel.frame.maxX + headerMargin, y: 0, width: 80, height: bounds.height)
        
        editBtn.frame = CGRect(x: bounds.width - 60, y: headerMargin, width: 60, height: bounds.height - headerMargin*2)
        editBtn.layer.cornerRadius = 15
    }
}

extension YDChannelSelectorHeader {
    private func initUI() {
        addSubview(titleLabel)
        addSubview(tipsLabel)
        addSubview(editBtn)
    }
    
    @objc private func btnDidClicked(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        editStatusChangedBlock?(btn.isSelected)
    }
}
