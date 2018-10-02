//
//  UIViewController+Extensions.swift
//  IMEPayWallet
//
//  Created by Manoj Karki on 9/14/17.
//  Copyright © 2017 imedigital. All rights reserved.
//

import UIKit

extension UIViewController {

    func addNavSeparator() {
        if let _ = navigationController {
           let separator = UIView(frame: CGRect(x: 0.0, y: 0.0, width: view.bounds.width, height: 1.0))
           separator.backgroundColor = UIColor(red: 244.0 / 255.0, green:  244.0 / 255.0, blue:  244.0 / 255.0, alpha: 1.0)
           view.addSubview(separator)
           view.bringSubview(toFront: separator)
        }
    }
    
//    class func topViewController() -> UIViewController {
//        let delegate = UIApplication.shared.delegate as! AppDelegate
//        var rootViewController = delegate.window!.rootViewController
//
//        while rootViewController?.presentedViewController != nil {
//            rootViewController = rootViewController?.presentedViewController
//        }
//        return rootViewController!
//    }

//    func addRightBarButton(title: String?, tintColor: UIColor = UIColor.black, sel: Selector) {
//        let rightBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: sel)
//        rightBarButtonItem.setTitleTextAttributes([NSForegroundColorAttributeName: baseColor(), NSFontAttributeName : UIFont.systemFont(ofSize: 13, weight: UIFontWeightBold)], for: .normal)
//        navigationItem.rightBarButtonItem = rightBarButtonItem
//    }

//    func addCancelBtn() {
//        let cancelBtn = UIBarButtonItem(image: UIImage(named:"close_small"), style: .plain, target: self, action:#selector(self.dissmiss))
//        navigationItem.rightBarButtonItem = cancelBtn
//    }

    func addCancelBtn(sel: Selector) {
        let cancelBtn = UIBarButtonItem(image: UIImage(named:"close_small"), style: .plain, target: self, action:sel)
        cancelBtn.tintColor = UIColor.black
        navigationItem.rightBarButtonItem = cancelBtn
    }

    func dissmiss() {
        self.dismiss(animated: true, completion: nil)
    }

//    func addWhiteNavCancelButton() {
//        navigationItem.leftBarButtonItem = UIBarButtonItem.init(image:#imageLiteral(resourceName: "back") , style: UIBarButtonItemStyle.plain, target: self, action: #selector(whiteNavButtonClicked))
//    }

//    @objc func whiteNavButtonClicked() {
//        let barButtonApperance = UIBarButtonItem.appearance()
//        barButtonApperance.tintColor = UIColor.black
//        UINavigationBar.addShowdowLine()
//        dissmiss()
//    }

}

protocol StoryboardInitializable {
    static var storyboardIdentifier: String { get }
}

extension StoryboardInitializable where Self: UIViewController {
    
    static var storyboardIdentifier: String {
        return String(describing: Self.self)
    }
    
    static func initFromStoryboard(name: String = "Main") -> Self {
        let storyboard = UIStoryboard(name: name, bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: storyboardIdentifier) as! Self
    }
}

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
    
    func showAlertWithOk(title: String?, message: String? = "", action1Title: String? = "Ok",  action2Title: String? = "Cancel", completion: @escaping (UIAlertAction) -> ()) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action1 = UIAlertAction(title: action1Title, style: .default, handler: completion)
        let action2 = UIAlertAction(title: action2Title, style: .default)
        
        alert.addAction(action1)
        alert.addAction(action2)
        present(alert, animated: true, completion: nil)
    }
    
    func showAlertWithOkCancel(title: String?, message: String? = "", action1Title: String? = "Ok",  action2Title: String? = "Cancel", okAction: @escaping (UIAlertAction) -> (), cancelAction: @escaping (UIAlertAction) -> ()) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action1 = UIAlertAction(title: action1Title, style: .default, handler: okAction)
        let action2 = UIAlertAction(title: action2Title, style: .default, handler: cancelAction)
        alert.addAction(action2)
        alert.addAction(action1)
        present(alert, animated: true, completion: nil)
    }

}
