//
//  NumStepperCellTableViewCell.swift
//  LimoService
//
//  Created by Sameer Totey on 4/13/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class NumStepperCellTableViewCell: UITableViewCell {

    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var label: UILabel!
    
    var delegate: NumStepperCellDelegate?
    
    var value: Int? {
        didSet {
            if value != nil {
                stepper.value = Double(value!)
                label.text = "\(Int(stepper.value))"
            }
        }
    }
    
    var enabled: Bool = true {
        didSet {
            stepper.enabled = enabled
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

    
    func configureSteppers(initial: Double, minimum: Double, maximum: Double, step: Double) {
        stepper.value = initial
        value = Int(initial)
        stepper.minimumValue = minimum
        stepper.maximumValue = maximum
        stepper.stepValue = step
//        upDateLabel()
    }

//    func upDateLabel() {
//        label.text = "\(Int(stepper.value))"
//    }
    
    // MARK: - Actions
    @IBAction func stepperValueChangd(sender: UIStepper) {
//        upDateLabel()
        value = Int(sender.value)
        delegate?.stepperValueUpdated(self)
    }
    
}
