//
//  YDChannelSelector.swift
//  YDChannelSelectorDemo
//
//  Created by yudai on 2018/3/12.
//  Copyright © 2018年 TRS. All rights reserved.
//

import UIKit

public protocol YDChannelSelectorDataSource: class {
    func numberOfSections(in selector: YDChannelSelector) -> Int
    func selector(_ selector: YDChannelSelector, numberOfItemsInSection section: Int) -> Int
    func selector(_ selector: YDChannelSelector, itemAt indexPath: IndexPath) -> SelectorItem
}

public protocol YDChannelSelectorDelegate: class {
    /// 数据源发生变化
    func selector(_ selector: YDChannelSelector, didChangeDS newDataSource: [[SelectorItem]])
    /// 点击了关闭按钮
    func selector(_ selector: YDChannelSelector, dismiss newDataSource: [[SelectorItem]])
    /// 点击了某个频道
    func selector(_ selector: YDChannelSelector, didSelectChannel channelItem: SelectorItem)
}

/// item间隙
fileprivate let itemMargin: CGFloat = yd_Inch35() ? 15:yd_Inch40() ? 15:20
/// item宽度
fileprivate let itemW: CGFloat = (UIScreen.main.bounds.width-5*itemMargin)/4
/// item高度
fileprivate let itemH: CGFloat = 35
/// 初始数据源
fileprivate let originDS = "originDS"
/// 用户操纵后数据源
fileprivate let operatedDS = "operatedDS"

public class YDChannelSelector: UIViewController {
    
    // MARK: - 对外属性方法 -
    
    /**
     是否存储上次用户最后一次操作后的数据源(默认存储)
     业务逻辑: 上次原始原始数据源和这次一样，返回上次用户最后操纵数据源，如果原始数据源有变动则返回新数据源，之前用户操作重置
     */
    public var isCacheLastest = true
    
    /// 数据源
    public weak var dataSource: YDChannelSelectorDataSource?
    
    /// 代理
    public weak var delegate: YDChannelSelectorDelegate?
    
    /// 当前选中频道
    public var currentSelected: SelectorItem!

    // MARK: - 私有属性方法 -
    
    /// 私有数据源
    private var _dataSource: [[SelectorItem]]? {
        didSet{
            // 错误过滤
            guard _dataSource != nil && !(_dataSource?.isEmpty)! else {
                assert(false, "DataSources can not be empty!")
                return
            }
            
            // 第一次处理
            guard isFixFlag == false else { return }
            
            // 默认选中第一个
            currentSelected = _dataSource?.first?.first
            
            isFixFlag = true
        }
    }
    
    /// 初始化处理标识
    private var isFixFlag = false

    /// 是否进入编辑状态
    private var isEdit: Bool = false {
        didSet{
            collectionView.reloadData()
        }
    }
    
    /// 最近删除频道
    private var latelyDeleteChannels = [SelectorItem]()
    
    private lazy var titleLabel: UILabel = {
        let tl = UILabel()
        tl.textAlignment = .center
        tl.font = UIFont(name: "Helvetica-Bold", size: 18)
        tl.textColor = UIColor.black
        tl.text = "所有栏目"        
        return tl
    }()
    
