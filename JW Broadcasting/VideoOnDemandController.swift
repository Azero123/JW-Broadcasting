//
//  VideoOnDemandController.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 9/25/15.
//  Copyright © 2015 xquared. All rights reserved.
//

/*

The code backing this UIViewController is for the "Video On Demand" tab.
This UIViewController is a subclass of CategoryController please refer to CategoryController for anything regarding this controller as it only changes the graphics sizes and resource url used for fetching content.

*/


import UIKit
import AVKit

class VideoOnDemandController: CategoryController {
    
    /*
    
    Sets the category property because string is used for fetching new content.
    
    */

    override func viewDidLoad() {
        self.category="VideoOnDemand"
        super.viewDidLoad()
        (self.videoCollection.collectionViewLayout as! CollectionViewAlignmentFlowLayout).headerSpace=50
    }
    
    /*
    
    Sets size of items displayed on the right section of the UIViewController.
    
    */
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let multiplier:CGFloat=1.5
        //908,512
        return CGSizeMake(CGFloat(350)*multiplier, CGFloat(240)*multiplier+60)//640,360//ws320,180
        //320,205-(60)
    }
    
}
