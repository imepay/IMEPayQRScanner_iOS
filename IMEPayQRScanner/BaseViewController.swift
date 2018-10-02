//
//  BaseViewController.swift
//  IMEPayWallet
//
//  Created by Manoj Karki on 10/8/17.
//  Copyright © 2017 imedigital. All rights reserved.
//

import UIKit
import CoreLocation

class BaseViewController: UIViewController {

    var viewDidAppearFirstTime: Bool = false
    var viewWillAppearFirstTime: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "back")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    func backButtonTapped() {
        navigationController?.popViewController(animated: true)
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    func viewDidAppearForFirstTime() {}
    func viewWillAppearForFirstTime() {}

}
