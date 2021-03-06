//
//  StatusIndicatiorView.swift
//  LimoService
//
//  Created by Sameer Totey on 4/14/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class StatusIndicatiorView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBInspectable var borderColor: UIColor = UIColor.clearColor() {
        didSet {
            layer.borderColor = borderColor.CGColor
        }
    }

    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 3.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var preferredWidth: CGFloat = 6
    @IBInspectable var preferredHeight: CGFloat = 100
    
    override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(preferredWidth, preferredHeight)
    }
}
