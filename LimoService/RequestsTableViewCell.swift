//
//  RequestsTableViewCell.swift
//  LimoService
//
//  Created by Sameer Totey on 4/3/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class RequestsTableViewCell: PFTableViewCell {

    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var whenLabel: UILabel!
    @IBOutlet weak var statusIndicatorView: StatusIndicatiorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let fromLabel = UILabel(frame: CGRectZero)
//        fromLabel.text = "From: "
//        fromLabel.sizeToFit()
        let fromImageView = UIImageView(image: UIImage(named: "GreenLocationPin"))
        fromImageView.frame = CGRectMake(0, 0, 16, 24)

        fromTextField.leftView = fromImageView
        fromTextField.leftViewMode = .Always
        
        let toLabel = UILabel(frame: CGRectZero)
//        toLabel.text = "To: "
//        toLabel.sizeToFit()
        let toImageView = UIImageView(image: UIImage(named: "RedLocationPin"))
        toImageView.frame = CGRectMake(0, 0, 16, 24)
        

        toTextField.leftView = toImageView
        toTextField.leftViewMode = .Always

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