    private lazy var dismissBtn: UIButton = {
        let db = UIButton()
        db.setImage(UIImage(named: "selector_dismiss"), for: .normal)
        db.setTitleColor(UIColor.black, for: .normal)
        db.addTarget(self, action: #selector(remove), for: .touchUpInside)
        db.imageEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        return db
    }()
    
    private lazy var longPressGes: UILongPressGestureRecognizer = {
        let lpg = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture(ges:)))
        return lpg
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = itemMargin
        layout.minimumInteritemSpacing = itemMargin
        layout.itemSize = CGSize(width: itemW, height: itemH)
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.contentInset = UIEdgeInsets.init(top: 0, left: itemMargin, bottom: 0, right: itemMargin)
        cv.backgroundColor = UIColor.white
        cv.showsVerticalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(YDChannelSelectorCell.self, forCellWithReuseIdentifier: YDChannelSelectorCellID)
        cv.register(YDChannelSelectorHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: YDChannelSelectorHeaderID)
        cv.addGestureRecognizer(longPressGes)
        return cv
    }()
    
    // MARK: life cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        titleLabel.frame = CGRect(x: (UIScreen.main.bounds.width-72)/2, y: yd_Inch58() || yd_Inch65or61() ? 40:20, width: 72, height: 44)
        dismissBtn.frame = CGRect(x: UIScreen.main.bounds.width-25-20, y: 0, width: 25, height: 25)
        dismissBtn.center.y = titleLabel.center.y
        collectionView.frame = CGRect(x: 0, y: titleLabel.frame.maxY, width: view.bounds.width, height: view.bounds.height - titleLabel.frame.maxY)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var dataSource_t = [[SelectorItem]]()
        
        for i in 0..<(dataSource?.numberOfSections(in: self) ?? 0) {
            var section_t = [SelectorItem]()
            for j in 0..<(dataSource?.selector(self, numberOfItemsInSection: i) ?? 0) {
                let item = dataSource?.selector(self, itemAt: IndexPath(item: j, section: i)) ?? SelectorItem(channelTitle: "unknown", rawData: nil)
                section_t.append(item)
            }
            dataSource_t.append(section_t)
        }

        // 根据需求处理数据源
        if isCacheLastest && UserDefaults.standard.value(forKey: operatedDS) != nil { // 需要缓存之前数据 且用户操作有存储
            // 缓存原始数据源
            if isCacheLastest { cacheDataSource(dataSource: dataSource_t, isOrigin: true) }
            var bool = false
            let newTitlesArrs = dataSource_t.map { $0.map { $0.channelTitle! } }
            let orginTitlesArrs = UserDefaults.standard.value(forKey: originDS) as? [[String]]
            // 之前有存过原始数据源
            if orginTitlesArrs != nil { bool = newTitlesArrs == orginTitlesArrs! }
            if bool { // 和之前数据相等 -> 返回缓存数据源
                let cacheTitleArrs = UserDefaults.standard.value(forKey: operatedDS) as? [[String]]
                let flatArr = dataSource_t.flatMap { $0 }
                var cachedDataSource = cacheTitleArrs!.map { $0.map { SelectorItem(channelTitle: $0, rawData: nil) }}
                for (i,items) in cachedDataSource.enumerated() {
                    for (j,item) in items.enumerated() {
                        for originItem in flatArr {
                            if originItem.channelTitle == item.channelTitle {
                                cachedDataSource[i][j] = originItem
                            }
                        }
                    }
                }
                dataSource_t = cachedDataSource
            } else {  // 和之前数据不等 -> 返回新数据源(不处理)
                
            }
        }
        
        // 预处理数据源
        var dataSource_tt = dataSource_t
        dataSource_tt.insert(latelyDeleteChannels, at: 1)
        _dataSource = dataSource_tt
        collectionView.reloadData()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // 移除界面后的一些操作
        if _dataSource?.count == 2 { // 初始只有1个section
            _dataSource![0] = _dataSource![0] + (_dataSource?[1] ?? [])
        } else {                     // 初始2个或更多section
            _dataSource![2] = _dataSource![1] + (_dataSource?[2] ?? [])
            
        }
        _dataSource?.remove(at: 1)
        latelyDeleteChannels.removeAll()
    }

    deinit {
        delegate = nil
        dataSource = nil
    }
}

extension YDChannelSelector {
    private func initUI() {
        view = HitTestView()
        view.backgroundColor = UIColor.white
        
        view.addSubview(titleLabel)
        view.addSubview(collectionView)
        view.addSubview(dismissBtn)
        
        (view as! HitTestView).collectionView = collectionView
    }
    
