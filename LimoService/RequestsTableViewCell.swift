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
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let fromLabel = UILabel(frame: CGRectZero)
        fromLabel.text = "From: "
        fromLabel.sizeToFit()
        fromTextField.leftView = fromLabel
        fromTextField.leftViewMode = .Always
        
        let toLabel = UILabel(frame: CGRectZero)
        toLabel.text = "To: "
        toLabel.sizeToFit()
        toTextField.leftView = toLabel
        toTextField.leftViewMode = .Always

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
