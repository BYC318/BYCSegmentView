//
//  BYCSegmentView.swift
//  CoinExchange_iOS
//
//  Created by 元朝 on 2022/9/16.
// 2

import UIKit

public enum BYCSegmentHoverType {
    case none
    case top
}

@objc public protocol BYCSegmentListViewDelegate : NSObjectProtocol {
    
    func listView() -> UIView
    func listScrollView() -> UIScrollView
    
    @objc optional func listViewDidAppear()
    @objc optional func listViewDidDisappear()
    
    @objc optional func listScrollViewShouldReset() -> Bool
}

@objc public protocol BYCSegmentViewDataSource : NSObjectProtocol {
    func headerView(_ segmentView: BYCSegmentView) -> UIView?
    func sliderView(_ segmentView: BYCSegmentView) -> UIView?
    func numberOfLists(_ segmentView: BYCSegmentView) -> Int
    func segmentView(_ segmentView: BYCSegmentView, initListAtIndex index: Int) -> BYCSegmentListViewDelegate
}

@objc public protocol BYCSegmentViewDelegate : NSObjectProtocol {
    @objc optional func segmentViewDidScroll(_ segmentView: BYCSegmentView, scrollView: UIScrollView)
    @objc optional func segmentViewListScrollViewDidScroll(_ segmentView: BYCSegmentView, scrollView: UIScrollView, contentOffset: CGPoint)
    @objc optional func segmentViewDragBegan(_ segmentView: BYCSegmentView)
    @objc optional func segmentViewDragEnded(_ segmentView: BYCSegmentView, isOnTop: Bool)
}

let BYCSegmentViewCellID = "SegmentCell"
let BYCSegmentViewContentOffset = "contentOffset"
let BYCSegmentViewContentSize = "contentSize"