    @objc private func remove() {
        // 通知代理
        delegate?.selector(self, dismiss: _dataSource!)
        // 移除控制器
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleLongGesture(ges: UILongPressGestureRecognizer) {
        guard isEdit == true else { return }
        switch(ges.state) {
        case .began:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: ges.location(in: collectionView)) else { break }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(ges.location(in: ges.view!))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
    private func handleDataSource(sourceIndexPath: IndexPath, destinationIndexPath: IndexPath) {
        let sourceStr = _dataSource![sourceIndexPath.section][sourceIndexPath.row]
        if sourceIndexPath.section == 0 && destinationIndexPath.section == 1 { // 我的栏目 -> 最近删除
            latelyDeleteChannels.append(sourceStr)
        }
        
        if sourceIndexPath.section == 1 && destinationIndexPath.section == 0 && !latelyDeleteChannels.isEmpty { // 最近删除 -> 我的栏目
            latelyDeleteChannels.remove(at: sourceIndexPath.row)
        }
        
        _dataSource![sourceIndexPath.section].remove(at: sourceIndexPath.row)
        _dataSource![destinationIndexPath.section].insert(sourceStr, at: destinationIndexPath.row)
        
        // 通知代理
        delegate?.selector(self, didChangeDS: _dataSource!)
        // 存储用户操作
        cacheDataSource(dataSource: _dataSource!)
    }
    
    private func cacheDataSource(dataSource: [[SelectorItem]], isOrigin: Bool = false) {
        guard isCacheLastest else { return }
        var titlesArrs = dataSource.map { $0.map { $0.channelTitle! } }
        if isOrigin {                 // 原始数据源
            UserDefaults.standard.set(titlesArrs, forKey: originDS)
        } else {                      // 最近删除 -> 更多栏目
            if dataSource.count > 2 { // 有更多栏目
                titlesArrs[2] = titlesArrs[1] + titlesArrs[2]
                titlesArrs.remove(at: 1)
                UserDefaults.standard.set(titlesArrs, forKey: operatedDS)
            } else {                  // 没有更多栏目
                UserDefaults.standard.set(titlesArrs, forKey: operatedDS)
            }
        }
        UserDefaults.standard.synchronize()
    }
}

extension YDChannelSelector: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return _dataSource?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _dataSource![section].count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: YDChannelSelectorCellID, for: indexPath) as! YDChannelSelectorCell
    
        let item = _dataSource![indexPath.section][indexPath.row]
        
        // 设置固定栏目
        cell.isFixation = item.isFixation
        // 设置选中
        cell.isCurrentSelected = item.channelTitle == currentSelected.channelTitle
        // 设置数据源
        cell.dataSource = item.channelTitle
        
        if indexPath.section == 0 { // 是我的栏目
            cell.cellType = .delete
            cell.isEdit = isEdit
        } else {                    // 不是我的栏目
            cell.cellType = .add
            cell.isEdit = true
        }
        
        cell.longPressAction = { [weak self] _ in
            // 激活编辑状态
            self?.isEdit = true
        }
        
