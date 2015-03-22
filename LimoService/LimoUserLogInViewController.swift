//
//  LimoUserLogInViewController.swift
//  LimoService
//
//  Created by Sameer Totey on 3/15/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class LimoUserLogInViewController: PFLogInViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let label = UILabel()
        label.backgroundColor = UIColor.blackColor()
        label.textColor = UIColor.whiteColor()
        label.text = "Limo Service"
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        label.sizeToFit()
        logInView?.logo = label
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
