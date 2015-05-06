//
//  RequestInfoViewController.swift
//  LimoService
//
//  Created by Sameer Totey on 4/22/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class RequestInfoViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var labelLine1: UILabel!
    @IBOutlet weak var labelLine2: UILabel!
    @IBOutlet weak var labelLine3: UILabel!
    @IBOutlet weak var labelLine4: UILabel!
    @IBOutlet weak var labelLine5: UILabel!
    
    var savedLine1: UILabel!
    var savedLine2: UILabel!
    var savedLine3: UILabel!
    var savedLine4: UILabel!
    var savedLine5: UILabel!
    
    var savedDatePicker: UIDatePicker!
    var savedDateButton: UIButton!
    var savedTextField: UITextField!
    
    var limoRequest: LimoRequest? {
        didSet {
            updateUI()
        }
    }
    
    weak var delegate: RequestInfoDelegate?
    
    var date: NSDate? {
        didSet {
            if date != nil {
                datePicker?.minimumDate = date!.earlierDate(NSDate())
                datePicker?.date = date!
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
    
    private func updateUI() {
        if let datePicker = datePicker {
            if limoRequest == nil {
                placeEditableView()
            } else {
                placeDisplayView()
            }
        }
     }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // save a reference to all the views so that they are not deallocated by ARC
        savedDatePicker = datePicker
        savedDateButton = dateButton
        savedTextField = textField
        savedLine1 = labelLine1
        savedLine2 = labelLine2
        labelLine2.numberOfLines = 2
        savedLine3 = labelLine3
        labelLine3.numberOfLines = 2
        savedLine4 = labelLine4
        savedLine5 = labelLine5
        let fromLeftLabel = UILabel(frame: CGRectZero)
        fromLeftLabel.text = "From: "
        fromLeftLabel.sizeToFit()
        textField.leftView = fromLeftLabel
        textField.leftViewMode = .Always
        updateUI()
    }
    
    func configureDatePicker() {
        datePicker?.datePickerMode = .DateAndTime
        
        // Set min/max date for the date picker.
        // As an example we will limit the date between now and 15 days from now.
        let now = NSDate()
        datePicker?.minimumDate = now
        date = now
        
        let currentCalendar = NSCalendar.currentCalendar()
        
        let dateComponents = NSDateComponents()
        dateComponents.day = 15
        
        let fifteenDaysFromNow = currentCalendar.dateByAddingComponents(dateComponents, toDate: now, options: nil)
        datePicker?.maximumDate = fifteenDaysFromNow
        datePicker?.minuteInterval = 2
        datePicker?.addTarget(self, action: "updateDatePickerLabel", forControlEvents: .ValueChanged)
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
        dateButton?.setTitle(dateFormatter.stringFromDate(datePicker.date), forState: .Normal)
        if let date = datePicker?.date {
            delegate?.dateUpdated(date, newDateString: dateFormatter.stringFromDate(date))
        }
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

    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        delegate?.textFieldActivated()
        return false
    }
    
    func placeEditableView() {
        configureDatePicker()
        if datePicker != nil {
            datePickerHidden = !datePickerHidden
            datePickerHidden = true
        }
    }
    
    func placeDisplayView() {
        setLines()
        var viewsDict = Dictionary <String, UIView>()
        viewsDict["line1"] = labelLine1
        viewsDict["line2"] = labelLine2
        viewsDict["line3"] = labelLine3
        viewsDict["line4"] = labelLine4
        viewsDict["line5"] = labelLine5
        view.subviews.map({ $0.removeFromSuperview() })
        view.addSubview(labelLine1)
        view.addSubview(labelLine2)
        view.addSubview(labelLine3)
        view.addSubview(labelLine4)
        view.addSubview(labelLine5)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[line1]-|", options: nil, metrics: nil, views: viewsDict))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[line2]-|", options: nil, metrics: nil, views: viewsDict))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[line3]-|", options: nil, metrics: nil, views: viewsDict))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[line4]-|", options: nil, metrics: nil, views: viewsDict))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[line5]-|", options: nil, metrics: nil, views: viewsDict))
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[line1][line2][line3][line4][line5]|", options: nil, metrics: nil, views: viewsDict))
        let heightNeeded = labelLine1.sizeThatFits(self.view.bounds.size).height +
            labelLine2.sizeThatFits(self.view.bounds.size).height +
            labelLine3.sizeThatFits(self.view.bounds.size).height +
            labelLine4.sizeThatFits(self.view.bounds.size).height +
            labelLine5.sizeThatFits(self.view.bounds.size).height
            
        
        delegate?.neededHeight(heightNeeded)

    }
    
    func setLines() {
        [labelLine1, labelLine2, labelLine3, labelLine4, labelLine5].map {
            $0.text = ""
        }
        labelLine1.text = limoRequest?.whenString
        if let fromAddress = limoRequest?.fromAddress {
            if !fromAddress.isEmpty {
                labelLine2.text = "From: \(fromAddress) "
            }
        }
        if let toAddress = limoRequest?.toAddress {
            if !toAddress.isEmpty {
                labelLine3.text = "To: \(toAddress) "
            }
        }
        if let numBags = limoRequest?.numBags, numPassengers = limoRequest?.numPassengers, vehicle = limoRequest?.preferredVehicle {
            labelLine4.text = "Passengers:\(numPassengers) Bags:\(numBags) for \(vehicle)"
        }
        if let comment = limoRequest?.comment {
            labelLine5.text = comment
        }
    }
}
