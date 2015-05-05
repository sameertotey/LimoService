//
//  SegmentControlTableViewCell.swift
//  LimoService
//
//  Created by Sameer Totey on 5/5/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class SegmentControlTableViewCell: UITableViewCell {
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var delegate: SegmentControlCellDelegate?
    
    var selection: String? 
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureSegmentedControl() {
//        segmentControl.momentary = true
//        
//        segmentControl.setEnabled(false, forSegmentAtIndex: 0)
//        
        segmentControl.addTarget(self, action: "selectedSegmentDidChange:", forControlEvents: .ValueChanged)
    }
    
    // MARK: Actions
    func selectedSegmentDidChange(segmentedControl: UISegmentedControl) {
        
        selection = segmentControl.titleForSegmentAtIndex(segmentedControl.selectedSegmentIndex)
        
        NSLog("The selected segment changed to: \(selection).")
    
        delegate?.segmentControlUpdated(self)
    }
    

}
