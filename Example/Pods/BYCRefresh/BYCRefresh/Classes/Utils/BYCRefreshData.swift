//
//  BYCRefreshData.swift
//  BYCRefresh
//
//  Created by BYC on 2022/10/20.
//

struct RefreshData {
    internal static let contentOffset = "contentOffset"
    internal static let contentInset = "contentInset"
    internal static let contentSize = "contentSize"
    internal static let state = "state"
    
    internal static let headerHeight = 50.0
    internal static let footerHeight = 50.0
    
    internal static let animationDuration = 0.25
    
    internal static var headerPointer   = "byc_header"
    internal static var footerPointer   = "byc_footer"
}

public typealias RefreshingBlock = (() -> Void)

public enum RefreshState {
    case idle  /** 普通闲置状态 */
    case pulling /** 松开就可以进行刷新的状态 */
    case refreshing /** 正在刷新中的状态 */
    case willRefresh /** 即将刷新的状态 */
    case endRefresh /** 结束刷新的状态 */
    case noMoreData /** 所有数据加载完毕，没有更多的数据了 */
}
