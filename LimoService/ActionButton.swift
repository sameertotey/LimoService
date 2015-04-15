//
//  ActionButton.swift
//  LimoService
//
//  Created by Sameer Totey on 4/15/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class ActionButton: UIButton {
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
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var normalTitle: String? {
        didSet{
            if normalTitle != nil {
                setTitle(normalTitle, forState: .Normal)
            }
        }
    }
    
    @IBInspectable var widthPadding: CGFloat = 0.0
    
    @IBInspectable var heightPadding: CGFloat = 0.0
    
    override func intrinsicContentSize() -> CGSize {
        var size = super.intrinsicContentSize()
        return CGSizeMake(size.width + widthPadding, size.height + heightPadding)
    }
}
