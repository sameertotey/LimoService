//
//  LocationSelectionTableViewCell.swift
//  LimoService
//
//  Created by Sameer Totey on 4/13/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class LocationSelectionTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var locationNameTextField: UITextField!
    @IBOutlet weak var locationLookupButton: UIButton!
    @IBOutlet weak var locationAddressLabel: UILabel!
    var delegate: LocationCellDelegate?
    
    var locationName: String? {
        didSet {
            if locationName != locationNameTextField.text {
                locationNameTextField.text = locationName
            }
        }
    }
    
    var locationAddress: String? {
        didSet {
            locationAddressLabel.text = locationAddress
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        locationNameTextField.delegate = self
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
   
    // MARK: Actions
    
    @IBAction func lookupButtonTouched(sender: UIButton) {
        locationNameTextField.resignFirstResponder()
        delegate?.lookupTouched(self)
    }
    
    // MARK: TextField delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        locationName = textField.text
        delegate?.locationTextFieldUpdated(self)
        return false
    }
}
