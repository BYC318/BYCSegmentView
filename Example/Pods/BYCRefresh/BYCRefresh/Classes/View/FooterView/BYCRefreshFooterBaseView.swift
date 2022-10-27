//
//  BYCRefreshFooterBaseView.swift
//  BYCRefresh
//
//  Created by BYC on 2022/10/19.
//

import UIKit

open class BYCRefreshFooterBaseView: UIView {

    
    public var automaticallyChangeAlpha = true
    
    public var scrollView: UIScrollView?
    public var offset = 0.0
    public var diffInset = 0.0
    var refreshingBlock = {}
    var scrollViewOriginalInset: UIEdgeInsets?
    var firstLayout = true
    var lastBottomDelta = 0.0
    
    
    public var refreshing: Bool {
        state == .refreshing || state == .willRefresh
    }
    
    open var pullingPercent: CGFloat = 0.0 {
        didSet {
            if pullingPercent > 1 {
                pullingPercent = 1
                return
            }
            if automaticallyChangeAlpha {
                if refreshing {
                    alpha = 1.0
                }else {
                    alpha = pullingPercent
                }
            }
        }
    }
    
    open var state: RefreshState = .idle {
        willSet {
            if state == newValue { return }
            let oldState = state
            DispatchQueue.main.async {
                guard let scrollView = self.scrollView else { return }
                
                if self.state == .idle || self.state == .noMoreData {
                    
                    if oldState == .refreshing {
                        
                        UIView.animate(withDuration: RefreshData.animationDuration) {
                            scrollView.byc_insetB -= self.lastBottomDelta
                            self.alpha = 0.0
                        } completion: { finished in
                            self.pullingPercent = 0.0
                        }
                    }
                    let deltaH = self.heightForContentBreakView()
                    
                    if oldState == .refreshing && deltaH > 0 {
                        scrollView.byc_offsetY = scrollView.byc_offsetY
                    }
                    
                } else if self.state == .refreshing {
                    UIView.animate(withDuration: RefreshData.animationDuration) {
                        let scrollViewOriginalInsetBottom = self.scrollViewOriginalInset?.bottom ?? 0
                        var bottom = scrollViewOriginalInsetBottom + self.gap()
                        let deltaH = self.heightForContentBreakView()
                        if deltaH < 0 {
                            bottom -= deltaH
                        }
                        self.lastBottomDelta = bottom - scrollView.byc_insetB
                        scrollView.byc_insetB = bottom
                        scrollView.byc_offsetY = self.reponseRefreshOffsetY() + self.gap()
                    } completion: { finished in
                        self.refreshingBlock()
                    }
                    
                }
                
                DispatchQueue.main.async {
                    self.setNeedsLayout()
                }
            }
        }
    }
    
