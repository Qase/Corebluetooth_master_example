//
//  BaseNavigationController.swift
//  NNLockLite
//
//  Created by David Nemec on 13/11/2017.
//  Copyright © 2017 Quanti. All rights reserved.
//

import UIKit

class BaseNavigationViewController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.barTintColor = .navigationBar
        navigationBar.tintColor = UIColor.white
        navigationBar.isTranslucent = false

    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}
