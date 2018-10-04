//
//  IMPScannerCoordinator.swift
//  IMEPayQRScanner
//
//  Created by Manoj Karki on 10/2/18.
//  Copyright © 2018 Manoj Karki. All rights reserved.
//

import UIKit

// MARK:- Scanner Controller Delegate protocol

protocol ScannerControllerDelegate: class {
    func scannerSucceed(name: String?, mobileNumberOrCode: String?)
    func scannerFailed(errorMessage: String?)
    func cancelled()
}

// MARK:- SDK Coordinator

final public class IMPScannerCoordinator {

    private struct Constants {
        static let mainStoryboardName = "Scanner"
        static let cancelledMessage = "Cancelled by user"
    }

    var onScanSuccess: (( _ name : String?, _ mobileNumberOrCode: String?) -> Void)?
    var onScanFailure: (( _ errorMessage: String?) -> Void)?

    private var parentVc: UIViewController?

    public init(parentViewController: UIViewController?) {
        self.parentVc = parentViewController
    }

    public func start() {
        let scannerVc = QRCodeScannerViewController.initFromStoryboard(name: Constants.mainStoryboardName)
        scannerVc.scannerDelegate = self
        self.parentVc?.present(scannerVc, animated: true, completion: nil)
    }
}

// MARK:- ScannerControllerDelegate

extension IMPScannerCoordinator: ScannerControllerDelegate {

    func scannerSucceed(name: String?, mobileNumberOrCode: String?) {
        onScanSuccess?(name, mobileNumberOrCode)
        self.parentVc?.presentedViewController?.dissmiss()
    }

    func scannerFailed(errorMessage: String?) {
        onScanFailure?(errorMessage)
        self.parentVc?.presentedViewController?.dissmiss()
    }
    
    func cancelled() {
        onScanFailure?(Constants.cancelledMessage)
    }
}
