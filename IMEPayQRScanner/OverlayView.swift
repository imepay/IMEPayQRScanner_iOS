//
//  OverlayView.swift
//  IMEPayWallet
//
//  Created by Manoj Karki on 9/20/17.
//  Copyright © 2017 imedigital. All rights reserved.
//

import UIKit

class OverlayView: UIView {
    
    @IBOutlet weak var topLeftVLine     : UIView!
    @IBOutlet weak var topLeftHLine     : UIView!
     @IBOutlet weak var transHoleView   : UIView!
    @IBOutlet weak var topRightVLine    : UIView!
    @IBOutlet weak var topRightHLine    : UIView!
    
    @IBOutlet weak var bottomLeftVLine  : UIView!
    @IBOutlet weak var bottomLeftHLine  : UIView!
    
    @IBOutlet weak var bottomRightVLine : UIView!
    @IBOutlet weak var bottomRightHLine : UIView!

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        super.draw(rect)
        if transHoleView != nil {
            // Ensures to use the current background color to set the filling color

            //self.backgroundColor?.setFill()
            //UIRectFill(rect)

            let layer = CAShapeLayer()
            let path = CGMutablePath()
            
            // Make hole in view's overlay
            path.addRect(CGRect(x: transHoleView.frame.origin.x + 3.0, y: transHoleView.frame.origin.y + 3.0, width: transHoleView.bounds.width - 6.0, height: transHoleView.bounds.height - 6.0))
            path.addRect(bounds)

            layer.path = path
            layer.fillRule = kCAFillRuleEvenOdd
            self.layer.mask = layer
        } 
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        bringSubview(toFront: transHoleView)
        
        for redLine in transHoleView.subviews {
            bringSubview(toFront: redLine)
        }
        transHoleView.translatesAutoresizingMaskIntoConstraints = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
