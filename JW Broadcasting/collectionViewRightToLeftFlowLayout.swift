//
//  collectionViewRightToLeftFlowLayout.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 9/25/15.
//  Copyright © 2015 xquared. All rights reserved.
//

import UIKit

class collectionViewRightToLeftFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        
        
        let layoutAttribute=super.layoutAttributesForItemAtIndexPath(indexPath)
        layoutAttribute?.frame=CGRectMake( ((layoutAttribute?.frame.size.width)!*1.2)*CGFloat(indexPath.row), 0, (layoutAttribute?.frame.size.width)!, (layoutAttribute?.frame.size.height)!)
        
        return layoutAttribute
    }
}
