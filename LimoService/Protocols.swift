//
//  Protocols.swift
//  LimoService
//
//  Created by Sameer Totey on 4/13/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import Foundation

protocol LocationCellDelegate: class {
    func lookupTouched(sender: LocationSelectionTableViewCell) -> Void
    func locationTextFieldUpdated(sender: LocationSelectionTableViewCell) -> Void
}

protocol TextFieldCellDelegate: class {
    func textFieldUpdated(sender: TextFieldCellTableViewCell) -> Void
}

protocol NumStepperCellDelegate: class {
    func stepperValueUpdated(sender: NumStepperCellTableViewCell) -> Void
}

protocol ButtonCellDelegate: class {
    func buttonTouched(sender: ButtonCellTableViewCell) -> Void
}

protocol DateSelectionDelegate: class {
    func dateUpdated(sender: DateSelectionTableViewCell) -> Void
    func dateButtonToggled(sender: DateSelectionTableViewCell) -> Void
}

protocol NavBarNotificationDelegate: class {
    func navigationBarStatusUpdated(newStatus: Bool) -> Void
}

protocol RequestInfoDelegate: class {
    func dateUpdated(newDate: NSDate,  newDateString: String) -> Void
    func neededHeight(height: CGFloat) -> Void
    func textFieldActivated() -> Void
}
