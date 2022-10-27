//
//  UIView+BYCExtentsion.swift
//  BYCRefresh
//
//  Created by BYC on 2022/10/20.
//

import UIKit

extension UIView {

    internal var byc_x: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            frame.origin.x = newValue
        }
    }

    internal var byc_y: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            frame.origin.y = newValue
        }
    }
    
    internal var byc_height: CGFloat {
        get {
            return frame.size.height
        }
        set {
            frame.size.height = newValue
        }
    }
    
    internal var byc_width: CGFloat {
        get {
            return frame.size.width
        }
        set {
            frame.size.width = newValue
        }
    }
    
    internal var byc_size: CGSize {
        get {
            return frame.size
        }
        set {
            byc_width = newValue.width
            byc_height = newValue.height
        }
    }

}
