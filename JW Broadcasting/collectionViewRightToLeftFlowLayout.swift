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
        layoutAttribute?.frame=CGRectMake( ((layoutAttribute?.frame.size.width)!*1.1)*CGFloat(indexPath.row), 0, (layoutAttribute?.frame.size.width)!, (layoutAttribute?.frame.size.height)!)
        //layoutAttribute?.center=CGPoint(x: 10000, y: 10)
        
        return layoutAttribute
    }
   /*
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        print("is it working?")
        var attributes:Array<UICollectionViewLayoutAttributes>=[]
        
        for (var i=0;i<self.collectionView?.numberOfItemsInSection(0);i++){
            attributes.append(self.layoutAttributesForItemAtIndexPath(NSIndexPath(forRow: i, inSection: 0))!)
        }
        print(attributes)
        
        return attributes
    }
    */
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
}