    public static func footer(refreshingBlock: @escaping RefreshingBlock) -> BYCRefreshFooterBaseView {
        let view = Self()
        view.byc_height = RefreshData.footerHeight
        view.refreshingBlock = refreshingBlock
        view.alpha = view.pullingPercent
        view.state = .idle
        return view
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        guard let scrollView = scrollView else {
            return
        }
        if firstLayout {
            guard let scrollViewOriginalInset = scrollViewOriginalInset else { return }
            firstLayout = false
            let contentHeight = scrollView.byc_contentH
            let scrollHeight = scrollView.byc_height - scrollViewOriginalInset.top - scrollViewOriginalInset.bottom
            byc_y = max(contentHeight, scrollHeight) - offset - byc_height
        }
        byc_x = scrollView.byc_insetL
        byc_width = scrollView.byc_width
        byc_height = RefreshData.footerHeight
        
        if state == .willRefresh {
            state = .refreshing
        }
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        if newSuperview == nil {
            removeObservers()
        }
        
        guard let scrollView = newSuperview as? UIScrollView else {
            return
        }
        
        removeObservers()
        self.scrollView = scrollView
        scrollView.alwaysBounceVertical = true
        scrollViewOriginalInset = scrollView.byc_inset
        addObservers()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func gap() -> CGFloat {
        offset >= 0 ? 0 : -((diffInset > 0 ? diffInset : 0) + offset)
    }
    
    func removeObservers() {
        guard let scrollView = self.scrollView else {
            return
        }
        
        scrollView.removeObserver(self, forKeyPath: RefreshData.contentOffset)
        scrollView.removeObserver(self, forKeyPath: RefreshData.contentSize)
    }
    
    func addObservers() {
        guard let scrollView = self.scrollView else {
            return
        }
        scrollView.addObserver(self, forKeyPath: RefreshData.contentOffset, options: .new, context: nil)
        scrollView.addObserver(self, forKeyPath: RefreshData.contentSize, options: .new, context: nil)
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if !isUserInteractionEnabled { return }
        if keyPath == RefreshData.contentOffset {
            changeContentOffset(change: change)
        } else if keyPath == RefreshData.contentSize {
            changeContentSize(change: change)
        }
    }
    
    func changeContentOffset(change: [NSKeyValueChangeKey : Any]?) {
        guard let scrollView = scrollView else { return }
        if byc_width != scrollView.byc_width {
            setNeedsLayout()
            layoutIfNeeded()
        }
        if state == .refreshing { return }
        scrollViewOriginalInset = scrollView.byc_inset
        let offsetY = scrollView.byc_offsetY
        let reponseRefreshOffsetY = reponseRefreshOffsetY()
        if offsetY <= reponseRefreshOffsetY { return }
        let pullingPercent = (offsetY - reponseRefreshOffsetY) / byc_height
        
        if state == .noMoreData {
            self.pullingPercent = pullingPercent
            return
        }

        if scrollView.isDragging {
            self.pullingPercent = pullingPercent
            let normalPullingOffsetY = reponseRefreshOffsetY + byc_height
            if state == .idle && offsetY > normalPullingOffsetY {
                state = .pulling
            } else if state == .pulling && offsetY <= normalPullingOffsetY {
                state = .idle
            }
        } else if state == .pulling {
            beginRefreshing()
        } else if pullingPercent < 1 {
            self.pullingPercent = pullingPercent
        }
    }
    
    func changeContentSize(change: [NSKeyValueChangeKey : Any]?) {
        guard let scrollView = scrollView else { return }
        guard let scrollViewOriginalInset = scrollViewOriginalInset else { return }
        let contentHeight = scrollView.byc_contentH
        let scrollHeight = scrollView.byc_height - scrollViewOriginalInset.top - scrollViewOriginalInset.bottom
        byc_y = max(contentHeight, scrollHeight) - offset - byc_height
    }
    
    func heightForContentBreakView() -> CGFloat {
        guard let scrollView = scrollView else { return 0 }
        guard let scrollViewOriginalInset = scrollViewOriginalInset else { return 0 }
        let height = scrollView.byc_height - scrollViewOriginalInset.bottom - scrollViewOriginalInset.top
        return scrollView.byc_contentH - height
    }
    
    func reponseRefreshOffsetY() -> CGFloat {
        guard let scrollViewOriginalInset = scrollViewOriginalInset else { return 0 }
        let deltaH = heightForContentBreakView()
        if deltaH > 0 {
            return deltaH - scrollViewOriginalInset.top
        }
        return -scrollViewOriginalInset.top
    }
}

extension BYCRefreshFooterBaseView {
    
    public func beginRefreshing() {
        UIView.animate(withDuration: RefreshData.animationDuration) {
            self.alpha = 1.0
        }
        
        if window != nil {
            state = .refreshing
        } else {
            if state != .refreshing {
                state = .willRefresh
                setNeedsLayout()
            }
        }
    }
    
    public func endRefreshing() {
        DispatchQueue.main.async {
            self.state = .idle
        }
    }
    
    public func endRefreshingNoMoreData() {
        DispatchQueue.main.async {
            self.state = .noMoreData
        }
    }
}

