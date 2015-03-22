//
//  LocationTableViewCell.swift
//  LimoService
//
//  Created by Sameer Totey on 3/16/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {

    var addressLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addressLabel = UILabel(frame: CGRectZero)
        addressLabel!.autoresizingMask = .FlexibleWidth | .FlexibleHeight;
        addressLabel!.numberOfLines = 0;
        contentView.addSubview(addressLabel!)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        addressLabel?.attributedText = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let rect = CGRectInset(self.contentView.bounds, 15, 10);
        addressLabel!.frame = rect;     // We should have a addressLabel at this point
    }
    
}
