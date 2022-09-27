//
//  BYCSegmentViewController4.swift
//  CoinExchange_iOS
//
//  Created by 元朝 on 2022/9/16.
//

import UIKit
import JXSegmentedView
import MJRefresh
import BYCSegmentView
import SnapKit

class BYCSegmentViewController4: UIViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    lazy var smoothView: BYCSegmentView = {
        let smoothView = BYCSegmentView(dataSource: self)
        smoothView.headerStickyHeight = 0
        smoothView.defaultSelectedIndex = 1
        return smoothView
    }()
    
    var titleDataSource = JXSegmentedTitleDataSource()
    
    lazy var categoryView: JXSegmentedView = {
        let categoryView = JXSegmentedView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50))
        
        categoryView.backgroundColor = .white
        
        titleDataSource.titles = ["BTC", "ETH", "CET"]
        titleDataSource.titleNormalFont = UIFont.systemFont(ofSize: 14.0)
        titleDataSource.titleSelectedFont = UIFont.systemFont(ofSize: 16.0)
        titleDataSource.titleNormalColor = .black
        titleDataSource.titleSelectedColor = .black
        titleDataSource.isTitleZoomEnabled = true
        titleDataSource.reloadData(selectedIndex: 0)
        categoryView.dataSource = titleDataSource
        categoryView.defaultSelectedIndex = 1
        let lineView = JXSegmentedIndicatorLineView()
        lineView.lineStyle = .lengthen
        categoryView.indicators = [lineView]
        
        return categoryView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.smoothView)
        self.view.addSubview(self.categoryView)
        
        view.backgroundColor = .red

        let top = UIApplication.shared.statusBarFrame.height + 44
        self.categoryView.snp.makeConstraints { (make) in

            make.top.equalTo(top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        self.smoothView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets.init(top: 50 + top, left: 0, bottom: 0, right: 0))
        }
        self.categoryView.contentScrollView = self.smoothView.listCollectionView
    }
}

extension BYCSegmentViewController4: BYCSegmentViewDataSource {

    func numberOfLists(_ smoothView: BYCSegmentView) -> Int {
        return self.titleDataSource.titles.count
    }
    
    func segmentView(_ smoothView: BYCSegmentView, initListAtIndex index: Int) -> BYCSegmentListViewDelegate {
        let listView = BYCSegmentListView(index: index)
        listView.requestData()
        return listView
    }
}
