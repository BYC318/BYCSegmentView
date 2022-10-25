//
//  BYCRefreshHeaderBaseView.swift
//  BYCRefresh
//
//  Created by BYC on 2022/10/20.
//

import UIKit

open class BYCRefreshHeaderBaseView: UIView {

    var automaticallyChangeAlpha = true
    
    var scrollView: UIScrollView?
    
    var refreshingBlock = {}
    var scrollViewOriginalInset: UIEdgeInsets?
    
    var refreshing: Bool {
        state == .refreshing || state == .willRefresh
    }
    
    var pullingPercent: CGFloat = 0.0 {
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
    
    var state: RefreshState = .idle {
        willSet {
            if state == newValue { return }
            
            if newValue == .idle {
                if state != .refreshing { return }
                UIView.animate(withDuration: RefreshData.animationDuration) {
                    if self.automaticallyChangeAlpha {
                        self.alpha = 0.0
                    }
                } completion: { finished in
                    self.pullingPercent = 0.0
                }
            } else if newValue == .refreshing {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: RefreshData.animationDuration) {
                        guard let scrollView = self.scrollView else { return }
                        guard let scrollViewOriginalInset = self.scrollViewOriginalInset else { return }
                        if scrollView.panGestureRecognizer.state != .cancelled {
                            let top = scrollViewOriginalInset.top + self.byc_height
                            scrollView.contentOffset = CGPoint.init(x: 0, y: -top)
                        }
                    } completion: { finished in
                        self.refreshingBlock()
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.setNeedsLayout()
            }
        }
    }
    
    public static func header(refreshingBlock: @escaping RefreshingBlock) -> BYCRefreshHeaderBaseView {
        let view = Self()
        view.refreshingBlock = refreshingBlock
        view.alpha = view.pullingPercent
        return view
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        guard let scrollView = scrollView else {
            return
        }
        byc_x = scrollView.byc_insetL
        byc_y = 0
        byc_width = scrollView.byc_width
        byc_height = RefreshData.headerHeight
        
        if state == .willRefresh {
            state = .refreshing
        }
        print("scrollView === \(scrollView.byc_size)")
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
    
    func removeObservers() {
        guard let scrollView = self.scrollView else {
            return
        }
        
        scrollView.removeObserver(self, forKeyPath: RefreshData.contentOffset)
    }
    
    func addObservers() {
        guard let scrollView = self.scrollView else {
            return
        }
        scrollView.addObserver(self, forKeyPath: RefreshData.contentOffset, options: .new, context: nil)
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if !isUserInteractionEnabled { return }
        if keyPath == RefreshData.contentOffset {
            changeContentOffset(change: change)
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
        guard let scrollViewOriginalInset = scrollViewOriginalInset else { return }
        let offsetY = scrollView.byc_offsetY
        let happenOffsetY = -scrollViewOriginalInset.top
        if offsetY > happenOffsetY { return }
        let normalPullingOffsetY = happenOffsetY - byc_height
        let pullingPercent = (happenOffsetY - offsetY) / byc_height
        self.pullingPercent = pullingPercent
        if scrollView.isDragging {
            
            if state == .idle && offsetY < normalPullingOffsetY {
                state = .pulling
            } else if state == .pulling && offsetY >= normalPullingOffsetY {
                state = .idle
            }
        } else if state == .pulling {
            beginRefreshing()
        }
    }
}

extension BYCRefreshHeaderBaseView {
    
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
}
