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
        default:
            break
        }
    }
    
}

