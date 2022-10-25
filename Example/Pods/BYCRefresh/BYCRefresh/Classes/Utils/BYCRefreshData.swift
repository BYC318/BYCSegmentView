//
//  BYCRefreshData.swift
//  BYCRefresh
//
//  Created by BYC on 2022/10/20.
//

struct RefreshData {
    static let contentOffset = "contentOffset"
    static let contentInset = "contentInset"
    static let contentSize = "contentSize"
    static let state = "state"
    
    static let headerHeight = 50.0
    static let footerHeight = 50.0
    
    static let animationDuration = 0.25
    
    static var headerPointer   = "byc_header"
    static var footerPointer   = "byc_footer"
}

public typealias RefreshingBlock = (() -> Void)

enum RefreshState {
    case idle  /** 普通闲置状态 */
    case pulling /** 松开就可以进行刷新的状态 */
    case refreshing /** 正在刷新中的状态 */
    case willRefresh /** 即将刷新的状态 */
    case endRefresh /** 结束刷新的状态 */
    case noMoreData /** 所有数据加载完毕，没有更多的数据了 */
}
