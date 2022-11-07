//
//  BaseViewController.swift
//  BYCSegmentView_Example
//
//  Created by BYC on 2022/11/7.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import WRNavigationBar

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        wr_setNavBarBackgroundAlpha(0)
    }

}
