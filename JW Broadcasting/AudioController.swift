//
//  AudioControllerViewController.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 11/6/15.
//  Copyright © 2015 xquared. All rights reserved.
//

/*

The code backing this UIViewController is for the "Audio" tab.
This UIViewController is a subclass of CategoryController please refer to CategoryController for anything regarding this controller as it only changes the graphics sizes and resource url used for fetching content.

*/


import UIKit
import AVKit

class AudioController: CategoryController {
    
    /*
    
    Sets the category property because string is used for fetching new content.
    
    */

    override func viewDidLoad() {
        
        /*
        
        All the code for this section is in CategoryController. However we can change some properties. For instance we need to specify the category file name in this case Audio. Also we need to appropriately space the items based on the size of the previews so that they are not on top of each other.
        
        */
        
        self.category="Audio"
        super.viewDidLoad()
        (self.videoCollection.collectionViewLayout as! CollectionViewAlignmentFlowLayout).spacingPercentile=1.2
        (self.videoCollection.collectionViewLayout as! CollectionViewAlignmentFlowLayout).headerSpace=100
    }
    
    /*
    
    Sets size of items displayed on the right section of the UIViewController.
    
    */
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        /*The size of each preview item*/
        
        return CGSizeMake(350, 350)
    }
    
}
