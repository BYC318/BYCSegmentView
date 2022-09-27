//
//  ViewController.swift
//  BYCSegmentView
//
//  Created by BYC on 09/23/2022.
//  Copyright (c) 2022 BYC. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.navigationController?.pushViewController(BYCSegmentViewController(), animated: true)
        case 1:
            self.navigationController?.pushViewController(BYCSegmentViewController2(), animated: true)
        case 2:
            self.navigationController?.pushViewController(BYCSegmentViewController3(), animated: true)
        case 3:
            self.navigationController?.pushViewController(BYCSegmentViewController4(), animated: true)
        case 4:
            self.navigationController?.pushViewController(BYCSegmentViewController5(), animated: true)
        case 5:
            self.navigationController?.pushViewController(BYCSegmentViewController6(), animated: true)
        default:
            break
        }
    }
    
}

