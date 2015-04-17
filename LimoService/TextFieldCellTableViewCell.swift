//
//  TextFieldCellTableViewCell.swift
//  LimoService
//
//  Created by Sameer Totey on 4/13/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class TextFieldCellTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    
    @IBOutlet weak var textField: UITextField!
    
    weak var delegate: TextFieldCellDelegate?
    
    var textString: String? {
        didSet {
            textField.text = textString
        }
    }

    var enabled: Bool = true {
        didSet {
            textField.enabled = enabled
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textField.delegate = self
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        delegate?.textFieldUpdated(self)
        return false
    }

}
