//
//  BYCSegmentListView.swift
//  CoinExchange_iOS
//
//  Created by 元朝 on 2022/9/16.
//

import UIKit
import BYCSegmentView

class BYCSegmentListView: UIView {

    var clickActionBlock: (() -> Void)?
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "tableViewCell")
        tableView.rowHeight = 50.0
        tableView.backgroundColor = .white
        return tableView
    }()

    var count: Int = 0
    var index: Int = 0

    init(index: Int) {
        super.init(frame: .zero)
        
        self.index = index

        self.addSubview(self.tableView)
        self.tableView.snp.makeConstraints({ (make) in
            make.edges.equalTo(self)
        })
        
        self.tableView.reloadData()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func requestData() {
        self.count = 100
        if self.index == 1 {
            self.count = 5;
        }else if self.index == 2 {
            self.count = 3
        }
        self.reloadData()
    }
    
    func reloadData() {
        self.tableView.reloadData()
    }
}

extension BYCSegmentListView: BYCSegmentListViewDelegate {
    func listView() -> UIView {
        return self
    }

    func listScrollView() -> UIScrollView {
        return self.tableView
    }
}

extension BYCSegmentListView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        cell.textLabel?.text = "第\(indexPath.row+1)行"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        clickActionBlock?()
    }
}
