//
//  RequestInfoViewController.swift
//  LimoService
//
//  Created by Sameer Totey on 4/22/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class RequestInfoViewController: UIViewController {

    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var textField: UITextField!
    
    var savedDatePicker: UIDatePicker!
    var savedDateButton: UIButton!
    var savedTextField: UITextField!
    
    weak var delegate: RequestInfoDelegate?
    
    var date: NSDate? {
        didSet {
            if date != nil {
                datePicker.minimumDate = date!.earlierDate(NSDate())
                datePicker.date = date!
                dateString = dateFormatter.stringFromDate(date!)
                updateDatePickerLabel()
            }
        }
    }
    
    var dateString: String?
    
    var enabled: Bool = true {
        didSet {
            dateButton.enabled = enabled
            datePicker.enabled = enabled
            textField.enabled = enabled
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialization code
        savedDatePicker = datePicker
        savedDateButton = dateButton
        savedTextField = textField
        let fromLabel = UILabel(frame: CGRectZero)
        fromLabel.text = "From: "
        fromLabel.sizeToFit()
        textField.leftView = fromLabel
        textField.leftViewMode = .Always
        configureDatePicker()
        datePickerHidden = true
    }
    
    func configureDatePicker() {
        datePicker.datePickerMode = .DateAndTime
        
        // Set min/max date for the date picker.
        // As an example we will limit the date between now and 15 days from now.
        let now = NSDate()
        datePicker.minimumDate = now
        date = now
        
        let currentCalendar = NSCalendar.currentCalendar()
        
        let dateComponents = NSDateComponents()
        dateComponents.day = 15
        
        let fifteenDaysFromNow = currentCalendar.dateByAddingComponents(dateComponents, toDate: now, options: nil)
        datePicker.maximumDate = fifteenDaysFromNow
        datePicker.minuteInterval = 2
        datePicker.addTarget(self, action: "updateDatePickerLabel", forControlEvents: .ValueChanged)
        updateDatePickerLabel()
    }
    
    
    /// A date formatter to format the `date` property of `datePicker`.
    lazy var dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        return dateFormatter
        }()
    
    func updateDatePickerLabel() {
        dateButton.setTitle(dateFormatter.stringFromDate(datePicker.date), forState: .Normal)
    }
    
    var datePickerHidden = false {
        didSet {
            if datePickerHidden != oldValue {
                var viewsDict = Dictionary <String, UIView>()
                viewsDict["dateButton"] = dateButton
                viewsDict["datePicker"] = datePicker
                viewsDict["textField"] = textField
                view.subviews.map({ $0.removeFromSuperview() })
                view.addSubview(dateButton)
                view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[dateButton]-|", options: nil, metrics: nil, views: viewsDict))
                if datePickerHidden {
                    view.addSubview(textField)
                    view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[textField]-|", options: nil, metrics: nil, views: viewsDict))
                    view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[dateButton][textField]|", options: nil, metrics: nil, views: viewsDict))
                } else {
                    view.addSubview(datePicker)
                    view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[datePicker]-|", options: nil, metrics: nil, views: viewsDict))
                    view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[dateButton][datePicker]|", options: nil, metrics: nil, views: viewsDict))
                }
                let heightNeeded: CGFloat
                if datePickerHidden {
                    heightNeeded = dateButton.sizeThatFits(self.view.bounds.size).height + textField.sizeThatFits(self.view.bounds.size).height
                } else {
                    heightNeeded = dateButton.sizeThatFits(self.view.bounds.size).height + datePicker.sizeThatFits(self.view.bounds.size).height
                }
                delegate?.neededHeight(heightNeeded)
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func buttonTouched(sender: UIButton) {
        datePickerHidden = !datePickerHidden
    }

}
