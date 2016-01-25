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

class OldVideoOnDemandController: CategoryController {
    
    /*
    
    Sets the category property because string is used for fetching new content.
    
    */

    override func viewDidLoad() {
        
        /*
        
        All the code for this section is in CategoryController. However we can change some properties. For instance we need to specify the category file name in this case VideoOnDemand. Also we need to appropriately space the items based on the size of the previews so that they are not on top of each other.
        
        */
        self.category="VideoOnDemand"
        super.viewDidLoad()
        (self.videoCollection.collectionViewLayout as! CollectionViewAlignmentFlowLayout).headerSpace=50
    }
    
    /*
    
    Sets size of items displayed on the right section of the UIViewController.
    
    */
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let multiplier:CGFloat=1.5
        
        /*The size of each preview item*/
        
        /*
        Typically we are going to try to use the "ws" image ratio as the preview item because it fits properly.
        The typical size of the image is 320x180 but we provide more space for other image items that are not in that ratio.
        
        */
        
        return CGSizeMake(CGFloat(350)*multiplier, CGFloat(240)*multiplier+60)//640,360//ws320,180
    }
    
}
