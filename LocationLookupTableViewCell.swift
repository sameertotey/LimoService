//
//  LocationLookupTableViewCell.swift
//  LimoService
//
//  Created by Sameer Totey on 4/1/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class LocationLookupTableViewCell: PFTableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
