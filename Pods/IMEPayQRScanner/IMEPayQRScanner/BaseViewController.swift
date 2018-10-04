//
//  BaseViewController.swift
//  IMEPayWallet
//
//  Created by Manoj Karki on 10/8/17.
//  Copyright © 2017 imedigital. All rights reserved.
//

import UIKit

// MARK:- Base UIViewController class

class BaseViewController: UIViewController {

    var viewDidAppearFirstTime: Bool = false
    var viewWillAppearFirstTime: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if  !viewDidAppearFirstTime {
            viewDidAppearFirstTime = true
            viewDidAppearForFirstTime()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if  !viewWillAppearFirstTime {
            viewWillAppearFirstTime = true
            viewWillAppearForFirstTime()
        }
    }

    func viewDidAppearForFirstTime() {}
    func viewWillAppearForFirstTime() {}

}
