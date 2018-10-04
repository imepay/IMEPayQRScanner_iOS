//
//  ViewController.swift
//  ScannerDemo
//
//  Created by Manoj Karki on 10/4/18.
//  Copyright © 2018 Manoj Karki. All rights reserved.
//

import UIKit
import IMEPayQRScanner

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func scan(_ sender: Any) {
        let coordinator = IMPScannerCoordinator(parentViewController: self)
        
        coordinator.onScanSuccess  = { name, mobileNumOrCode in
            print("Merchant Name \(name ?? "")")
            print("Merchant Mobile Number / Code \(mobileNumOrCode ?? "")")
        }
        
        coordinator.onScanFailure = {
            print("Scanner failure message \($0 ?? "")")
        }
        
        coordinator.start()
    }


}