        // 手势冲突解决
        longPressGes.require(toFail: cell.longPressGes)
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: YDChannelSelectorHeaderID, for: indexPath) as! YDChannelSelectorHeader
        header.editStatusChangedBlock = { [weak self] (isEdit) in
            self?.isEdit = isEdit
        }
        if indexPath.section == 0 {
            header.isHiddenEdit = false
            header.isEdit = isEdit
            header.title = "我的栏目"
            if isEdit == true {
                header.tips = "拖动排序"
            } else {
                header.tips = "点击进入栏目"
            }
        } else if indexPath.section == 1 && !latelyDeleteChannels.isEmpty {
            header.isHiddenEdit = true
            header.title = "最近删除"
            header.tips = ""
        } else {
            header.isHiddenEdit = true
            header.title = "更多栏目"
            header.tips = "点击添加栏目"
        }
        return header
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {                                          // 我的栏目
            return CGSize(width: 0, height: 50)
        } else if section == 1 && latelyDeleteChannels.isEmpty {   // 没有最近删除
            return CGSize.zero
        } else if section == 1 && !latelyDeleteChannels.isEmpty {  // 有最近删除
            return CGSize(width: 0, height: 50)
        } else {                                                   // 更多栏目
            return CGSize(width: 0, height: 50)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! YDChannelSelectorCell
        if indexPath.section == 0 && isEdit && !cell.isFixation { // 我的栏目 非固定栏目 编辑状态下 -> 最近删除
            let destinationIndexPath = IndexPath(item: 0, section: 1)
            handleDataSource(sourceIndexPath: indexPath, destinationIndexPath: destinationIndexPath)
            collectionView.moveItem(at: indexPath, to: destinationIndexPath)
            let destinationCell = collectionView.cellForItem(at: destinationIndexPath) as! YDChannelSelectorCell
            destinationCell.cellType = .add
        } else if indexPath.section == 0 && !isEdit {        // 我的栏目 非编辑状态下 -> 事件传递
            let channelItem = _dataSource![indexPath.section][indexPath.row]
            // 通知代理
            delegate?.selector(self, didSelectChannel: channelItem)
            // dismiss
            dismiss(animated: true, completion: nil)
            // 当前选中切换
            currentSelected = channelItem
        } else if indexPath.section != 0 {                   // 更多栏目 -> 我的栏目
            let destinationIndexPath = IndexPath(item: _dataSource![0].count, section: 0)
            handleDataSource(sourceIndexPath: indexPath, destinationIndexPath: destinationIndexPath)
            collectionView.moveItem(at: indexPath, to: destinationIndexPath)
            let destinationCell = collectionView.cellForItem(at: destinationIndexPath) as! YDChannelSelectorCell
            destinationCell.cellType = .delete
            destinationCell.isEdit = isEdit
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        let item = _dataSource![indexPath.section][indexPath.row]
        if indexPath.section > 0 || item.isFixation { // 不是我的栏目 或者是固定栏目
            return false
        } else {
            return true
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        handleDataSource(sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath)
    }
    
    /// 这个方法里面控制需要移动和最后移动到的IndexPath(开始移动时)
    /// - Returns: 当前期望移动到的位置
    public func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        let item = _dataSource![proposedIndexPath.section][proposedIndexPath.row]
        if proposedIndexPath.section > 0 || item.isFixation { // 不是我的栏目 或者是固定栏目
            return originalIndexPath // 操作还原
        } else {
            return proposedIndexPath // 操作完成
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if latelyDeleteChannels.isEmpty { // 没有最近删除
            if indexPath.section == 1 {
                (collectionViewLayout as! UICollectionViewFlowLayout).sectionInset = UIEdgeInsets.zero
                return CGSize.zero
            } else {
                (collectionViewLayout as! UICollectionViewFlowLayout).sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 20, right: 0)
                return CGSize(width: itemW, height: itemH)
            }
        } else { // 有最近删除
            (collectionViewLayout as! UICollectionViewFlowLayout).sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 20, right: 0)
            return CGSize(width: itemW, height: itemH)
        }
    }
}

public struct SelectorItem {
    
    /// 频道名称
    public var channelTitle: String!
    /// 是否是固定栏目
    public var isFixation: Bool!
    /// 频道对应初始字典或模型
    public var rawData: Any?
    
    public init(channelTitle: String, isFixation: Bool = false, rawData: Any?) {
        self.channelTitle = channelTitle
        self.isFixation = isFixation
        self.rawData = rawData
    }
}

fileprivate class HitTestView: UIView {
    
    open var collectionView: UICollectionView!
    
    /// 拦截系统触碰事件
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let indexPath = collectionView.indexPathForItem(at: convert(point, to: collectionView)) { // 在某个cell上
            let cell = collectionView.cellForItem(at: indexPath) as! YDChannelSelectorCell
            cell.touchAnimate()
        }
        return super.hitTest(point, with: event)
    }
}

