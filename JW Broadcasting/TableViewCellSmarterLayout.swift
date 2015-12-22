//
//  TableViewCellSmarterLayout.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 12/20/15.
//  Copyright © 2015 xquared. All rights reserved.
//

import UIKit

class TableViewCellSmarterLayout: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.detailTextLabel?.center=CGPoint(x: (self.detailTextLabel?.center.x)!, y: self.frame.size.height/2)
    }

}
