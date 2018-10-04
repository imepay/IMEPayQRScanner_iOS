//
//  UIViewController+Extensions.swift
//  IMEPayWallet
//
//  Created by Manoj Karki on 9/14/17.
//  Copyright © 2017 imedigital. All rights reserved.
//

import UIKit

// MARK:- UIViewController Extensions

extension UIViewController {

    func dissmiss() {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK:- Storyboard initialization protocols

protocol StoryboardInitializable {
    static var storyboardIdentifier: String { get }
}

extension StoryboardInitializable where Self: UIViewController {
    
    static var storyboardIdentifier: String {
        return String(describing: Self.self)
    }

    static func initFromStoryboard(name: String = "Scanner") -> Self {
        let bundle  = Bundle.init(for: IMPScannerCoordinator.self)
        let storyboard = UIStoryboard(name: name, bundle: bundle)
        return storyboard.instantiateViewController(withIdentifier: storyboardIdentifier) as! Self
    }
}

// MARK:- Alert Handlers

extension UIViewController {

    func showAlert(title: String?, message: String? = "", actionTitle: String? = "Ok") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: actionTitle, style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func showAlertWithCompletion(title: String?, message: String? = "", actionTitle: String? = "Ok", completion: @escaping (UIAlertAction) -> ()){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: actionTitle, style: .default, handler: completion)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

// UIView Extensions

extension UIView {

    func rounded() {
        set(cornerRadius: self.frame.height / 2)
    }

    func set(cornerRadius radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
}
