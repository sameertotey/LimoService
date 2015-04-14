//
//  Protocols.swift
//  LimoService
//
//  Created by Sameer Totey on 4/13/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import Foundation

protocol LocationCellDelegate {
    func lookupTouched(sender: LocationSelectionTableViewCell) -> Void
    func locationTextFieldUpdated(sender: LocationSelectionTableViewCell) -> Void
}

protocol TextFieldCellDelegate {
    func textFieldUpdated(sender: TextFieldCellTableViewCell) -> Void
}

protocol NumStepperCellDelegate {
    func stepperValueUpdated(sender: NumStepperCellTableViewCell) -> Void
}

protocol ButtonCellDelegate {
    func buttonTouched(sender: ButtonCellTableViewCell) -> Void
}

protocol DateSelectionDelegate {
    func dateUpdated(sender: DateSelectionTableViewCell) -> Void
    func dateButtonToggled(sender: DateSelectionTableViewCell) -> Void
}