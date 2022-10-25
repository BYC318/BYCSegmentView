//
//  BYCStringExtension.swift
//  BYCRefresh
//
//  Created by BYC on 2022/10/20.
//

import UIKit

extension NSString {
    func widthWith(font: UIFont) -> CGFloat {
        if self.length == 0 { return 0 }
        let attribute : Dictionary<NSAttributedString.Key , Any> = [
            .font : font
        ]
        let maxSize = CGSize.init(width: 300, height: 30)
        let contentRect = self.boundingRect(with: maxSize, options: [.truncatesLastVisibleLine, .usesLineFragmentOrigin, .usesFontLeading], attributes: attribute, context: nil)
        let size = contentRect.integral.size
        return size.width
    }
}
