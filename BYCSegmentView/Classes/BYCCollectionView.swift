//
//  BYCCollectionView.swift
//  BYCSegmentView
//
//  Created by BYC on 2022/12/28.
//

import UIKit

open class BYCCollectionView: UICollectionView, UIGestureRecognizerDelegate {

    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        panGestureRecognizer.delegate = self
        
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let transitionX = panGesture.translation(in: self).x
            if transitionX < 0, contentSize.width - contentOffset.x == self.frame.width {
                return false
            } else if transitionX > 0, contentOffset.x == 0 {
                return false
            }
        }
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        guard let description = otherGestureRecognizer.view?.description else {
            return false
        }
        if description.contains("UILayoutContainerView") {
            return true
        }
        return false
    }
    
}
