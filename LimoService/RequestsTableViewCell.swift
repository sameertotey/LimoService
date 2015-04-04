//
//  RequestsTableViewCell.swift
//  LimoService
//
//  Created by Sameer Totey on 4/3/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class RequestsTableViewCell: PFTableViewCell {

    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var whenLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
