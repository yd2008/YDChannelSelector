//
//  YDChannelSelectorCell.swift
//  YDChannelSelectorViewDemo
//
//  Created by yudai on 2018/3/12.
//  Copyright © 2018年 TRS. All rights reserved.
//

import UIKit

/// cell id
public let YDChannelSelectorCellID = "YDChannelSelectorCellID"
/// cell 内部控件之间间距
fileprivate let cellMargin: CGFloat = yd_Inch35() ? 8:yd_Inch40() ? 8:12

enum YDChannelSelectorCellType {
    case add
    case delete
}

class YDChannelSelectorCell: UICollectionViewCell {
    
    /// 长按点击事件
    public var longPressAction: ((_ lpg: UILongPressGestureRecognizer) -> Void)?
    
    /// 数据源
    public var dataSource: String? {
        didSet{
            titleLabel.text = dataSource
        }
    }
    
    /// 是否是固定栏目
    public var isFixation = false
    
    /// 是否是当前选中red
    
    public var isCurrentSelected = false {
        didSet {
            titleLabel.textColor = isCurrentSelected ? UIColor.red : UIColor.black
        }
    }
    
    /// 当前cell类型
    public var cellType: YDChannelSelectorCellType? {
        didSet{
            switch cellType {
            case .add?:
                iconView.image = UIImage(named: "selector_add")
            case .delete?:
                if isFixation {
                    iconView.image = nil
                } else {
                    iconView.image = UIImage(named: "selector_delete")
                }
            default: break
            }
        }
    }
    
    /// 是否进入编辑状态
    open var isEdit: Bool = false {
        didSet{
            if isFixation && isEdit { // 是固定栏目并且在编辑状态下
                contentView.layer.borderColor = UIColor.clear.cgColor
            } else {
                contentView.layer.borderColor = UIColor(white: 0.9, alpha: 1).cgColor
            }
            
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    /// 长按手势识别器
    open lazy var longPressGes: UILongPressGestureRecognizer = {
        let lpg = UILongPressGestureRecognizer(target: self, action: #selector(longPress(lpg:)))
        lpg.delegate = self
        return lpg
    }()
    
    /// 触碰动画
    open func touchAnimate() {
        contentView.backgroundColor = UIColor(white: 0, alpha: 0.1)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.12) { [weak self] in
            self?.contentView.backgroundColor = UIColor.white
        }
    }
    
    private lazy var iconView: UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    private lazy var titleLabel: UILabel = {
        let tl = UILabel()
        tl.font = UIFont.systemFont(ofSize: 14)
        tl.textAlignment = .center
        tl.adjustsFontSizeToFitWidth = true
        tl.baselineAdjustment = .alignCenters
        tl.backgroundColor = UIColor.clear
        return tl
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
        
        contentView.layer.cornerRadius = contentView.bounds.height/2
        let cellW = contentView.bounds.width
        let cellH = contentView.bounds.height
        
        // 设置对应情况下内部控件frame
        if isEdit == true { // 编辑状态下
            let iconW: CGFloat = yd_Inch35() ? 8:yd_Inch40() ? 8:10
            let iconX: CGFloat = cellMargin
            let iconY: CGFloat = (cellH - iconW)/2
            let iconH: CGFloat = iconW
            iconView.frame = CGRect(x: iconX, y: iconY, width: iconW, height: iconH)
            
            let titleW: CGFloat = cellW - iconView.frame.maxY - (yd_Inch35() ? -4:yd_Inch40() ? -4:0)
            let titleX: CGFloat = iconView.frame.maxX + 2
            let titleY: CGFloat = 0
            let titleH: CGFloat = cellH
            titleLabel.frame = CGRect(x: titleX, y: titleY, width: titleW, height: titleH)
            titleLabel.frame.size.width -= 10
        } else {           // 非编辑状态下
            // 隐藏iconView
            iconView.frame = CGRect.zero
            titleLabel.frame = contentView.bounds
            titleLabel.frame.size.width -= (yd_Inch35() ? 10:yd_Inch40() ? 10:yd_Inch47() ? 15:18)
            titleLabel.frame.origin.x = (bounds.width - titleLabel.frame.size.width)/2
        }
    }
    
}

extension YDChannelSelectorCell {
    private func initUI() {
        // 手势添加
        addGestureRecognizer(longPressGes)
        
        // UI
        contentView.layer.borderWidth = 1
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(iconView)
    }

    @objc private func longPress(lpg: UILongPressGestureRecognizer) {
        guard lpg.state == .began else { return }
        longPressAction?(lpg)
    }
}

extension YDChannelSelectorCell: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return !(isEdit && cellType != .add)
    }
}

// frame 相关常用函数
func yd_Inch35() -> Bool { return UIScreen.main.bounds.height == 480.0 }
func yd_Inch40() -> Bool { return UIScreen.main.bounds.height == 568.0 }
func yd_Inch47() -> Bool { return UIScreen.main.bounds.height == 667.0 }
func yd_Inch55() -> Bool { return UIScreen.main.bounds.height == 736.0 }
func yd_Inch58() -> Bool { return UIScreen.main.bounds.height == 812.0 }
func yd_Inch65or61() -> Bool { return UIScreen.main.bounds.height == 896.0 }