open class BYCSegmentView: UIView, UIGestureRecognizerDelegate {
    /// 列表代理集合
    public private(set) var listDict = [Int: BYCSegmentListViewDelegate]()
    public let listCollectionView: UICollectionView
    public var defaultSelectedIndex: Int = 0
    /// 悬停高度
    public var headerStickyHeight: CGFloat = 0
    public weak var delegate: BYCSegmentViewDelegate?
    weak var dataSource: BYCSegmentViewDataSource?
    public private(set) var hoverType: BYCSegmentHoverType = .none
    /// 支持内容不足时候撑开内容
    public var isHoldUpScrollView: Bool = true
    /// 列表头部占位容器集合
    var listHeaderDict = [Int: UIView]()
    /// 主视图头部占位容器
    lazy var headerContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        return view
    }()

    var headerView: UIView?
    var sliderView: UIView?
    
    public private(set) var currentIndex: Int = 0
    public private(set) var currentListScrollView: UIScrollView?
    var isSyncListContentOffsetEnabled: Bool = false
    var currentHeaderContainerViewY: CGFloat = 0
    
    public private(set) var headerContainerHeight: CGFloat = 0
    var headerHeight: CGFloat = 0
    var segmentedHeight: CGFloat = 0
    var currentListInitailzeContentOffsetY: CGFloat = 0

    var isScroll = false
    
    public init(dataSource: BYCSegmentViewDataSource) {
        self.dataSource = dataSource
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        listCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: .zero)
        
        listCollectionView.dataSource = self
        listCollectionView.delegate = self
        listCollectionView.isPagingEnabled = true
        listCollectionView.bounces = false
        listCollectionView.showsHorizontalScrollIndicator = false
        listCollectionView.scrollsToTop = false
        listCollectionView.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: BYCSegmentViewCellID)
        if #available(iOS 10.0, *) {
            listCollectionView.isPrefetchingEnabled = false
        }
        if #available(iOS 11.0, *) {
            listCollectionView.contentInsetAdjustmentBehavior = .never
        }
        self.addSubview(listCollectionView)
        
        self.addSubview(self.headerContainerView)
        self.refreshHeaderView()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        listDict.values.forEach {
            $0.listScrollView().removeObserver(self, forKeyPath: BYCSegmentViewContentOffset)
            $0.listScrollView().removeObserver(self, forKeyPath: BYCSegmentViewContentSize)
        }
        self.headerView?.removeFromSuperview()
        self.sliderView?.removeFromSuperview()
        self.listCollectionView.dataSource = nil
        self.listCollectionView.delegate = nil
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        refreshList(frame: self.bounds)
        self.listCollectionView.frame = self.bounds
    }
        
    func refreshList(frame: CGRect) {
        listDict.values.forEach {
            var f = $0.listView().frame
            if (f.size.width != 0 && f.size.height != 0 && f.size.height != frame.size.height) {
                f.size.height = frame.size.height
                $0.listView().frame = f
                listCollectionView.reloadData()
            }
        }
    }
    
    public func refreshHeaderView() {
        loadHeaderAndSegmentedView()
        refreshHeaderContainerView()
    }

    public func reloadData() {
        currentListScrollView = nil
        currentIndex = defaultSelectedIndex
        currentHeaderContainerViewY = 0
        isSyncListContentOffsetEnabled = false
        
        listHeaderDict.removeAll()
        listDict.values.forEach {
            $0.listScrollView().removeObserver(self, forKeyPath: BYCSegmentViewContentOffset)
            $0.listScrollView().removeObserver(self, forKeyPath: BYCSegmentViewContentSize)
            $0.listView().removeFromSuperview()
        }
        listDict.removeAll()
        
        self.refreshWidth { [self] (size) in
            self.listCollectionView.setContentOffset(CGPoint(x: size.width * CGFloat(self.currentIndex), y: 0), animated: false)
            self.listCollectionView.reloadData()
        }
    }
    
    func loadHeaderAndSegmentedView() {
        self.headerView = self.dataSource?.headerView(self)
        self.sliderView = self.dataSource?.sliderView(self)
        if let headerView = self.headerView {
            self.headerContainerView.addSubview(headerView)
        }
        if let sliderView = self.sliderView {
            self.headerContainerView.addSubview(sliderView)
        }
        
        refreshHeaderContainerHeight()
    }
    
    func refreshHeaderContainerView() {
        self.refreshWidth { [self] (size) in
            self.refreshHeaderContainerHeight()
            
            var frame = self.headerContainerView.frame;
            if __CGSizeEqualToSize(frame.size, .zero) {
                frame = CGRect(x: 0, y: 0, width: size.width, height: self.headerContainerHeight)
            }else {
                frame.size.height = self.headerContainerHeight
            }
            self.headerContainerView.frame = frame
            
            self.headerView?.frame = CGRect(x: 0, y: 0, width: size.width, height: self.headerHeight)
            if let segmentedView = self.sliderView {
                segmentedView.frame = CGRect(x: 0, y: self.headerHeight, width: size.width, height: self.segmentedHeight)
                if segmentedView.superview != self.headerContainerView {
                    self.headerContainerView.addSubview(segmentedView)
                }
            }
            
            self.listDict.values.forEach {
                var insets = $0.listScrollView().contentInset
                insets.top = headerContainerHeight
                $0.listScrollView().contentInset = insets
                $0.listScrollView().contentOffset = CGPoint(x: 0, y: -headerContainerHeight)
            }
            self.listHeaderDict.values.forEach {
                var frame = $0.frame
                frame.origin.y = -headerContainerHeight
                frame.size.height = headerContainerHeight
                $0.frame = frame
            }
        }
    }
    
    func refreshHeaderContainerHeight() {
        self.headerHeight = self.headerView?.bounds.size.height ?? 0
        self.segmentedHeight = self.sliderView?.bounds.size.height ?? 0
        self.headerContainerHeight = self.headerHeight + self.segmentedHeight
    }
    
    func refreshWidth(completion: @escaping (_ size: CGSize)->()) {
        if self.bounds.size.width == 0 {
            DispatchQueue.main.async {
                completion(self.bounds.size)
            }
        }else {
            completion(self.bounds.size)
        }
    }
    
    func listDidScroll(scrollView: UIScrollView) {
        if listCollectionView.isDragging || listCollectionView.isDecelerating { return }
        let index = self.listIndex(for: scrollView)
        if index != self.currentIndex { return }
        self.currentListScrollView = scrollView
        let contentOffsetY = scrollView.contentOffset.y + headerContainerHeight
        if contentOffsetY < (headerHeight - headerStickyHeight) {
            self.hoverType = .none
            isSyncListContentOffsetEnabled = true
            currentHeaderContainerViewY = -contentOffsetY
            for list in listDict.values {
                if list.listScrollView() != scrollView {
                    list.listScrollView().setContentOffset(scrollView.contentOffset, animated: false)
                }
            }
            let header = listHeader(for: scrollView)
            if headerContainerView.superview != header {
                headerContainerView.frame.origin.y = 0
                header?.addSubview(headerContainerView)
            }
            currentListScrollView?.showsVerticalScrollIndicator = false
        }else {
            self.hoverType = .top
            if headerContainerView.superview != self {
                headerContainerView.frame.origin.y = -(headerHeight - headerStickyHeight)
                addSubview(headerContainerView)
            }
            
            currentListScrollView?.showsVerticalScrollIndicator = true
            if isSyncListContentOffsetEnabled {
                isSyncListContentOffsetEnabled = false
                currentHeaderContainerViewY = -(headerHeight - headerStickyHeight)
                for list in listDict.values {
                    if list.listScrollView() != currentListScrollView {
                        list.listScrollView().setContentOffset(CGPoint(x: 0, y: -(segmentedHeight + headerStickyHeight)), animated: false)
                    }
                }
            }
        }
        let contentOffset = CGPoint(x: scrollView.contentOffset.x, y: contentOffsetY)
        self.delegate?.segmentViewListScrollViewDidScroll?(self, scrollView: scrollView, contentOffset: contentOffset)
    }
    
    func listHeader(for listScrollView: UIScrollView) -> UIView? {
        for (index, list) in listDict {
            if list.listScrollView() == listScrollView {
                return listHeaderDict[index]
            }
        }
        return nil
    }
    
    func listIndex(for listScrollView: UIScrollView) -> Int {
        for (index, list) in listDict {
            if list.listScrollView() == listScrollView {
                return index
            }
        }
        return 0
    }
    
    
    func listDidAppear(at index: Int) {
        guard let dataSource = dataSource else { return }
        let count = dataSource.numberOfLists(self)
        if count <= 0 || index >= count {
            return
        }
        listDict[index]?.listViewDidAppear?()
    }
    
    func listDidDisappear(at index: Int) {
        guard let dataSource = dataSource else { return }
        let count = dataSource.numberOfLists(self)
        if count <= 0 || index >= count {
            return
        }
        listDict[index]?.listViewDidDisappear?()
    }
    
    fileprivate func set(scrollView: UIScrollView?, offset: CGPoint) {
        if !__CGPointEqualToPoint(scrollView?.contentOffset ?? .zero, offset) {
            scrollView?.contentOffset = offset
        }
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == BYCSegmentViewContentOffset {
            if let scrollView = object as? UIScrollView {
                listDidScroll(scrollView: scrollView)
            }
        } else if keyPath == BYCSegmentViewContentSize {
            let minContentSizeHeight = self.bounds.size.height - self.segmentedHeight - self.headerStickyHeight
            if let scrollView = object as? UIScrollView {
                let contentH = scrollView.contentSize.height
                if minContentSizeHeight > contentH && self.isHoldUpScrollView {
                    scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: minContentSizeHeight)
                    if let listScrollView = self.currentListScrollView {
                        if scrollView != listScrollView {
                            print("isHoldUpScrollView  111 === ")
                            scrollView.contentOffset = CGPoint(x: 0, y: self.currentListInitailzeContentOffsetY)
                        }
                    }
                }else {
                    var shoudReset = true
                    for list in listDict.values {
                        if list.listScrollView() == scrollView && list.listScrollViewShouldReset?() != nil {
                            shoudReset = list.listScrollViewShouldReset!()
                        }
                    }
                    
                    if minContentSizeHeight > contentH && shoudReset {
                        scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: -self.headerContainerHeight), animated: false)
                        listDidScroll(scrollView: scrollView)
                    }
                }
            }
        }else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    

    func horizontalScrollDidEnd(at index: Int) {
        currentIndex = index
        guard let listHeader = listHeaderDict[index], let listScrollView = listDict[index]?.listScrollView() else { return }
        self.currentListScrollView = listScrollView
        listDict.values.forEach {
            $0.listScrollView().scrollsToTop = ($0.listScrollView() == listScrollView)
        }
        if listScrollView.contentOffset.y <= -(segmentedHeight + headerStickyHeight) {
            headerContainerView.frame.origin.y = 0
            listHeader.addSubview(headerContainerView)
        }
        
        let minContentSizeHeight = self.bounds.size.height - self.segmentedHeight - self.headerStickyHeight
        if (minContentSizeHeight > listScrollView.contentSize.height && !self.isHoldUpScrollView) {
            listScrollView.setContentOffset(CGPoint(x: listScrollView.contentOffset.x, y: listScrollView.contentSize.height-self.headerContainerHeight), animated: false)
            listDidScroll(scrollView: listScrollView)
        }
    }
 
}

