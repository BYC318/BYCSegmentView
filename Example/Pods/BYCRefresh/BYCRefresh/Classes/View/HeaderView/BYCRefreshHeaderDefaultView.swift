//
//  BYCRefreshHeaderDefaultView.swift
//  BYCRefresh
//
//  Created by BYC on 2022/10/20.
//

import UIKit

open class BYCRefreshHeaderDefaultView: BYCRefreshHeaderBaseView {

    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .green
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    
    open override var state: RefreshState {
        didSet {
            switch state {
            case .idle:
                label.text = "下拉即可刷新~"
            case .pulling:
                label.text = "松开即可刷新~"
            case .refreshing:
                label.text = "刷新中~"
            case .willRefresh:
                label.text = "即将刷新~"
            case .noMoreData:
                label.text = "加载完毕~"
            default:
                break
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
    }
}
