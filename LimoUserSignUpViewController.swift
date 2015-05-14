//
//  LimoUserSignUpViewController.swift
//  LimoService
//
//  Created by Sameer Totey on 3/15/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class LimoUserSignUpViewController: PFSignUpViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let label = UILabel()
        label.backgroundColor = UIColor.blackColor()
        label.textColor = UIColor.whiteColor()
        label.text = "Limo Service"
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        label.sizeToFit()
        signUpView?.logo = label

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
}
