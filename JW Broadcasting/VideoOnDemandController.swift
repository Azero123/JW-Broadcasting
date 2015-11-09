//
//  VideoOnDemandController.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 9/25/15.
//  Copyright © 2015 xquared. All rights reserved.
//

import UIKit
import AVKit

class VideoOnDemandController: categoryController {
    
    override func viewDidLoad() {
        category="VideoOnDemand"
        super.viewDidLoad()
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(350, 300)
    }
    
}
