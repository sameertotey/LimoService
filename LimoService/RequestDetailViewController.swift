//
//  RequestDetailViewController.swift
//  LimoService
//
//  Created by Sameer Totey on 4/4/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class RequestDetailViewController: UIViewController {
    var currentUser: PFUser!
    var limoRequest: LimoRequest!
    
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var whenLabel: UILabel!
    @IBOutlet weak var statusButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupFields()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupFields() {
        fromLabel.text = limoRequest.valueForKey("fromString") as? String
        toLabel.text = limoRequest.valueForKey("toString") as? String
        whenLabel.text = limoRequest.valueForKey("whenString") as? String
    }
    
    @IBAction func statusButtonTouchUpInside(sender: UIButton) {
        
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
