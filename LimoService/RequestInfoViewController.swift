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
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var label6: UILabel!
    
    @IBOutlet weak var line1: UIView!
    @IBOutlet weak var line2: UIView!
    @IBOutlet weak var line3: UIView!
    @IBOutlet weak var line4: UIView!
    
    @IBOutlet weak var fromImage: UIImageView!
    @IBOutlet weak var toImage: UIImageView!
    @IBOutlet weak var passengersImage: UIImageView!
    @IBOutlet weak var bagsImage: UIImageView!
    @IBOutlet weak var dateImage: UIImageView!
    
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    
    var savedLabel1: UILabel!
    var savedLabel2: UILabel!
    var savedLabel3: UILabel!
    var savedLabel4: UILabel!
    var savedLabel5: UILabel!
    var savedLabel6: UILabel!
    
    var savedLine1: UIView!
    var savedLine2: UIView!
    var savedLine3: UIView!
    var savedLine4: UIView!
    
    var savedFromImage: UIImageView!
    var savedToImage: UIImageView!
    var savedPassengersImage: UIImageView!
    var savedBagsImage: UIImageView!
    var savedDateImage: UIImageView!
    
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
        savedLabel1 = label1
        savedLabel2 = label2
        savedLabel3 = label3
        savedLabel4 = label4
        savedLabel5 = label5
        savedLabel6 = label6
        let fromImageView = UIImageView(image: UIImage(named: "FromPin"))
        textField.leftView = fromImageView
        
        textField.leftViewMode = .Always
        savedTextField = textField
        
        savedFromImage = fromImage
        savedToImage = toImage
        savedDateImage = dateImage
        savedPassengersImage = passengersImage
        savedBagsImage = bagsImage
        savedLine1 = line1
        savedLine2 = line2
        savedLine3 = line3
        savedLine4 = line4
        
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
        tapGestureRecognizer.enabled = false
    }
    
    func placeDisplayView() {
        tapGestureRecognizer.enabled = true
        var viewsDict = Dictionary <String, UIView>()
        view.subviews.map({ $0.removeFromSuperview() })
        label1.text = nil
        label2.text = nil
        label3.text = nil
        label4.text = nil
        label5.text = nil
        label6.text = nil
        [line1, line2, line3, line4].map({
            $0.subviews.map({ $0.removeFromSuperview() })
        })
        viewsDict["line1"] = line1
        viewsDict["line2"] = line2
        viewsDict["line3"] = line3
        viewsDict["line4"] = line4
        viewsDict["label1"] = label1
        viewsDict["label2"] = label2
        viewsDict["label3"] = label3
        viewsDict["label4"] = label4
        viewsDict["label5"] = label5
        viewsDict["label6"] = label6
        viewsDict["fromImage"] = fromImage
        viewsDict["toImage"] = toImage
        viewsDict["passengersImage"] = passengersImage
        viewsDict["bagsImage"] = bagsImage

        view.addSubview(line1)
        view.addSubview(line2)
        view.addSubview(line3)
        view.addSubview(line4)

        setLines(viewsDict)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[line1]", options: nil, metrics: nil, views: viewsDict))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[line2]", options: nil, metrics: nil, views: viewsDict))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[line3]", options: nil, metrics: nil, views: viewsDict))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[line4]", options: nil, metrics: nil, views: viewsDict))


        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[line1][line2][line3][line4]", options: nil, metrics: nil, views: viewsDict))

        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        let heightNeeded = line1.sizeThatFits(view.bounds.size).height +
            line2.sizeThatFits(view.bounds.size).height +
            line3.sizeThatFits(view.bounds.size).height +
            line4.sizeThatFits(view.bounds.size).height
        
        delegate?.neededHeight(heightNeeded)

    }
    
    func setLines(viewsDict: Dictionary <String, UIView>) {
        line1.removeConstraints(line1.constraints())

        label1.text = limoRequest?.whenString
        line1.addSubview(label1)
        if let numPassengers = limoRequest?.numPassengers {
            label2.text = "\(numPassengers)  "
        }
        line1.addSubview(passengersImage)
        line1.addSubview(label2)

        if let numBags = limoRequest?.numBags {
            label3.text = "\(numBags)  "
        }
        line1.addSubview(bagsImage)
        line1.addSubview(label3)

        let label1Size = label1.sizeThatFits(view.bounds.size)
        let label2Size = label2.sizeThatFits(view.bounds.size)
        let label3Size = label3.sizeThatFits(view.bounds.size)
        let passengersImageSize = passengersImage.sizeThatFits(view.bounds.size)
        let bagsImageSize = bagsImage.sizeThatFits(view.bounds.size)
        let line1Height = max(label1Size.height, label2Size.height, label3Size.height, passengersImageSize.height, bagsImageSize.height)
        line1.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[label1]-[passengersImage]-[label2]-[bagsImage]-[label3]-|", options: nil, metrics: nil, views: viewsDict))
        line1.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[label1]", options: nil, metrics: nil, views: viewsDict))
        line1.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[passengersImage]", options: nil, metrics: nil, views: viewsDict))
        line1.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[label2]|", options: nil, metrics: nil, views: viewsDict))
        line1.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[bagsImage]", options: nil, metrics: nil, views: viewsDict))
        line1.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[label3]", options: nil, metrics: nil, views: viewsDict))
        line1.addConstraint(NSLayoutConstraint(item: line1, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: line1Height))
        
        line2.removeConstraints(line2.constraints())
        if let fromAddress = limoRequest?.fromAddress, fromName = limoRequest?.fromName {
            if !fromAddress.isEmpty {
                label4.text = fromAddress.fullAddressString(fromName)
                line2.addSubview(fromImage)
                line2.addSubview(label4)
                line2.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[fromImage]-[label4]-|", options: nil, metrics: nil, views: viewsDict))
                line2.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[fromImage]", options: nil, metrics: nil, views: viewsDict))
                line2.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[label4]", options: nil, metrics: nil, views: viewsDict))
                let label4Size = label4.sizeThatFits(view.bounds.size)
                let fromImageSize = fromImage.sizeThatFits(view.bounds.size)
                let line2Height = max(label4Size.height, fromImageSize.height)
                line2.addConstraint(NSLayoutConstraint(item: line2, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: line2Height))
            }
        }
        

        line3.removeConstraints(line3.constraints())
        if let toAddress = limoRequest?.toAddress, toName = limoRequest?.toName {
            if !toAddress.isEmpty {
                label5.text = toAddress.fullAddressString(toName)
                line3.addSubview(toImage)
                line3.addSubview(label5)
                line3.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[toImage]-[label5]-|", options: nil, metrics: nil, views: viewsDict))
                line3.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[toImage]", options: nil, metrics: nil, views: viewsDict))
                line3.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[label5]", options: nil, metrics: nil, views: viewsDict))
                let label5Size = label5.sizeThatFits(view.bounds.size)
                let toImageSize = fromImage.sizeThatFits(view.bounds.size)
                let line3Height = max(label5Size.height, toImageSize.height)
                line3.addConstraint(NSLayoutConstraint(item: line3, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: line3Height))

            }
        }
//        line3.setNeedsLayout()
//        line3.layoutIfNeeded()
//        line3.sizeToFit()
//        let line3Size = line3.sizeThatFits(CGSizeMake(view.frame.width, 600))
        
        line4.removeConstraints(line4.constraints())
        if let comment = limoRequest?.comment {
            label6.text = comment
            line4.addSubview(label6)
            line4.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[label6]-|", options: nil, metrics: nil, views: viewsDict))
            line4.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[label6]", options: nil, metrics: nil, views: viewsDict))
            line4.addConstraint(NSLayoutConstraint(item: line4, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: label6.sizeThatFits(view.bounds.size).height))

        }

//        if let toAddress = limoRequest?.toAddress {
//            if !toAddress.isEmpty {
//                labelLine3.text = "To: \(toAddress) "
//            }
//        }
//        if let numBags = limoRequest?.numBags, numPassengers = limoRequest?.numPassengers, vehicle = limoRequest?.preferredVehicle {
//            labelLine4.text = "Passengers:\(numPassengers) Bags:\(numBags) for \(vehicle)"
//        }
//        if let comment = limoRequest?.comment {
//            labelLine5.text = comment
//        }
    }
    
    
    @IBAction func viewTapped(sender: AnyObject) {
        println("view was tapped.......")
        delegate?.displayViewTapped()
    }
    
}

extension String {
    func fullAddressString(name: String) -> String {
        let fullString: String
        if self.hasPrefix(name) {
            fullString = String(map(self.generate()) {
                $0 == "\n" ? ";" : $0
                })
        } else {
            fullString = String(map((name + ";" + self).generate()) {
                $0 == "\n" ? ";" : $0
                })
        }
        return fullString
    }
}
