//
//  DateSelectionTableViewCell.swift
//  LimoService
//
//  Created by Sameer Totey on 4/13/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class DateSelectionTableViewCell: UITableViewCell {

    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var savedDatePicker: UIDatePicker?
    var savedDateButton: UIButton?
    
    var delegate: DateSelectionDelegate?
    
    var date: NSDate? {
        didSet {
            if date != nil{
                datePicker.date = date!
                dateString = dateFormatter.stringFromDate(date!)
            }
        }
    }
    
    var dateString: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        savedDatePicker = datePicker
        savedDateButton = dateButton
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
    
    var viewExpanded = false {
        didSet {
            self.hideDatePicker(!viewExpanded)
        }
    }
    
    func hideDatePicker(setting: Bool) {
        var viewsDict = Dictionary <String, UIView>()
        viewsDict["dateButton"] = savedDateButton
        viewsDict["datePicker"] = savedDatePicker
        contentView.subviews.map({ $0.removeFromSuperview() })
        contentView.addSubview(savedDateButton!)
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[dateButton]-|", options: nil, metrics: nil, views: viewsDict))
        if setting {
            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[dateButton]-|", options: nil, metrics: nil, views: viewsDict))
        } else {
            contentView.addSubview(savedDatePicker!)
            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[datePicker]-|", options: nil, metrics: nil, views: viewsDict))
            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[dateButton]-[datePicker]-|", options: nil, metrics: nil, views: viewsDict))
        }
        
    }
    
    // MARK: - Actions
    
    @IBAction func buttonTouched(sender: UIButton) {
        println("date button touched")
        delegate?.dateButtonToggled(self)
    }

}