extension BYCSegmentView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let dataSource = self.dataSource else { return 0 }
        
        let count = dataSource.numberOfLists(self)
        return count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let dataSource = self.dataSource else { return UICollectionViewCell() }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BYCSegmentViewCellID, for: indexPath)
        var list = listDict[indexPath.item]
        if list == nil {
            list = dataSource.segmentView(self, initListAtIndex: indexPath.item)
            listDict[indexPath.item] = list!
            list?.listView().setNeedsLayout()
            
            let listScrollView = list?.listScrollView()
            if #available(iOS 11.0, *) {
                listScrollView?.contentInsetAdjustmentBehavior = .never
            }
            
            
            var insets = listScrollView?.contentInset
            insets?.top = headerContainerHeight
            list?.listScrollView().contentInset = insets ?? .zero
            currentListInitailzeContentOffsetY = -headerContainerHeight + min(-currentHeaderContainerViewY, (headerHeight - headerStickyHeight))
            self.set(scrollView: listScrollView, offset: CGPoint(x: 0, y: currentListInitailzeContentOffsetY))
            
            let listHeader = UIView(frame: CGRect(x: 0, y: -headerContainerHeight, width: bounds.size.width, height: headerContainerHeight))
            listScrollView?.addSubview(listHeader)
            
            if self.headerContainerView.superview == nil {
                listHeader.addSubview(headerContainerView)
            }
            listHeaderDict[indexPath.item] = listHeader
    
            listScrollView?.addObserver(self, forKeyPath: BYCSegmentViewContentOffset, options: .new, context: nil)
            listScrollView?.addObserver(self, forKeyPath: BYCSegmentViewContentSize, options: .new, context: nil)
            listScrollView?.contentOffset = listScrollView!.contentOffset
        }
        listDict.values.forEach {
            $0.listScrollView().scrollsToTop = ($0 === list)
        }
        if let listView = list?.listView(), listView.superview != cell.contentView {
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            listView.frame = cell.contentView.bounds
            cell.contentView.addSubview(listView)
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        listDict.values.forEach {
            $0.listView().frame = CGRect.init(origin: .zero, size: self.listCollectionView.bounds.size)
        }
        return self.listCollectionView.bounds.size
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        listDidAppear(at: indexPath.item)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        listDidDisappear(at: indexPath.item)
    }
    
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.segmentViewDidScroll?(self, scrollView: scrollView)
        let indexPercent = scrollView.contentOffset.x/scrollView.bounds.size.width
        let index = Int(scrollView.contentOffset.x/scrollView.bounds.size.width)
        
        let listScrollView = self.listDict[index]?.listScrollView()
        if (indexPercent - CGFloat(index) == 0) && !(scrollView.isTracking || scrollView.isDecelerating) && listScrollView?.contentOffset.y ?? 0 <= -(segmentedHeight + headerStickyHeight) {
            horizontalScrollDidEnd(at: index)
        }else {
            if headerContainerView.superview != self {
                headerContainerView.frame.origin.y = currentHeaderContainerViewY
                addSubview(headerContainerView)
            }
        }

        if currentIndex != index {
            currentIndex = index
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            let index = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
            horizontalScrollDidEnd(at: index)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
        horizontalScrollDidEnd(at: index)
    }
}
