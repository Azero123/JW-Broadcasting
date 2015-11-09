//
//  audioControllerViewController.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 11/6/15.
//  Copyright © 2015 xquared. All rights reserved.
//

import UIKit
import AVKit

class audioController: categoryController {

    override func viewDidLoad() {
        category="Audio"
        super.viewDidLoad()
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(270, 320)
    }
    
}
