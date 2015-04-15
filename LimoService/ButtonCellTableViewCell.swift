//
//  ButtonCellTableViewCell.swift
//  LimoService
//
//  Created by Sameer Totey on 4/13/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class ButtonCellTableViewCell: UITableViewCell {

    @IBOutlet weak var button: UIButton!
    
    var delegate: ButtonCellDelegate?
    
    var title: String? {
        didSet {
            button.setTitle(title, forState: .Normal)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Actions
    
    @IBAction func buttonTouchedInside(sender: UIButton) {
        delegate?.buttonTouched(self)
    }

}
