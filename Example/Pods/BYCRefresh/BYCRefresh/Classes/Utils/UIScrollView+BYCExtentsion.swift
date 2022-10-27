//
//  UIScrollView+BYCExtentsion.swift
//  BYCRefresh
//
//  Created by BYC on 2022/10/20.
//

import UIKit

extension UIScrollView {
    internal var byc_inset: UIEdgeInsets {
        if #available(iOS 11, *) {
            return adjustedContentInset
        }
        return contentInset
    }
    
    internal var byc_insetT: CGFloat {
        set {
            var inset = contentInset
            inset.top = newValue
            if #available(iOS 11, *) {
                inset.top -= (adjustedContentInset.top - contentInset.top)
            }
            contentInset = inset
        }
        get {
            byc_inset.top
        }
    }
    
    internal var byc_insetB: CGFloat {
        set {
            var inset = contentInset
            inset.bottom = newValue
            if #available(iOS 11, *) {
                inset.bottom -= (adjustedContentInset.bottom - contentInset.bottom)
            }
            contentInset = inset
        }
        get {
            byc_inset.bottom
        }
    }
    
    internal var byc_insetL: CGFloat {
        set {
            var inset = contentInset
            inset.left = newValue
            if #available(iOS 11, *) {
                inset.left -= (adjustedContentInset.left - contentInset.left)
            }
            contentInset = inset
        }
        get {
            byc_inset.left
        }
    }
    
    internal var byc_insetR: CGFloat {
        set {
            var inset = contentInset
            inset.right = newValue
            if #available(iOS 11, *) {
                inset.right -= (adjustedContentInset.right - contentInset.right)
            }
            contentInset = inset
        }
        get {
            byc_inset.right
        }
    }
    
    internal var byc_offsetX: CGFloat {
        set {
            var offset = contentOffset
            offset.x = newValue
            contentOffset = offset
        }
        get {
            contentOffset.x
        }
    }
    
    internal var byc_offsetY: CGFloat {
        set {
            var offset = contentOffset
            offset.y = newValue
            contentOffset = offset
        }
        get {
            contentOffset.y
        }
    }
    
    internal var byc_contentW: CGFloat {
        set {
            var size = contentSize
            size.width = newValue
            contentSize = size
        }
        get {
            contentSize.width
        }
    }
    
    internal var byc_contentH: CGFloat {
        set {
            var size = contentSize
            size.height = newValue
            contentSize = size
        }
        get {
            contentSize.height
        }
    }
}

extension UIScrollView {
    public var byc_header: BYCRefreshHeaderBaseView? {
        set {
            let header = byc_header
            if header == newValue { return }
            header?.removeFromSuperview()
            objc_setAssociatedObject(self, &RefreshData.headerPointer, newValue, .OBJC_ASSOCIATION_RETAIN)
            guard let newValue = newValue else { return }
            self.insertSubview(newValue, at: 0)
        }
        get {
            return objc_getAssociatedObject(self, &RefreshData.headerPointer) as? BYCRefreshHeaderBaseView
        }
    }
    
    public var byc_footer: BYCRefreshFooterBaseView? {
        set {
            let footer = byc_footer
            if footer == newValue { return }
            footer?.removeFromSuperview()
            objc_setAssociatedObject(self, &RefreshData.footerPointer, newValue, .OBJC_ASSOCIATION_RETAIN)
            guard let newValue = newValue else { return }
            self.insertSubview(newValue, at: 0)
        }
        get {
            return objc_getAssociatedObject(self, &RefreshData.footerPointer) as? BYCRefreshFooterBaseView
        }
    }
    
}
