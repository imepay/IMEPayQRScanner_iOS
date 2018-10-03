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
    func scannerSucceed(qrString: String?)
    func scannerFailed(errorMessage: String?)
}

// MARK:- SDK Coordinator

final public class IMPScannerCoordinator {

    private struct Constants {
        static let mainStoryboardName = "QRCode"
        static let scannerVcScannerId = "QRCodeScannerViewController"
        static let somethingWentWrongMessage = "Something Went Wrong, Please try again later."
    }

    var onScanSuccess: (( _ qrString: String?) -> Void)?
    var onScanFailure: (( _ errorMessage: String?) -> Void)?

    private var parentVc: UIViewController?

    public init(parentViewController: UIViewController?) {
        self.parentVc = parentViewController
    }

    public func start() {
        let bundle  = Bundle.init(for: IMPScannerCoordinator.self)
        let storyboard = UIStoryboard.init(name: Constants.mainStoryboardName, bundle: bundle)
        guard let scannerVc = storyboard.instantiateViewController(withIdentifier: Constants.scannerVcScannerId) as? QRCodeScannerViewController else {
            onScanFailure?(Constants.somethingWentWrongMessage)
            return
        }
        
        scannerVc.scannerDelegate = self
        self.parentVc?.present(scannerVc, animated: true, completion: nil)
    }
}

// MARK:- ScannerControllerDelegate

extension IMPScannerCoordinator: ScannerControllerDelegate {
    
    func scannerSucceed(qrString: String?) {
        onScanSuccess?(qrString)
        self.parentVc?.presentedViewController?.dissmiss()
    }

    func scannerFailed(errorMessage: String?) {
        onScanFailure?(errorMessage)
        self.parentVc?.presentedViewController?.dissmiss()
    }
}

