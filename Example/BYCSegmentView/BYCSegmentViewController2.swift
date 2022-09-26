//
//  BYCSegmentViewController2.swift
//  CoinExchange_iOS
//
//  Created by 元朝 on 2022/9/16.
//

import UIKit
import JXSegmentedView
import MJRefresh
import BYCSegmentView
import SnapKit

class BYCSegmentViewController2: UIViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    lazy var smoothView: BYCSegmentView = {
        let smoothView = BYCSegmentView(dataSource: self)
        smoothView.headerStickyHeight = UIApplication.shared.statusBarFrame.height + 44
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
    
    private lazy var header: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 400))
        button.setImage(UIImage.init(named: "image"), for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.smoothView)
        self.smoothView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        self.categoryView.contentScrollView = self.smoothView.listCollectionView
    }
    
    @objc func buttonAction() {
        let alter = UIAlertController.init(title: "点击了头部", message: nil, preferredStyle: .alert)
        alter.addAction(UIAlertAction.init(title: "知道了", style: .cancel, handler: nil))
        self.present(alter, animated: true, completion: nil)
    }
}

extension BYCSegmentViewController2: BYCSegmentViewDataSource, BYCListViewDelegate {
    func headerView(_ segmentView: BYCSegmentView) -> UIView? {
        return header
    }
    func sliderView(_ segmentView: BYCSegmentView) -> UIView? {
        return categoryView
    }
    
    func numberOfLists(_ smoothView: BYCSegmentView) -> Int {
        return self.titleDataSource.titles.count
    }
    
    func segmentView(_ smoothView: BYCSegmentView, initListAtIndex index: Int) -> BYCSegmentListViewDelegate {
        let listView = BYCSegmentListView(delegate: self, index: index)
        listView.requestData()
        return listView
    }

    func smoothViewHeaderContainerHeight() -> CGFloat {
        return self.smoothView.headerContainerHeight
    }
}
